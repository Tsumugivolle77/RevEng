// harness.c
#include "klee/klee.h"
#include <assert.h>

// 把两个函数都包含进来
int count_bits_v1(int num);
int count_bits_v2(int num);

int main() {
    int x;
    
    // 告诉KLEE：x是符号变量（未知输入）
    klee_make_symbolic(&x, sizeof(x), "x");
    
    // 对比两个函数的输出
    int r1 = count_bits_v1(x);
    int r2 = count_bits_v2(x);
    
    // 如果不一致，触发断言失败——KLEE会记录这个输入
    klee_assert(r1 == r2);
    
    return 0;
}