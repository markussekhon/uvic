 /* getstats.c 
 * CSC 360, Spring 2024
 *
 * - If run without an argument, prints information about 
 *   the computer to stdout.
 *
 * - If run with a process number created by the current user, 
 *   prints information about that process to stdout.
 *
 * Author: Markus Sekhon
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>


/*
 * Constants
 */

#define MAXLINELENGTH 255

#define SECDAYS 86400
#define SECHOURS 3600
#define SECMINUTES 60

#define PROCESSPATH "/proc/"

#define PNAMEPATH "/comm"
#define PNAMENEEDLE ""

#define PCMDLINEPATH "/cmdline"
#define PCMDLINENEEDLE ""

#define PSTATUSPATH "/status"
#define THREADSNEEDLE "Threads"
#define VOLSWITCHESNEEDLE "voluntary_ctxt_switches"
#define NONVOLSWITCHESNEEDLE "nonvoluntary_ctxt_switches"

#define VERSIONPATH "/proc/version"
#define VERSIONNEEDLE ""

#define MEMORYPATH "/proc/meminfo"
#define MEMORYNEEDLE "MemTotal"

#define CPUINFOPATH "/proc/cpuinfo"
#define MODELNEEDLE "model name"
#define CORESNEEDLE "cpu cores"

#define UPTIMEPATH "/proc/uptime"
#define UPTIMENEEDLE ""

/*
 * Prototypes
 */

/*Function Name: extract_file
 * Reads a file and searches for the needle in the haystack, saves result in result
 * filename is the path to the file
 * needle is a marker for the information specificly sought out
 * result is where the found line is stored
 */
void extract_file(char filename[MAXLINELENGTH], char* needle, char *result);

/*Function Name: print_status
 * Prints thread count and num of context switches
 * path is the path to the current process youre trying to find this information from
 */
void print_status(char *path);

/*Function Name: print_cmdline
 * Prints the commandline arguement that started the process
 * path is the path to the current process youre trying to find this information from
 */
void print_cmdline(char *path);

/*Function Name: print_name
 * Prints the name of the current process
 * path is the path to the current process youre trying to find this information from
 */
void print_name(char *path);

/*Function Name: print_date
 * converts and prints time in seconds to days, hours, minutes, and seconds
 * uptime is the time in seconds
 */
void print_date(double uptime);

/*Function Name: print_uptime
 * finds systems uptime and prints it
 */
void print_uptime();

/*Function Name: print_version
 * prints the the linux kernel version
 */
void print_version();

/*Function Name: print_memory
 * prints the total system memory
 */
void print_memory();

/*Function Name: print_cpu_info
 * prints the cpu model name and number of cores
 */
void print_cpu_info();

/*Function Name:
 * prints detailed information about the current process running
 * process_num is the pid of the process that we are printing information out about
 */
void print_process_info(char * process_num);

/*Function Name:
 * prints a summary of system information (cpu, os, memory, and uptime info)
 */
void print_full_info();


/*
 * Logic
 */


void extract_file(char filename[MAXLINELENGTH], char* needle, char *result) {
    FILE *fptr;
    char line[MAXLINELENGTH];
    int found = 0;
    
    fptr = fopen(filename , "r");

    if (fptr == NULL) {
        printf("error with %s\n", filename);
        exit(EXIT_FAILURE);
    }

    while(!found && fgets(line, MAXLINELENGTH, fptr)){
        if (!found && strncmp(line, needle, strlen(needle)) == 0){
            strcpy(result, line);
            found = 1;
        }
    }
    
    fclose(fptr);
}

void print_status(char *path) {
    char filepath[MAXLINELENGTH], result[MAXLINELENGTH];
    char volNeedle[MAXLINELENGTH], nonvolNeedle[MAXLINELENGTH];
    int vol, nonvol, total;
    
    strcpy(filepath, path);
    strcat(filepath, PSTATUSPATH);

    extract_file(filepath, THREADSNEEDLE, result);
    printf("%s", result);

    extract_file(filepath, VOLSWITCHESNEEDLE, result);
    strcpy(volNeedle, VOLSWITCHESNEEDLE);
    strcat(volNeedle, ": %d");
    sscanf(result, volNeedle, &vol);
    
    extract_file(filepath, NONVOLSWITCHESNEEDLE, result);
    strcpy(nonvolNeedle, NONVOLSWITCHESNEEDLE);
    strcat(nonvolNeedle, ": %d");
    sscanf(result, nonvolNeedle, &nonvol);

    total = vol + nonvol;
    printf("Total context switches: %d\n", total);
}

void print_cmdline(char *path) {
    char filepath[MAXLINELENGTH], result[MAXLINELENGTH];
    
    strcpy(filepath, path);
    strcat(filepath, PCMDLINEPATH);

    extract_file(filepath, PCMDLINENEEDLE, result);
    printf("Cmdline: %s\n", result);
}

void print_name(char *path) {
    char filepath[MAXLINELENGTH], result[MAXLINELENGTH];
    
    strcpy(filepath, path);
    strcat(filepath, PNAMEPATH);

    extract_file(filepath, PNAMENEEDLE, result);
    printf("Name: %s", result);
}

void print_date(double uptime) {
    int days = uptime / SECDAYS;
    uptime = uptime - (days * SECDAYS);

    int hours = uptime / SECHOURS;
    uptime = uptime - (hours * SECHOURS);
    
    int minutes = uptime / SECMINUTES;
    uptime = uptime - (minutes * SECMINUTES);
    
    int seconds = uptime;

    printf("Uptime: %d days, %d hours, %d minutes, %d seconds\n", days, hours , minutes, seconds);
}

void print_uptime() {
    char line[MAXLINELENGTH];
    double uptime;
    extract_file(UPTIMEPATH, UPTIMENEEDLE, line);
    sscanf(line, "%lf" , &uptime);
    print_date(uptime);
}

void print_version() {
    char line[MAXLINELENGTH];
    extract_file(VERSIONPATH, VERSIONNEEDLE, line);
    printf("%s", line);
}

void print_memory() {
    char line[MAXLINELENGTH];
    extract_file(MEMORYPATH, MEMORYNEEDLE, line);
    printf("%s", line);
}

void print_cpu_info() {
    char result[MAXLINELENGTH];
    extract_file(CPUINFOPATH, MODELNEEDLE, result);
    printf("%s", result);
    extract_file(CPUINFOPATH, CORESNEEDLE, result);
    printf("%s", result);
}

void print_process_info(char * process_num) {
    char path[MAXLINELENGTH];
    
    strcpy(path, PROCESSPATH);
    strcat(path, process_num);

    DIR *dir = opendir(path);

    if (dir) {
        closedir(dir);
        printf("Process number: %s\n", process_num);
        print_name(path);
        print_cmdline(path);
        print_status(path);
    } else {
        printf("Process number %s not found.\n", process_num);
        exit(EXIT_FAILURE);
    }
}

void print_full_info() {
    print_cpu_info();
    print_version();
    print_memory();
    print_uptime();
}


int main(int argc, char ** argv) {  
    if (argc == 1) {
        print_full_info();
    } else {
        print_process_info(argv[1]);
    }
    return 0;
}
