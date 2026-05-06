#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>

int read_count=0;
int shared_mem=0;
pthread_mutex_t mutex;
pthread_mutex_t rw_mutex;
// int read_count = 0;

void* read(void* arg) {
    pthread_mutex_lock(&mutex);
    read_count++;
    if (read_count == 1)
        pthread_mutex_lock(&rw_mutex);
    pthread_mutex_unlock(&mutex);

    printf("Reading %d\n", shared_mem);

    pthread_mutex_lock(&mutex);
    read_count--;
    if (read_count == 0)
        pthread_mutex_unlock(&rw_mutex);
    pthread_mutex_unlock(&mutex);

    return NULL;
}

void* write(void* arg) {
    pthread_mutex_lock(&rw_mutex);
    shared_mem++;
    printf("Writing %d\n", shared_mem);
    pthread_mutex_unlock(&rw_mutex);

    return NULL;
}

int main(){
    int n_read=5;
    int n_write=10;
    pthread_t thr_prod[n_read];
    pthread_t thr_cons[n_write];
    printf("main process pid: %d\n",getpid());
    pthread_mutex_init(&mutex,NULL);
    pthread_mutex_init(&rw_mutex,NULL);
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
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&rw_mutex);
}