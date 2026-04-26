#include <klee/klee.h>
#include <assert.h>

int count_bits_v1(int num);
int count_bits_v2(int num);

int main() {
    int num;
    klee_make_symbolic(&num, sizeof(num), "num");
    int r1 = count_bits_v1(num);
    int r2 = count_bits_v2(num);
    assert(r1 == r2);
    return 0;
}