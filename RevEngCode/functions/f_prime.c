int count_bits_v2(int num) {
    int count = 0;
    while (num) {
        num &= (num - 1);
        count++;
    }
    return count;
}