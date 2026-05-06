#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NBUF 2
int arr[NBUF];
int in=0;
int out=0;
int count=0;
pthread_mutex_t l;
pthread_cond_t empty;
pthread_cond_t full;


void* produce(void* arg){
    int val= *(int *)arg;
    pthread_mutex_lock(&l);
    while(count==NBUF){
        pthread_cond_wait(&full,&l);
    }
    arr[in]=val;
    int prev_in=in;
    in=(in+1)%NBUF;
    count++;
    printf("produced %d in thread %lu\n",val,(unsigned long)pthread_self());
    pthread_cond_broadcast(&empty);
    pthread_mutex_unlock(&l);
}

void* consume(){
    pthread_mutex_lock(&l);
    while(count==0){
        pthread_cond_wait(&empty,&l);
    }
    int val=arr[out];
    int prev_out=out;
    out=(out+1)%NBUF;
    count--;
    printf("consumed %d in thread %lu\n",val,(unsigned long)pthread_self());
    pthread_cond_broadcast(&full);
    pthread_mutex_unlock(&l);
}


int main(){
    int n_prod=5;
    int n_cons=5;
    pthread_t thr_prod[n_prod];
    pthread_t thr_cons[n_cons];
    int arg_prod[n_prod];
    printf("main process pid: %d\n",getpid());
    pthread_mutex_init(&l,NULL);
    pthread_cond_init(&empty,NULL);
    pthread_cond_init(&full,NULL);

    for(int i=0;i<n_prod;i++){
        arg_prod[i]=i;
        pthread_create(&(thr_prod[i]),NULL,produce,&(arg_prod[i]));
    }
    for(int i=0;i<n_cons;i++){
        pthread_create(&(thr_cons[i]),NULL,consume,NULL);
    }
    for(int i=0;i<n_prod;i++){
        pthread_join(thr_prod[i],NULL);
    }
    for(int i=0;i<n_cons;i++){
        pthread_join(thr_cons[i],NULL);
    }
    pthread_mutex_destroy(&l);
    pthread_cond_destroy(&empty);
    pthread_cond_destroy(&full);
}