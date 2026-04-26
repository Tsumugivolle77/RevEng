import subprocess
import os
from dotenv import load_dotenv
from parse_signature import parse_function_signature
from generate_harness import generate_and_validate

# 基于当前文件位置计算路径
# src/main.py -> RevEngCode/
SRC_DIR = os.path.dirname(os.path.abspath(__file__))
REVENGCODE_DIR = os.path.dirname(SRC_DIR)
REVENG_DIR = os.path.dirname(REVENGCODE_DIR)

# 加载.env（在RevEng根目录下）
load_dotenv(dotenv_path=os.path.join(REVENG_DIR, ".env"))

DOCKER_WORKSPACE = "/workspace/RevEngCode"


def compile_all():
    print("=== 编译所有文件 ===")
    
    files = [
        ("functions/f.c", "f.bc"),
        ("functions/f_prime.c", "f_prime.bc"),
        ("harness.c", "harness.bc"),
    ]
    
    for src, out in files:
        result = subprocess.run(
            ["docker", "exec", "klee_demo",
             "clang", "-emit-llvm", "-c", "-g", "-O0",
             f"{DOCKER_WORKSPACE}/{src}",
             "-o", f"{DOCKER_WORKSPACE}/{out}"],
            capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"❌ 编译 {src} 失败:")
            print(result.stderr)
            return False
        print(f"✅ {src} 编译成功")
    
    # 链接
    result = subprocess.run(
        ["docker", "exec", "klee_demo",
         "llvm-link",
         f"{DOCKER_WORKSPACE}/f.bc",
         f"{DOCKER_WORKSPACE}/f_prime.bc",
         f"{DOCKER_WORKSPACE}/harness.bc",
         "-o", f"{DOCKER_WORKSPACE}/combined.bc"],
        capture_output=True, text=True
    )
    
    if result.returncode != 0:
        print("❌ 链接失败:")
        print(result.stderr)
        return False
    
    print("✅ 链接成功")
    return True


def run_klee():
    print("\n=== 运行KLEE ===")
    result = subprocess.run(
        ["docker", "exec", "klee_demo",
         "klee", "--max-time=30s",
         f"{DOCKER_WORKSPACE}/combined.bc"],
        capture_output=True, text=True
    )
    print(result.stdout)
    print(result.stderr)
    return result.returncode


def parse_results():
    print("\n=== 分析结果 ===")
    result = subprocess.run(
        ["docker", "exec", "klee_demo",
         "bash", "-c",
         f"ls {DOCKER_WORKSPACE}/klee-last/"],
        capture_output=True, text=True
    )
    
    files = result.stdout.strip().split('\n')
    test_count = sum(1 for f in files if f.endswith('.ktest'))
    error_count = sum(1 for f in files if f.endswith('.err'))
    
    print(f"生成测试用例：{test_count} 个")
    
    if error_count > 0:
        print(f"⚠️  发现 {error_count} 个断言失败，两函数行为不一致！")
    else:
        print("✅ 未发现差异，两函数行为一致")


def run_pipeline(f_path: str, f_prime_path: str):
    print("=== 解析函数签名 ===")
    
    with open(f_path) as file:
        sig_f = parse_function_signature(file.read())
    with open(f_prime_path) as file:
        sig_f_prime = parse_function_signature(file.read())
    
    print(f"函数1：{sig_f}")
    print(f"函数2：{sig_f_prime}")
    
    print("\n=== 生成Harness ===")
    generate_and_validate(sig_f, sig_f_prime)
    
    if not compile_all():
        return
    
    run_klee()
    parse_results()


if __name__ == "__main__":
    f_path = os.path.join(REVENGCODE_DIR, "functions", "f.c")
    f_prime_path = os.path.join(REVENGCODE_DIR, "functions", "f_prime.c")
    
    run_pipeline(f_path, f_prime_path)