#include <stdio.h>

int main(int argc, char* argv[]){
    if(argc!=2){
        printf("nope\n");
        return 1;
    }
    int n=atoi(argv[1]);
    int status=1;
    int f;
    for(int i=0;i<n;i++){
        f=fork();
        if(f>0){
            wait();
        }
        else if(f==0){
            status*=2;
            if(i==n-1){
                printf("%d\n",status);
            } 
        }
    }
}