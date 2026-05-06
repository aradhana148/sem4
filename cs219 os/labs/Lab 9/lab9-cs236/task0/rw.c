#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>

int read_count=0;
int shared_mem=0;
pthread_mutex_t l;
pthread_cond_t c;

void* read(){
    pthread_mutex_lock(&l);
    read_count++;
    pthread_mutex_unlock(&l);
    pthread_mutex_lock(&l);
    printf("Reading %d\n",shared_mem);
    pthread_mutex_unlock(&l);
    pthread_mutex_lock(&l);
    read_count--;
    if(read_count==0){
        pthread_cond_broadcast(&c);
    }
    // pthread_cond_signal(&c);
    pthread_mutex_unlock(&l);
}

void* write(){
    pthread_mutex_lock(&l);
    while(read_count>0){
        pthread_cond_wait(&c,&l);
    }
    shared_mem++;
    printf("Writing %d\n",shared_mem);
    pthread_mutex_unlock(&l);
}

int main(){
    int n_read=5;
    int n_write=10;
    pthread_t thr_prod[n_read];
    pthread_t thr_cons[n_write];
    printf("main process pid: %d\n",getpid());
    pthread_mutex_init(&l,NULL);
    pthread_cond_init(&c,NULL);
    for(int i=0;i<n_read;i++){
        pthread_create(&(thr_prod[i]),NULL,read,NULL);
    }
    for(int i=0;i<n_write;i++){
        pthread_create(&(thr_cons[i]),NULL,write,NULL);
    }
    
    for(int i=0;i<n_read;i++){
        pthread_join(thr_prod[i],NULL);
    }
    for(int i=0;i<n_write;i++){
        pthread_join(thr_cons[i],NULL);
    }
    pthread_mutex_destroy(&l);
    pthread_cond_destroy(&c);
}