/** @file event_manager.c
 *  @brief A pipes & filters program that uses conditionals, loops, and string processing tools in C to process iCalendar
 *  events and printing them in a user-friendly format.
 *  @author Felipe R.
 *  @author Hausi M.
 *  @author Jose O.
 *  @author Victoria L.
 *  @author Markus S.
 */

#define _XOPEN_SOURCE 700
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/**
 * @brief constants defined throughout program
 */
#define MAX_LINE_LEN 132
#define START_DATE_ARGUMENT "--start="
#define START_DATE_OFFSET 8
#define END_DATE_ARGUMENT "--end="
#define END_DATE_OFFSET 6
#define FILENAME_ARGUMENT "--file="
#define FILENAME_OFFSET 7
#define YEAR_MOD 10000
#define MONTH_MOD 100

/**
 * @brief structure template of Event
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

/**
 * @brief prototypes of functions
 */
void processArguments(int argc, char *argv[], int *startPointer, int *endPointer, char **filePointer);
void readEvents(char* fileName, Event *events, int *eventCountPointer);
void addEvents(char *line, FILE *file, Event *events,int *eventCountPointer);
void createDateEvent(char *linePointer,Event *events,int *eventCountPointer, int c);
void createRepeatEvents(int* eventCountPointer, Event *events);
void printEvents(Event *events, int *eventCountPointer, int *startDatePointer, int *endDatePointer);
void printDayHeader(int startDate);
void printEventInformation(Event event);

const char* monthName(int month);

/**
 * Function: main
 * --------------
 * @brief The main function and entry point of the program.
 *
 * @param argc The number of arguments passed to the program.
 * @param argv The list of arguments passed to the program.
 * @return int 0: No errors; 1: Errors produced.
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

   readEvents(fileName, events, eventCountPointer);

   printEvents(events, eventCountPointer, startDatePointer, endDatePointer);

}

/**
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

        //either we update start date, end date, or filePointer
        if (charStartPointer != NULL)
        {
            sscanf(charStartPointer + START_DATE_OFFSET, "%d/%d/%d", &year, &month, &day);
            *startPointer = year * YEAR_MOD + month * MONTH_MOD + day;
        }
        else if (charEndPointer != NULL)
        {
            sscanf(charEndPointer + END_DATE_OFFSET, "%d/%d/%d", &year, &month, &day);
            *endPointer = year * YEAR_MOD + month * MONTH_MOD + day;
        }
        else if (charFilePointer != NULL)
        {
            *filePointer = charFilePointer + FILENAME_OFFSET;
        }
    }
}

/**
 * Function: readEvents
 * --------------
 * @brief reads the cli file, and loop to find when to create events
 *
 * @param fileName fileName passed on command line
 * @param events list of events
 * @param eventCountPointer points to counter of events in list
 * 
 * @return void
 */
void readEvents(char* fileName, Event *events, int *eventCountPointer)
{
    FILE *file = fopen(fileName, "r");
    char line[MAX_LINE_LEN];
    char* linePointer;

    //keep moving line by line in file
    while(fgets(line,sizeof(line), file))
    {
        line[strcspn(line, "\n")] = 0;

        // finding next event to create
        if (strcmp(line, "BEGIN:VEVENT") == 0)
        {
            addEvents(line,file,events,eventCountPointer);
        }
    }

    fclose(file);
}

/**
 * Function: addEvents
 * --------------
 * @brief adds events to the event array
 *
 * @param line current line
 * @param file to read next line from
 * @param events list of events
 * @param eventCountPointer points to counter of events in list
 * 
 * @return void
 */
void addEvents(char *line, FILE *file, Event *events,int *eventCountPointer)
{
    char* linePointer;

    //moving to next line (while there are still lines)
    while(fgets(line,MAX_LINE_LEN, file))
    {
                line[strcspn(line, "\n")] = 0;

                // check which case to go into, cases explain what they do
                if ((strcmp(line,"END:VEVENT")) == 0)
                {
                    *eventCountPointer+=1;
                    break;
                }
                else if ((linePointer = strstr(line, "DTSTART:"))!=NULL)
                {
                    createDateEvent(linePointer, events, eventCountPointer, 0);
                }
                else if((linePointer = strstr(line, "DTEND:"))!=NULL)
                {
                    createDateEvent(linePointer, events, eventCountPointer, 1);
                }
                else if((linePointer = strstr(line, "LOCATION:"))!=NULL)
                {
                    strcpy(events[*eventCountPointer].location, linePointer + strlen("LOCATION:"));

                }
                else if((linePointer = strstr(line, "SUMMARY:"))!=NULL)
                {
                    strcpy(events[*eventCountPointer].summary, linePointer + strlen("SUMMARY:"));
                    createRepeatEvents(eventCountPointer, events);
                }
                else if((linePointer = strstr(line, "RRULE:"))!=NULL)
                {
                    strcpy(events[*eventCountPointer].rrule, linePointer);  
                }
    }
}

/**
 * Function: createDateEvent
 * --------------
 * @brief adds date events
 *
 * @param linePointer which line to read from
 * @param events list of events
 * @param eventCountPointer points to counter of events in list
 * @param dateType checks if start or end date
 * 
 * @return void
 */
void createDateEvent(char *linePointer,Event *events,int *eventCountPointer, int dateType)
{
    char* token;
    char* lineCopy = strdup(linePointer);

    //splitting lineCopy into tokens and the tokens are being seperated into relevant info
    token = strtok(lineCopy, ":");

    //token holds the date in char st YYYYMMDD
    token = strtok(NULL, "T");

    if(dateType==1)
    {
        events[*eventCountPointer].endDate = atoi(token);
    }
    else{
        events[*eventCountPointer].startDate = atoi(token);
    }
    
    //now token holds the date in char format
    token = strtok(NULL, "\0");

    if(dateType==1){
        events[*eventCountPointer].endTime = atoi(token);
    }else{
        events[*eventCountPointer].startTime = atoi(token);
    }

}

/**
 * Function: createRepeatEvent
 * --------------
 * @brief creates repeat events following template
 *
 * @param eventCountPointer points to counter of events in list
 * @param events list of events
 * 
 * @return void
 */
void createRepeatEvents(int* eventCountPointer, Event *events)
{
    char* token;
    char* lineCopy = strdup(events[*eventCountPointer].rrule);
    char filters[] = ";=";
    int ruleEndDate;

    token = strtok(lineCopy, filters);

    //finding till what date to create repeat events
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

    //copying events from template event and adjusting startdate by 7 each time
    for(int j=events[*eventCountPointer].startDate+7;j<=ruleEndDate;j+=7)
    {
        events[*eventCountPointer+i].startDate = j;
        events[*eventCountPointer+i].endDate = j;
        events[*eventCountPointer+i].startTime = events[*eventCountPointer].startTime;
        events[*eventCountPointer+i].endTime = events[*eventCountPointer].endTime;
        strcpy(events[*eventCountPointer+i].location,events[*eventCountPointer].location);
        strcpy(events[*eventCountPointer+i].summary,events[*eventCountPointer].summary);
        i++;
    }

    //update total event count with number events added
    *eventCountPointer += i;

}

/**
 * Function: printEvents
 * --------------
 * @brief holds logic to print all events that are necessary
 *
 * @param events points to the list of events
 * @param eventCountPointer points to counter of events in list
 * @param startDatePointer  points to the start date of filter
 * @param endDatePointer points to the end date of filter
 * 
 * @return void
 */
void printEvents(Event *events, int *eventCountPointer, int *startDatePointer, int *endDatePointer)
{
    int previousDay = -1;
    int daysPrinted = 0;

    //end case is checking all events added
    for(int i = 0; i < *eventCountPointer; i++)
    {
        // if the event's dates are within the filter spec
        if(events[i].startDate >= *startDatePointer && events[i].startDate <= *endDatePointer)
        {
            //check to see if a header is neaded or if already there
            if(events[i].startDate != previousDay)
            {
                if(daysPrinted>0)
                {
                    printf("\n");
                    daysPrinted++;
                }
                printDayHeader(events[i].startDate);
                daysPrinted++;
            }

            printEventInformation(events[i]);

            //reference to see if a new header is needed
            previousDay = events[i].startDate;
        }
    }
}

/**
 * Function: printDayHeader
 * --------------
 * @brief prints the header
 *
 * @param startDate what date to display
 * 
 * @return void
 */
void printDayHeader(int startDate)
{
    int startYear = startDate / YEAR_MOD;
    int startMonth = (startDate % YEAR_MOD) / MONTH_MOD;
    int startDay = startDate % MONTH_MOD;
    char dateString[MAX_LINE_LEN];

    //prints the date and creates it as a string to check how many - to print
    sprintf(dateString,"%s %02d, %d\n", monthName(startMonth), startDay, startYear);
    printf("%s", dateString);

    //prints necessary # of dashes
    for(int j=0; j<strlen(dateString)-1;j++)
    {
        printf("-");
    }
    printf("\n");
}

/**
 * Function: printEventInformation
 * --------------
 * @brief prints the event information
 *
 * @param event what event to display
 * 
 * @return void
 */
void printEventInformation(Event event)
{
    // gets the information from the event
    int startYear = event.startDate / YEAR_MOD;
    int startMonth = (event.startDate % YEAR_MOD) / MONTH_MOD;
    int startDay = event.startDate % MONTH_MOD;
    int endYear = event.endDate / YEAR_MOD;
    int endMonth = (event.endDate % YEAR_MOD) / MONTH_MOD;
    int endDay = event.endDate % MONTH_MOD;
    int startHour = event.startTime / YEAR_MOD;
    int startMin = (event.startTime % YEAR_MOD) / MONTH_MOD;
    int endHour = event.endTime / YEAR_MOD;
    int endMin = (event.endTime % YEAR_MOD) / MONTH_MOD;

    //AM or PM
    char *startAMPM = startHour >= 12 ? "PM" : "AM" ;
    char *endAMPM = endHour >= 12 ? "PM" : "AM";

    //conversion to 12 hour clock
    startHour = startHour > 12 ? startHour - 12 : startHour;
    endHour = endHour > 12 ? endHour - 12 : endHour;

    //correctly formated information of event
    printf("%2d:%02d %s to %2d:%02d %s: %s {{%s}}\n",startHour, startMin, startAMPM, endHour, endMin, endAMPM, event.summary, event.location);
}

/**
 * Function: monthName
 * --------------
 * @brief returns what month to print
 *
 * @param month what event to display
 * 
 * @return const char* (month to display)
 */
const char* monthName(int month)
{
    const char *name[] = {"Invalid","January","February","March","April","May","June","July","August","September","October","November","December"};

    return (month >=1 && month <=12) ? name[month] : name[0];
}