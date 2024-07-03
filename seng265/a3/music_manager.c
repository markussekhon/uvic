/** @file music_manager.c
 *  @brief A small program to analyze songs data.
 *  @author Mike Z.
 *  @author Felipe R.
 *  @author Hausi M.
 *  @author Jose O.
 *  @author Victoria L.
 *  @author Markus S.
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "list.h"

/**
 * @brief constants defined throughout program
 */
#define MAX_LINE_LEN 180
#define MAX_FILES 3

/**
 * @brief macros defined throughout program
 */
#define MAX(a, b) ((a) > (b) ? (a) : (b)) //max of 2 elements
#define MAX_PARSE(a, b, c, d) (MAX(MAX(a, b), MAX(c, d))) //max of 4 elements
#define INSUFFICIENT_ARGUMENTS(argc) ((argc) < 4)
#define FILE_ERROR(file) (file == NULL)

/**
 * @brief prototypes of functions
 */

void export_df_to_csv(node_t* dataframe, char *sort_by);
void snip_dataframe(node_t **dataframe, int display);
void swap(node_t *a, node_t *b);
int compare_nodes(node_t* a, node_t *b);
void sort_dataframe(node_t **head);
void manipulate_dataframe(node_t **dataframe, int display);
void remove_byte_order_marker(char **line);
void get_positions(char *line, int *pointer_pa, int *pointer_ps, int *pointer_py, int *pointer_pp, char *sort_by);
void generate_list(char *line, node_t **dataframe, int pos_artist, int pos_song, int pos_year, int pos_parameter);
void create_dataframe(node_t **dataframe, char *filenames[], int files_length, char *sort_by);
void free_dataframe(node_t *head);
void process_arguments(int argc, char *argv[], char **pointer_sort, int *pointer_display, char *filenames[], int *pointer_fl);

/**
 * @brief logic of functions
 */

/**
 * @brief Exports the dataframe to a CSV file.
 *
 * @param dataframe A pointer to the head node of the dataframe.
 * @param sort_by The parameter that was used to sort the dataframe.
 */
void export_df_to_csv(node_t* dataframe, char *sort_by)
{
    FILE *file = fopen("output.csv", "w");

    //first line of the file that describes the contents of each column
    fprintf(file,"artist,song,year,%s\n",sort_by);

    node_t *cur = dataframe;

    //adds the contents of the data frame to the appropriate column, line by line
    while(cur != NULL)
    {
        fprintf(file,"%s,%s,%d,%s\n",cur->artist,cur->song,cur->year,cur->parameter);
        cur = cur->next;
    }

    fclose(file);
}

/**
 * @brief Removes the remaining nodes of the dataframe after the first `display` nodes.
 *
 * @param dataframe A pointer to the pointer to the head node of the dataframe.
 * @param display The number of nodes to retain in the dataframe.
 */
void snip_dataframe(node_t **dataframe, int display)
{
    node_t* cur = *dataframe;
    node_t* prev = NULL;

    //find point to free in the dataframe
    for(int i = 0; i < display && cur->next != NULL; i++)
    {
        prev = cur;
        cur = cur->next;
    }

    //free everything after
    if(prev != NULL) prev->next = NULL;
    free_dataframe(cur);
}

/**
 * @brief Swaps the data of two nodes.
 *
 * @param a A pointer to the first node.
 * @param b A pointer to the second node.
 */
void swap(node_t *a, node_t *b)
{
    char *temp_artist = a->artist;
    char *temp_song = a->song;
    char *temp_parameter= a->parameter;
    int temp_year = a->year;

    a->artist = b->artist;
    a->song = b->song;
    a->parameter = b->parameter;
    a->year = b->year;

    b->artist = temp_artist;
    b->song = temp_song;
    b->parameter = temp_parameter;
    b->year = temp_year; 
}

/**
 * @brief Compares the parameter values of two nodes.
 *
 * @param a A pointer to the first node.
 * @param b A pointer to the second node.
 * @return int -1 if the parameter of `a` is less than `b`, 0 if they are equal, 1 if `a` is greater than `b`.
 */
int compare_nodes(node_t* a, node_t *b)
{
    float val_a = atof(a->parameter);
    float val_b = atof(b->parameter);

    if(val_a < val_b)
    {
        return -1;
    }
    else if (val_a == val_b)
    {
        return 0;
    }
    else //a > b
    {
        return 1;
    }
}

/**
 * @brief Sorts the dataframe using bubble sort.
 *
 * @param head A pointer to the pointer to the head node of the dataframe.
 */
void sort_dataframe(node_t **head)
{
    node_t *cur;
    node_t *last_sorted = NULL;
    int swap_status = 1;

    //terminate early if no swap performed
    while(swap_status)
    {
        swap_status = 0;
        cur = *head;

        //check if end of list, or encountering last sorted node
        while(cur->next != NULL && cur->next != last_sorted)
        {

            //check swap condition
            if(compare_nodes(cur,cur->next) < 0)
            {
                swap(cur,cur->next);
                swap_status = 1;
            }

            cur = cur->next;
        }

        last_sorted = cur;
    }
}

/**
 * @brief Sorts the dataframe and trims it based on the `display` parameter.
 *
 * @param dataframe A pointer to the pointer to the head node of the dataframe.
 * @param display The number of nodes to retain in the dataframe.
 */
void manipulate_dataframe(node_t **dataframe, int display)
{
    sort_dataframe(dataframe);

    snip_dataframe(dataframe, display);
}

/**
 * @brief Removes the byte order marker from a line of text.
 *
 * @param line A pointer to the pointer to the line of text.
 */
void remove_byte_order_marker(char **line)
{
    char bom[] = "\xEF\xBB\xBF";

    if (strncmp(*line, bom, 3) == 0)
    {
        // add 3 to move starting of line to past the BOM
        *line += 3;
    }
}

/**
 * @brief Determines the positions of various parameters in the CSV line.
 *
 * @param line A pointer to the line of text.
 * @param pointer_pa A pointer to the position of the artist parameter.
 * @param pointer_ps A pointer to the position of the song parameter.
 * @param pointer_py A pointer to the position of the year parameter.
 * @param pointer_pp A pointer to the position of the sort parameter.
 * @param sort_by The parameter to sort by.
 */
void get_positions(char *line, int *pointer_pa, int *pointer_ps, int *pointer_py, int *pointer_pp, char *sort_by)
{
    int counter = 0;

    remove_byte_order_marker(&line);

    //tokenizing, first token will be the first item will be the describer of that column
    char *token = strtok(line, ",");

    //using while loop with counter to assign index values
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

/**
 * @brief Generates a linked list from a CSV line.
 *
 * @param line A pointer to the line of text.
 * @param dataframe A pointer to the pointer to the head node of the dataframe.
 * @param pos_artist The position of the artist parameter.
 * @param pos_song The position of the song parameter.
 * @param pos_year The position of the year parameter.
 * @param pos_parameter The position of the sort parameter.
 */
void generate_list(char *line, node_t **dataframe, int pos_artist, int pos_song, int pos_year, int pos_parameter)
{
    char *cur_artist = NULL;
    char *cur_song = NULL;
    int cur_year = 0;
    char *cur_parameter = NULL;

    //tokenizes values in csv file, first token is index 0
    char *token = strtok(line, ",");

    int cur_pos = 0;

    //finding the correct index position to extract the data for this node
    while (token != NULL)
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

        token = strtok(NULL, ",");
        cur_pos++;
    }

    //adding node to the linked list in alphabetical order
    *dataframe = add_inorder(*dataframe, new_node(cur_artist, cur_song, cur_year, cur_parameter));
}

/**
 * @brief Creates a dataframe(linked list) from a CSV file.
 *
 * @param dataframe A pointer to the pointer to the head node of the dataframe.
 * @param filenames An array of filenames to process.
 * @param files_length The number of files to process.
 * @param sort_by The parameter to sort by.
 */
void create_dataframe(node_t **dataframe, char *filenames[], int files_length, char *sort_by)
{

    for (int cur_file = 0; cur_file < files_length; cur_file++)
    {

        FILE *file = fopen(filenames[cur_file], "r");
        char line[MAX_LINE_LEN];
        fgets(line, sizeof(line), file);

        //index values to locate data for each node
        int pos_artist;
        int pos_song;
        int pos_year;
        int pos_parameter;

        get_positions(line, &pos_artist, &pos_song, &pos_year, &pos_parameter, sort_by);

        while (fgets(line, sizeof(line), file) != NULL)
        {
            //use index values from header line, to create nodes in a linked list
            generate_list(line, dataframe, pos_artist, pos_song, pos_year, pos_parameter);
        }

        fclose(file);
    }
}

/**
 * @brief Frees the memory allocated for the dataframe.
 *
 * @param head A pointer to the head node of the dataframe.
 */
void free_dataframe(node_t *head)
{

    while (head != NULL)
    {
        node_t *temp = head->next;

        free(head->artist);
        free(head->song);
        free(head->parameter);
        free(head);

        //next node to free
        head = temp;
    }

}

/**
 * @brief Processes the command-line arguments.
 *
 * @param argc The number of arguments.
 * @param argv The list of arguments.
 * @param pointer_sort A pointer to the sort parameter.
 * @param pointer_display A pointer to the display parameter.
 * @param filenames An array of filenames to process.
 * @param pointer_fl A pointer to the number of files to process.
 */
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

    //how many files
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
    node_t *dataframe = NULL;
    int files_length;
    char *filenames[MAX_FILES];

    process_arguments(argc, argv, &sort_by, &display, filenames, &files_length);

    create_dataframe(&dataframe, filenames, files_length, sort_by);

    manipulate_dataframe(&dataframe,display);

    export_df_to_csv(dataframe, sort_by);

    free_dataframe(dataframe);

    exit(0);
}
