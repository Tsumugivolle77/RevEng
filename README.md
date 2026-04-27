# RevEng: LLM-assisted Symbolic Test Harness Generation

A tool that automatically generates KLEE symbolic execution test harnesses using LLMs, designed to verify behavioral equivalence between two functionally identical C functions — for example, an original implementation and its decompiled or transcoded counterpart.

## How It Works

```
Input: two C functions f and f'
  → Parse function signatures (Tree-sitter)
  → LLM generates a KLEE test harness
  → Compile and run KLEE in Docker
  → Compare outputs and report differences
```

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Anaconda](https://www.anaconda.com/) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- An [Anthropic API key](https://console.anthropic.com/)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Tsumugivolle77/RevEng.git
cd RevEng
```

### 2. Configure Python Environment

```bash
conda create -n reveng python=3.11
conda activate reveng
pip install -r requirements.txt
```

### 3. Configure API Key

Create a `.env` file in the project root:

```
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxx
```

### 4. Start the KLEE Docker Container

Pull the KLEE image and start the container with the project directory mounted:

```bash
docker pull klee/klee:latest

docker run -it \
  --name klee_demo \
  -v $(pwd):/workspace \
  klee/klee:latest \
  /bin/bash
```

After the first run, you can restart the container with:

```bash
docker start klee_demo
```

## Usage

Place your two C functions in:

```
RevEngCode/functions/f.c        # original function
RevEngCode/functions/f_prime.c  # function to compare
```

Then run the pipeline:

```bash
conda activate reveng
python RevEngCode/src/main.py
```

The tool will:
1. Parse both function signatures
2. Generate a KLEE harness via Claude API
3. Compile and run KLEE inside Docker
4. Report whether the two functions are behaviorally equivalent

## Project Structure

```
RevEng/
├── .env                        # API key (not committed)
├── .gitignore
├── requirements.txt
└── RevEngCode/
    ├── functions/
    │   ├── f.c                 # original function
    │   └── f_prime.c           # function to compare
    ├── harness.c               # LLM-generated harness (auto-generated)
    └── src/
        ├── main.py             # pipeline entry point
        ├── parse_signature.py  # Tree-sitter based signature parser
        └── generate_harness.py # Claude API harness generator
```

## Roadmap

- [x] Environment setup
- [x] Function signature parsing (Tree-sitter)
- [x] LLM-based harness generation (Claude API)
- [x] End-to-end demo pipeline
- [ ] Support for more complex types (structs, arrays, pointers)
- [ ] Automated evaluation against benchmark datasets
- [ ] Result visualization and reporting
- [ ] Add GUI support
- [ ] Add new language support