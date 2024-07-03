/** @file music_manager.c
 *  @brief A small program to analyze songs data.
 *  @author Mike Z.
 *  @author Felipe R.
 *  @author Hausi M.
 *  @author Jose O.
 *  @author Victoria L.
 *  @author STUDENT_NAME
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "list.h"

#define MAX_LINE_LEN 180
#define MAX_FILES 3

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MAX_PARSE(a, b, c, d) (MAX(MAX(a, b), MAX(c, d)))
#define INSUFFICIENT_ARGUMENTS(argc) ((argc) < 4)

/**
 * @brief Serves as an incremental counter for navigating the list.
 *
 * @param p The pointer of the node to print.
 * @param arg The pointer of the index.
 *
 */
void inccounter(node_t *p, void *arg)
{
    int *ip = (int *)arg;
    (*ip)++;
}

/**
 * @brief Allows to print out the content of a node.
 *
 * @param p The pointer of the node to print.
 * @param arg The format of the string.
 *
 */
void print_node(node_t *p, void *arg)
{
    char *fmt = (char *)arg;
    printf(fmt, p->artist);
    printf(fmt, p->song);
    printf(fmt, p->parameter);
    // need to add year
}

/**
 * @brief Allows to print each node in the list.
 *
 * @param l The first node in the list
 *
 */
void analysis(node_t *l)
{
    int len = 0;

    apply(l, inccounter, &len);
    printf("Number of words: %d\n", len);

    apply(l, print_node, "%s\n");
}

void snip_dataframe(node_t *files[], int cur, int display)
{

}

void sort_dataframe(node_t *files[], int cur, char *sort_by)
{

}

void manipulate_dataframes(node_t *files[], int files_length, char *sort_by, int display)
{
    for(int i = 0; i < files_length; i++)
    {
        //sort

        //snip
    }
}

void get_positions(char *line, int *pointer_pa, int *pointer_ps, int *pointer_py, int *pointer_pp, char *sort_by)
{
    int counter = 0;

    char *token = strtok(line, ",");

    while (token != NULL)
    {

        if (strcmp(token, "artist") == 0)
        {
            *pointer_pa = counter;
        }
        else if (strcmp(token, "song") == 0)
        {
            *pointer_ps = counter;
        }
        else if (strcmp(token, "year") == 0)
        {
            *pointer_py = counter;
        }
        else if (strcmp(token, sort_by) == 0)
        {
            *pointer_pp = counter;
        }

        token = strtok(NULL, ",");
        counter++;
    }
}

void generate_list(char *line, node_t *files[], int cur_file, int pos_artist, int pos_song, int pos_year, int pos_parameter)
{
    char *cur_artist;
    char *cur_song;
    int cur_year;
    char *cur_parameter;

    char *token = strtok(line, ",");

    int cur_pos = 0;
    int furthest_pos = MAX_PARSE(pos_artist, pos_song, pos_year, pos_parameter);

    while (token != NULL && cur_pos <= furthest_pos)
    {

        if (cur_pos == pos_artist)
        {
            cur_artist = token;
        }
        else if (cur_pos == pos_song)
        {
            cur_song = token;
        }
        else if (cur_pos == pos_year)
        {
            cur_year = atoi(token);
        }
        else if (cur_pos == pos_parameter)
        {
            cur_parameter = token;
        }

        token = strtok(line, ",");
        cur_pos++;
    }

    files[cur_file] = add_inorder(files[cur_file], new_node(cur_artist, cur_song, cur_year, cur_parameter));
}

void create_dataframes(node_t *files[], char *filenames[], int files_length, char *sort_by)
{

    for (int cur_file = 0; cur_file < files_length; cur_file++)
    {
        FILE *file = fopen(filenames[cur_file], "r");
        char line[MAX_LINE_LEN];
        fgets(line, sizeof(line), file);

        int pos_artist;
        int pos_song;
        int pos_year;
        int pos_parameter;

        get_positions(line, &pos_artist, &pos_song, &pos_year, &pos_parameter, sort_by);

        while (fgets(line, sizeof(line), file) != NULL)
        {
            generate_list(line, files, cur_file, pos_artist, pos_song, pos_year, pos_parameter);
        }

        fclose(file);
    }
}

void free_list(node_t *head)
{

    while (head != NULL)
    {
        node_t *temp = head->next;

        free(head->artist);
        free(head->song);
        free(head->parameter);
        free(head);

        head = temp;
    }
}

void free_files(node_t *files[], int files_length)
{
    node_t *head;
    for (int i = 0; i < files_length; i++)
    {
        head = files[i];
        free_list(head);
    }
}

void process_arguments(int argc, char *argv[], char **pointer_sort, int *pointer_display, char *filenames[], int *pointer_fl)
{
    if (INSUFFICIENT_ARGUMENTS(argc))
    {
        printf("Not enough arguments passed.");
        exit(1);
    }

    // process sort
    char *token = strtok(argv[1], "=");
    token = strtok(NULL, "=");
    *pointer_sort = token;

    // process display
    token = strtok(argv[2], "=");
    token = strtok(NULL, "=");
    *pointer_display = atoi(token);

    // process files
    token = strtok(argv[3], "=");
    token = strtok(NULL, "=");
    char *cur_file = strtok(token, ",");

    int i = 0;
    while (cur_file != NULL && i < MAX_FILES)
    {
        filenames[i++] = cur_file;
        cur_file = strtok(NULL, ",");
    }

    *pointer_fl = i;
}

/**
 * @brief The main function and entry point of the program.
 *
 * @param argc The number of arguments passed to the program.
 * @param argv The list of arguments passed to the program.
 * @return int 0: No errors; 1: Errors produced.
 *
 */
int main(int argc, char *argv[])
{
    // variables
    char *sort_by;
    int display;
    int files_length;
    char *filenames[MAX_FILES];

    process_arguments(argc, argv, &sort_by, &display, filenames, &files_length);

    node_t *files[files_length];

    // create dataframes
    create_dataframes(files, filenames, files_length, sort_by);

    //combine dataframes

    // sort dataframes and cut length

    // export dataframes

    // free lists
    free_files(files, files_length);

    printf("SortBy: %s\n", sort_by);
    printf("Display: %d\n", display);
    printf("Num of Files: %d\n", files_length);
    for (int i = 0; i < files_length; i++)
    {
        printf("File %d: %s\n", i, filenames[i]);
    }

    exit(0);
}
