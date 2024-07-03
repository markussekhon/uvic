/** @file event_manager.c
 *  @brief A pipes & filters program that uses conditionals, loops, and string processing tools in C to process iCalendar
 *  events and printing them in a user-friendly format.
 *  @author Felipe R.
 *  @author Hausi M.
 *  @author Jose O.
 *  @author Victoria L.
 *  @author Markus S.
 *
 *
 */

#define _XOPEN_SOURCE 700
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/**
 * @brief The maximum line length.
 *
 */
#define MAX_LINE_LEN 132
#define START_DATE_ARGUMENT "--start="
#define START_DATE_OFFSET 8
#define END_DATE_ARGUMENT "--end="
#define END_DATE_OFFSET 6
#define FILENAME_ARGUMENT "--file="
#define FILENAME_OFFSET 7

/*
 * structure of events
 */
typedef struct {
    int startDate;
    int endDate;
    int startTime;
    int endTime;
    char location[MAX_LINE_LEN];
    char summary[MAX_LINE_LEN];
    char rrule[MAX_LINE_LEN];
} Event;

/*
 * prototypes
 */
void processArguments(int argc, char *argv[], int *startPointer, int *endPointer, char **filePointer);
void readEvents();
void createRepeatEvents(char *linePointer, int* eventCountPointer);
void printEvents();
const char* monthName(int month);

/**
 * Function: main
 * --------------
 * @brief The main function and entry point of the program.
 *
 * @param argc The number of arguments passed to the program.
 * @param argv The list of arguments passed to the program.
 * @return int 0: No errors; 1: Errors produced.
 *
 */
int main(int argc, char *argv[])
{
    int startDate = 0;
    int endDate = 0;
    int eventCount = 0;
    char *fileName;
    Event events[100];

    int *startDatePointer = &startDate;
    int *endDatePointer = &endDate;
    int *eventCountPointer = &eventCount;
    char **fileNamePointer = &fileName;

   processArguments(argc, argv, startDatePointer, endDatePointer, fileNamePointer);

   readEvents();

   printEvents();

}

/*
 * Function: processArguments
 * --------------
 * @brief finds the start and end dates to filter the cli file by
 *
 * @param argc The number of arguments passed to the program.
 * @param argv The list of arguments passed to the program.
 * @param startPointer points to int startdate
 * @param endPointer points to int enddate
 * @param filePointer points to char fileName
 * 
 * @return void
 *
 * 
 */
void processArguments(int argc, char *argv[], int *startPointer, int *endPointer, char **filePointer)
{
    for(int i=1;i<argc;i++)
    {
        //using pointers to reference start/end points for dates
        char *charStartPointer = strstr(argv[i], START_DATE_ARGUMENT);
        char *charEndPointer = strstr(argv[i], END_DATE_ARGUMENT);
        char *charFilePointer = strstr(argv[i], FILENAME_ARGUMENT);

        int year, month, day;

        //updating the start and end dates
        if (charStartPointer != NULL)
        {
            sscanf(charStartPointer + START_DATE_OFFSET, "%d/%d/%d", &year, &month, &day);
            *startPointer = year * 10000 + month * 100 + day;
        }
        else if (charEndPointer != NULL)
        {
            sscanf(charEndPointer + END_DATE_OFFSET, "%d/%d/%d", &year, &month, &day);
            *endPointer = year * 10000 + month * 100 + day;
        }
        else if (charFilePointer != NULL)
        {
            *filePointer = charFilePointer + FILENAME_OFFSET;
        }
    }
}

/*
 *
 */
void readEvents(char* fileName, Event events, int* eventCountPointer)
{
    FILE *file = fopen(fileName, "r");

    char line[MAX_LINE_LEN];


    while(fgets(line,sizeof(line), file))
    {
        line[strcspn(line, "\n")] = 0;

        if (strcmp(line, "BEGIN:VEVENT") == 0)
        {
            while(fgets(line,sizeof(line), file))
            {
                line[strcspn(line, "\n")] = 0;
                char* linePointer;

                if ((strcmp(line,"END:VEVENT")) == 0)
                {
                    *eventCountPointer++;
                    break;
                }

                else if ((linePointer = strstr(line, "DTSTART:"))!=NULL){
                    char* token;
                    char* lineCopy = strdup(linePointer);

                    token = strtok(lineCopy, ":");
                    token = strtok(NULL, "T");
                    events[*eventCountPointer].startDate = atoi(token);
                    token = strtok(NULL, "\0");
                    events[*eventCountPointer].startTime = atoi(token);
                    free(lineCopy);
                }
                else if((linePointer = strstr(line, "DTEND:"))!=NULL)
                {
                    char* token;
                    char* lineCopy = strdup(linePointer);

                    token = strtok(lineCopy, ":");
                    token = strtok(NULL, "T");
                    events[*eventCountPointer].endDate = atoi(token);
                    token = strtok(NULL, "\0");
                    events[*eventCountPointer].endTime = atoi(token);
                    free(lineCopy);
                }
                else if((linePointer = strstr(line, "LOCATION:"))!=NULL)
                {
                    strcpy(events[*eventCountPointer].location, linePointer + strlen("LOCATION:"));
                }
                else if((linePointer = strstr(line, "SUMMARY:"))!=NULL)
                {
                    strcpy(events[*eventCountPointer].summary, linePointer + strlen("SUMMARY:"));

                    char* token;
                    char* lineCopy = strdup(events[*eventCountPointer].rrule);
                    char filters[] = ";=";
                    int ruleEndDate;

                    token = strtok(lineCopy, filters);

                    while(token!=NULL)
                    {
                        if (strcmp(token, "UNTIL") == 0)
                        {
                            token = strtok(NULL,";T");
                            sscanf(token, "%d", &ruleEndDate);
                            break;
                        }
                        token = strtok(NULL, ";=");
                    }

                    int i = 1;

                    for(int j=events[eventCount].startDate+7;j<=ruleEndDate;j+=7)
                    {
                        events[eventCount+i].startDate = j;
                        events[eventCount+i].endDate = j;
                        events[eventCount+i].startTime = events[eventCount].startTime;
                        events[eventCount+i].endTime = events[eventCount].endTime;
                        strcpy(events[eventCount+i].location,events[eventCount].location);
                        strcpy(events[eventCount+i].summary,events[eventCount].summary);
                        i++;
                    }
                    eventCount += i;

                    free(lineCopy);

                }
                else if((linePointer = strstr(line, "RRULE:"))!=NULL)
                {
                    strcpy(events[eventCount].rrule, linePointer);
                    
                }

            }
        }

    }

    fclose(file);
}

void createRepeatEvents(char *linePointer, int* eventCountPointer)
{
    char* token;
    char* lineCopy = strdup(linePointer);

    token = strtok(lineCopy, "UNTIL=");
    token = strtok(NULL, "T");
    
    int ruleEndDate = atoi(token);
    int i = 1;

    for(int j=events[*eventCountPointer].startDate+700;j<=ruleEndDate;j+=700)
    {
        events[*eventCountPointer+i].startDate = j;
        events[*eventCountPointer+i].endDate = j;
        events[*eventCountPointer+i].startTime = events[*eventCountPointer].startTime;
        events[*eventCountPointer+i].endTime = events[*eventCountPointer].endTime;
        strcpy(events[*eventCountPointer+i].location,events[*eventCountPointer].location);
        strcpy(events[*eventCountPointer+i].summary,events[*eventCountPointer].summary);
        i++;
        printf("penor");
    }
    *eventCountPointer += i;

    free(lineCopy);
}

void printEvents()
{
    int previousDay = -1;
    int daysPrinted = 0;

    for(int i = 0; i < eventCount; i++)
    {

        if(events[i].startDate >= *startDatePointer && events[i].startDate <= *endDatePointer)
        {
            

            int startYear = events[i].startDate / 10000;
            int startMonth = (events[i].startDate % 10000) / 100;
            int startDay = events[i].startDate % 100;
            int endYear = events[i].endDate / 10000;
            int endMonth = (events[i].endDate % 10000) / 100;
            int endDay = events[i].endDate % 100;

            int startHour = events[i].startTime / 10000;
            int startMin = (events[i].startTime % 10000) / 100;
            int endHour = events[i].endTime / 10000;
            int endMin = (events[i].endTime % 10000) / 100;

            char *startAMPM = startHour >= 12 ? "PM" : "AM" ;
            char *endAMPM = endHour >= 12 ? "PM" : "AM";

            startHour = startHour > 12 ? startHour - 12 : startHour;
            endHour = endHour > 12 ? endHour - 12 : endHour;

            if(events[i].startDate != previousDay)
            {
                if(daysPrinted>0){
                    printf("\n");
                    daysPrinted++;
                }
                char dateString[MAX_LINE_LEN];
                sprintf(dateString,"%s %02d, %d\n", monthName(startMonth), startDay, startYear);
                printf("%s", dateString);

                for(int j=0; j<strlen(dateString)-1;j++)
                {
                    printf("-");
                }
                printf("\n");
                daysPrinted++;
            }

            

            if (eventCount == i+1 || previousDay==events[i].startDate)
            {
                printf("%2d:%02d %s to %2d:%02d %s: %s {{%s}}\n",startHour, startMin, startAMPM, endHour, endMin, endAMPM, events[i].summary, events[i].location);
            }
            else
            {
                printf("%2d:%02d %s to %2d:%02d %s: %s {{%s}}\n",startHour, startMin, startAMPM, endHour, endMin, endAMPM, events[i].summary, events[i].location);
            }

            previousDay = events[i].startDate;

        }

    }
}

const char* monthName(int month)
{
    const char *name[] = {"Invalid","January","February","March","April","May","June","July","August","September","October","November","December"};

    return (month >=1 && month <=12) ? name[month] : name[0];
}
