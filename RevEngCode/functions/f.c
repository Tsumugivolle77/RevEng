int count_bits_v1(int num) {
    int count = 0;
    for (int i = 0; i < 32; i++) {
        if ((num >> i) & 1) count++;
    }
    return count;
}