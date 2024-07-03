/* gopipe.c
 *
 * CSC 360, Spring 2024
 *
 * Execute up to four instructions, piping the output of each into the
 * input of the next.
 *
 * Please change the following before submission:
 *
 * Author: Markus Sekhon
 */

/* Note: The following are the **ONLY** header files you are
 * permitted to use for this assignment! */

#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <wait.h>

#define MAXCMDLENGTH 80
#define MAXARGS 8
#define MAXCMDS 4

typedef struct {
    char args[MAXARGS][MAXCMDLENGTH];
    int numOfArgs;
} Command;

/*
 * Prototypes
 */

/*Function Name: store_commands
 * stores the command passed by the user to command struct to be housed
 * cmd is the command
 * command is the pointer to the command struct in which we wish to store
 */
void store_commands(char *cmd, Command *command);

/*Function Name: read_commands
 * prompts user to input commands to be piped together, stores input commands
 * commands is an array of structs in which we store the commands
 * sizeOfCommands is max number of commands we can take in from user
 * numOfCmds is a number we update to signify how many commands have been input
 */
void read_commands(Command commands[], int sizeOfCommands, int *numOfCmds);

/*Function Name: create_pipes
 * creates appropriate number of pipes to have all commands communicate
 * pipes is an array of nested size 2 int arrays to be used to open the pipes
 * numOfPipes is the number of pipes needed
 */
void create_pipes(int pipes[][2], int numOfPipes);

/*Function Name: close_pipes
 * closes all the pipes passed
 * pipes is an array of nested size 2 int arrays to be used to close the pipes
 * numOfPipes is the number of pipes needed to be closed
 */
void close_pipes(int pipes[][2], int numOfPipes);

/*Function Name: execute_commands
 * executes all commands and makes sure that they pipe into each other correctly
 * commands hold command structs of the commands we wish to pipe together
 * numOfCmds is the number of commands we are piping together
 * pipes are the pipes we are using to accomplish this task
 * numOfPipes is the number of pipes
 */
void execute_commands(Command commands[], int numOfCmds, int pipes[][2], int numOfPipes);


/*
 * Logic
 */

void store_commands(char *cmd, Command *command) {
    char *tkn;
    command->numOfArgs = 0;
    tkn = strtok(cmd, " ");
    
    while (tkn != NULL && command->numOfArgs < MAXARGS) {
        strcpy(command->args[command->numOfArgs], tkn);
        command->numOfArgs++;
        tkn = strtok(NULL, " ");
    }
}

void read_commands(Command commands[], int sizeOfCommands, int *numOfCmds) {
    char cmd[MAXCMDLENGTH];
    int flag = 1;

    // if no command is input by the user at any time, it will unset flag
    while (flag && *numOfCmds < MAXCMDS) {
        write(1, "Please enter a command: ", 24);
        int length = read(0, cmd, MAXCMDLENGTH-1);

        if (length == 1) {
            flag = 0;
        } else if (length > 1) {
            cmd[length-1] = '\0';
            store_commands(cmd, &commands[*numOfCmds]);
            (*numOfCmds)++;
        } else {
            exit(EXIT_FAILURE);
        }
    }
}

void create_pipes(int pipes[][2], int numOfPipes) {
    for (int i=0;i<numOfPipes;i++) {
        if (pipe(pipes[i]) == -1) {
            exit(EXIT_FAILURE);
        }
    }
}

void close_pipes(int pipes[][2], int numOfPipes) {
    for (int i=0;i<numOfPipes;i++) {
        close(pipes[i][0]);
        close(pipes[i][1]);
    }
}

void execute_commands(Command commands[], int numOfCmds, int pipes[][2], int numOfPipes) {

    //array of command args will be copied to ensure null termination
    char *cpyOfArgs[MAXARGS+1];
    
    for (int curCmd=0;curCmd<numOfCmds;curCmd++) {
        pid_t pid = fork();

        if (pid == 0) {
            
            for (int j = 0; j < commands[curCmd].numOfArgs; j++) {
                cpyOfArgs[j] = commands[curCmd].args[j];
            }

            cpyOfArgs[commands[curCmd].numOfArgs] = NULL;
            
            if (curCmd > 0) {
                dup2(pipes[curCmd-1][0], STDIN_FILENO);
            }
            if (curCmd < numOfPipes) {
                dup2(pipes[curCmd][1], STDOUT_FILENO);
            }

            close_pipes(pipes, numOfPipes);
            execvp(commands[curCmd].args[0], cpyOfArgs);

            //no logic exec from this program should be occuring at this point
            exit(EXIT_FAILURE);
        }
            
        else if (pid < 0){
            exit(EXIT_FAILURE);
        }
    }

    close_pipes(pipes, numOfPipes);

    for (int curCmd=0; curCmd < numOfCmds; curCmd++) {
        wait(NULL);
    }
}

int main() {
    Command commands[MAXCMDS];
    int numOfCmds = 0;
    read_commands(commands, MAXCMDS, &numOfCmds);

    int numOfPipes = numOfCmds - 1;
    int pipes[numOfPipes][2];
    create_pipes(pipes, numOfPipes);

    execute_commands(commands, numOfCmds, pipes, numOfPipes);
}
