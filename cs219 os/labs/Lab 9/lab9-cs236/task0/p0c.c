#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

int total = 0;
pthread_mutex_t l;
void* increment(void *arg) {
    // TODO: Increment total by x for 1 million times, where x is the argument passed to the thread.
    int x=0;
    for (int i = 0; i < 1000000; i++) {
        x += *(int*)arg;
        pthread_mutex_lock(&l);
        total+=*(int*)arg;
        pthread_mutex_unlock(&l);
    }
    int *result = malloc(sizeof(int));
    *result=x;
    // TODO: Return the total increment done by this thread (i.e., x * 1000000) as the thread's return value.
    return result;
}

int main() {
    // TODO: Create threads to run increment function with arguments 1, 2, 3, and 4 respectively.
    pthread_t a,b,c,d;
    
    int arg1=1;
    int arg2=2;
    int arg3=3;
    int arg4=4;
    pthread_create(&a,NULL,increment,&arg1);
    pthread_create(&b,NULL,increment,&arg2);
    pthread_create(&c,NULL,increment,&arg3);
    pthread_create(&d,NULL,increment,&arg4);
    // TODO: Wait for all threads to finish and print the total value.
    void* r1;
    void* r2;
    void* r3;
    void* r4;
    pthread_join(a,&r1);
    pthread_join(b,&r2);
    pthread_join(c,&r3);
    pthread_join(d,&r4);
    printf("Thread %d incremented total by %d\n", 1, *(int*)r1);
    printf("Thread %d incremented total by %d\n", 2, *(int*)r2);
    printf("Thread %d incremented total by %d\n", 3, *(int*)r3);
    printf("Thread %d incremented total by %d\n", 4, *(int*)r4);
    printf("Total: %d\n", total);
    free(r1); free(r2); free(r3); free(r4);
    pthread_mutex_destroy(&l);
    return 0;
}