import anthropic
import subprocess
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HARNESS_PATH = os.path.join(BASE_DIR, "harness.c")
DOCKER_WORKSPACE = "/workspace/RevEngCode"

SYSTEM_PROMPT = """
You are a KLEE test harness generator. You output only raw C code, nothing else.

Rules:
- No markdown, no backticks, no explanations
- Always include <klee/klee.h> and <assert.h>
- Always forward declare both functions before main()
- Use klee_make_symbolic() for every scalar parameter
- Store return values in separate variables before asserting
- For char* parameters: use a fixed buffer of size 32, make it symbolic, assume last byte is '\\0'
- For pointer parameters: declare the pointed-to variable, make it symbolic, pass its address

Example output for (int f(int x), int f_prime(int x)):
#include <klee/klee.h>
#include <assert.h>

int f(int x);
int f_prime(int x);

int main() {
    int x;
    klee_make_symbolic(&x, sizeof(x), "x");
    int r1 = f(x);
    int r2 = f_prime(x);
    assert(r1 == r2);
    return 0;
}
"""

def build_user_prompt(sig_f: dict, sig_f_prime: dict) -> str:
    def format_sig(sig):
        params = ', '.join(
            f"{p['type']} {p['name']}" for p in sig['params']
        )
        return f"{sig['return_type']} {sig['name']}({params})"
    
    return f"""Generate a KLEE harness to compare these two functions:
Function 1: {format_sig(sig_f)}
Function 2: {format_sig(sig_f_prime)}"""


def generate_harness(sig_f: dict, sig_f_prime: dict) -> str:
    client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
    
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        system=SYSTEM_PROMPT,
        messages=[{
            "role": "user",
            "content": build_user_prompt(sig_f, sig_f_prime)
        }]
    )
    
    result = message.content[0].text
    result = result.replace("```c", "").replace("```", "").strip()
    
    return result


def generate_and_validate(sig_f: dict, sig_f_prime: dict, max_retries: int = 3) -> str:
    for attempt in range(max_retries):
        print(f"Attempt {attempt + 1}: generating harness...")
        code = generate_harness(sig_f, sig_f_prime)
        
        with open(HARNESS_PATH, "w") as f:
            f.write(code)
        print(f"Harness written to: {HARNESS_PATH}")
        
        result = subprocess.run(
            ["docker", "exec", "klee_demo",
             "clang", "-emit-llvm", "-c", "-g", "-O0",
             f"{DOCKER_WORKSPACE}/harness.c",
             "-o", f"{DOCKER_WORKSPACE}/harness.bc"],
            capture_output=True, text=True
        )
        
        if result.returncode == 0:
            print(f"[OK] Attempt {attempt + 1} succeeded: harness compiled successfully")
            return code
        else:
            print(f"[FAILED] Compilation failed, retrying...")
            print(result.stderr)
    
    raise Exception("Harness generation failed after maximum retries")