#include "user.h"
int main(int argc, char const *argv[])
{
    uint64 va = atoi(argv[1]);
    int pid = 0;

    if(argc == 3){
        pid = atoi(argv[2]);
    } else {
        pid = getpid();
    }
    int pa = 0;
    if(argc > 3|| argc ==1){
        printf("Usage: vatopa virtual_address [pid]\n");
        exit(1);
    } else {

    pa = va2pa(va, pid);
    }

    printf("0x%x\n", pa);
    return 0;
}
