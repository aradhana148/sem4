#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>

#define MAX_INPUT_SIZE 1024
#define MAX_NUM_TOKENS 64

/*
 * Splits the command string by space and returns the array of tokens
 * You'd need to free the memory after using these tokens.
 *
 * @param line: the input string
 * @return the array of tokens
 */
char** tokenize(char* line) {
    int token_no = 0;
    char** tokens = (char**)malloc(MAX_NUM_TOKENS * sizeof(char*));
    char* token = strtok(line, " \n\t");

    while (token != NULL && token_no < MAX_NUM_TOKENS) {
        tokens[token_no] = (char*)malloc(strlen(token) + 1);
        strcpy(tokens[token_no++], token);
        token = strtok(NULL, " \n\t");
    }
    tokens[token_no] = NULL;

    return tokens;
}

int main(int argc, char* argv[]) {
    char line[MAX_INPUT_SIZE];
    char** tokens;
    int i;

    while (1) {
        bzero(line, sizeof(line));
        printf("$ ");
        char* ret = fgets(line, sizeof(line), stdin);
        if (ret == NULL) return 0;

        tokens = tokenize(line);
        for (i = 0; tokens[i] != NULL; i++) {
            printf("DEBUG: found token '%s'\n", tokens[i]);
        }

        if(tokens[0] && strcmp(tokens[0],"cd")==0){
            chdir(tokens[1]);
        }
        int j=0;
        while(tokens[j]!=NULL){
            if(strcmp(tokens[i],"|")==0){
                int fdpipe[2];
                int p=pipe(fdpipe);
                dup2()
                write(fdpipe[1],)
            }

        int f=fork();
        if(f==0){
            int i=0;
            int fd;
            while(tokens[i]!=NULL){
                if(strcmp(tokens[i],">")==0){
                    fd=open(tokens[i+1],O_WRONLY | O_CREAT,0644);
                    dup2(fd,1);
                    printf("fe%s\n",tokens[i+1]);
                    break;
                }
                i++;
            }
            printf("%d\n",getpid());
            execvp(tokens[0],tokens);
            close(fd);
            
        }
        else if(f>0){
            waitpid(f,NULL,0);
        }
        else{
            printf("lik\n");
        }
        
        for (i = 0; tokens[i] != NULL; i++) free(tokens[i]);
        free(tokens);
    }
}
