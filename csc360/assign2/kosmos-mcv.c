/*
 * kosmos-mcv.c (mutexes & condition variables)
 *
 * For UVic CSC 360, Spring 2024
 *
 * Here is some code from which to start.
 *
 * PLEASE FOLLOW THE INSTRUCTIONS REGARDING WHERE YOU ARE PERMITTED
 * TO ADD OR CHANGE THIS CODE. Read from line 133 onwards for
 * this information.
 */

#include <assert.h>
#include <pthread.h>
#include <semaphore.h>
#include <sched.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "logging.h"


/* Random # below threshold that particular atom creation. 
 * This code is a bit fragile as it depends upon knowledge
 * of the ordering of the labels.  For now, the labels 
 * are in alphabetical order, which also matches the values
 * of the thresholds.
 */

#define C_THRESHOLD 0.2
#define H_THRESHOLD 0.8
#define O_THRESHOLD 1.0
#define DEFAULT_NUM_ATOMS 40

#define MAX_ATOM_NAME_LEN 10
#define MAX_KOSMOS_SECONDS 5

/* Global / shared variables */
int  cNum = 0, hNum = 0, oNum = 0;
long numAtoms;


/* Function prototypes */
void kosmos_init(void);
void *c_ready(void *);
void *h_ready(void *);
void *o_ready(void *);
void make_radical(int, int, int, int, int, char *);
void wait_to_terminate(int);


/* Needed to pass legit copy of an integer argument to a pthread */
int *dupInt( int i )
{
	int *pi = (int *)malloc(sizeof(int));
	assert( pi != NULL);
	*pi = i;
	return pi;
}




int main(int argc, char *argv[])
{
	long seed;
	numAtoms = DEFAULT_NUM_ATOMS;
	pthread_t **atom;
	int i;
	int status;
    double random_value;

	if ( argc < 2 ) {
		fprintf(stderr, "usage: %s <seed> [<num atoms>]\n", argv[0]);
		exit(1);
	}

	if ( argc >= 2) {
		seed = atoi(argv[1]);
	}

	if (argc == 3) {
		numAtoms = atoi(argv[2]);
		if (numAtoms < 0) {
			fprintf(stderr, "%ld is not a valid number of atoms\n",
				numAtoms);
			exit(1);
		}
	}

    kosmos_log_init();
	kosmos_init();

	srand(seed);
	atom = (pthread_t **)malloc(numAtoms * sizeof(pthread_t *));
	assert (atom != NULL);
	for (i = 0; i < numAtoms; i++) {
		atom[i] = (pthread_t *)malloc(sizeof(pthread_t));
        random_value = (double)rand() / (double)RAND_MAX;

		if ( random_value <= C_THRESHOLD ) {
			cNum++;
			status = pthread_create (
					atom[i], NULL, c_ready,
					(void *)dupInt(cNum)
				);
		} else if (random_value <= H_THRESHOLD ) {
			hNum++;
			status = pthread_create (
					atom[i], NULL, h_ready,
					(void *)dupInt(hNum)
				);
		} else if (random_value <= O_THRESHOLD) {
			oNum++;
			status = pthread_create (
					atom[i], NULL, o_ready,
					(void *)dupInt(oNum)
				);
        } else {
            fprintf(stderr, "SOMETHING HORRIBLY WRONG WITH ATOM GENERATION\n");
            exit(1);
        } 

		if (status != 0) {
			fprintf(stderr, "Error creating atom thread\n");
			exit(1);
		}
	}

    /* Determining the maximum number of ethynyl radicals is fairly
     * straightforward -- it will be the minimum of the number of
     * cNum, oNum, and hNum / 3.
     */
    int max_radicals = 0;

    if (cNum < oNum && cNum < hNum / 3) {
        max_radicals = cNum;
    } else if (oNum < cNum && oNum < hNum / 3) {
        max_radicals = oNum;
    } else {
        max_radicals = (int)(hNum / 3);
    }
#ifdef VERBOSE
    printf("Maximum # of radicals expected: %d\n", max_radicals);
#endif

    wait_to_terminate(max_radicals);
}

/*
* Now the tricky bit begins....  All the atoms are allowed
* to go their own way, but how does the Kosmos ethynyl-radical
* problem terminate? There is a non-zero probability that
* some atoms will not become part of a radical; that is,
* many atoms may be blocked on some semaphore of our own
* devising. How do we ensure the program ends when
* (a) all possible radicals have been created and (b) all
* remaining atoms are blocked (i.e., not on the ready queue)?
*/



/*
 * ^^^^^^^
 * DO NOT MODIFY CODE ABOVE THIS POINT.
 *
 *************************************
 *************************************
 *
 * ALL STUDENT WORK MUST APPEAR BELOW.
 * vvvvvvvv
 */


/* 
 * DECLARE / DEFINE NEEDED VARIABLES IMMEDIATELY BELOW.
 */
int shutdown = 0;

int radicals = 0;
int num_free_c = 0;
int num_free_o = 0;
int num_free_h = 0;

int r_active = 0;
int staged = 0;
int need_c = 0;
int need_o = 0;
int need_h = 0;

int c_id = -1;
int o_id = -1;
int h_id[3] = {-1, -1, -1};

pthread_mutex_t lock;
pthread_mutex_t reaction;
pthread_cond_t cond_r;
pthread_cond_t cond_c;
pthread_cond_t cond_o;
pthread_cond_t cond_h;

/*
 * FUNCTIONS YOU MAY/MUST MODIFY.
 */

bool can_form_radical() {
    return num_free_h >= 3 && num_free_c >= 1 && num_free_o >= 1;
}

void kosmos_init() {
    pthread_mutex_init(&lock, NULL);
    pthread_mutex_init(&reaction, NULL);

    pthread_cond_init(&cond_r, NULL);
    pthread_cond_init(&cond_c, NULL);
    pthread_cond_init(&cond_o, NULL);
    pthread_cond_init(&cond_h, NULL);
}

void *h_ready( void *arg )
{
	int id = *((int *)arg);
    char name[MAX_ATOM_NAME_LEN];

    sprintf(name, "h%03d", id);

#ifdef VERBOSE
	printf("%s now exists\n", name);
#endif

    pthread_mutex_lock(&lock);
    num_free_h++;

    if(!can_form_radical()){
        //participant thread

        //wait until required for reaction
        while(need_h <= 0) {
            pthread_cond_wait(&cond_h, &lock);

            //if leftover atoms
            if(shutdown){
                num_free_h--;
                pthread_mutex_unlock(&lock);
                return NULL;
            }
        }

        switch(need_h) {
            case 1:
                h_id[0] = id;
                break;
            case 2:
                h_id[1] = id;
                break;
            case 3:
                h_id[2] = id;
                break;
        }

        need_h--;

        //check if reaction ready and signal
        if(need_h == 0 && need_c == 0 && need_o == 0){
            staged = 1;
            pthread_cond_broadcast(&cond_r);
        }
        
        pthread_mutex_unlock(&lock);
        
    }else{
        //maker thread
        pthread_mutex_lock(&reaction);

        num_free_c -= 1;
        num_free_o -= 1;
        num_free_h -= 3;

        while(r_active){
            //no process will ever end up here
            //this is a failsafe to prevent
            //reactions overlapping
            
            pthread_mutex_unlock(&lock);
            pthread_cond_wait(&cond_r, &reaction);
            pthread_mutex_lock(&lock);
        }
        
        r_active = 1;
        h_id[2] = id;

        //set flag to allow 1c 1o 2h
        need_h = 2;
        need_o = 1;
        need_c = 1;
        
        pthread_cond_signal(&cond_c);
        pthread_cond_signal(&cond_o);
        pthread_cond_signal(&cond_h);
        pthread_cond_signal(&cond_h);

        pthread_mutex_unlock(&lock);

        //wait till participating atoms are staged
        while(!staged){
            pthread_cond_wait(&cond_r, &reaction);
        }
        
        make_radical(c_id,o_id,h_id[0],h_id[1],h_id[2], name);

        h_id[0] = -1; h_id[1] = -1; h_id[2] = -1;
        staged = 0;
        r_active = 0;
        
        pthread_mutex_unlock(&reaction);
    }
    
	return NULL;
}


void *c_ready( void *arg )
{
	int id = *((int *)arg);
    char name[MAX_ATOM_NAME_LEN];

    sprintf(name, "c%03d", id);

#ifdef VERBOSE
	printf("%s now exists\n", name);
#endif

    pthread_mutex_lock(&lock);
    num_free_c++;

    if(!can_form_radical()){
        //participant

        //waiting until required for a reaction
        while(need_c <= 0) {
            pthread_cond_wait(&cond_c, &lock);

            //if leftover atom
            if(shutdown){
                num_free_c--;
                pthread_mutex_unlock(&lock);
                return NULL;
            }
        }
        
        c_id = id;
        need_c--;

        //check if reaction ready and signal
        if(need_h == 0 && need_c == 0 && need_o == 0){
            staged = 1;
            pthread_cond_broadcast(&cond_r);
        }
        
        pthread_mutex_unlock(&lock);
        
    }else{
        //maker thread
        pthread_mutex_lock(&reaction);

        num_free_c -= 1;
        num_free_o -= 1;
        num_free_h -= 3;

        while(r_active){
            //no process will ever end up here
            //this is a failsafe to prevent
            //reactions overlapping
            
            pthread_mutex_unlock(&lock);
            pthread_cond_wait(&cond_r, &reaction);
            pthread_mutex_lock(&lock);
        }

        r_active = 1;

        c_id = id;

        //set flag to allow 1o 3h
        need_h = 3;
        need_o = 1;
        pthread_cond_signal(&cond_o);
        pthread_cond_signal(&cond_h);
        pthread_cond_signal(&cond_h);
        pthread_cond_signal(&cond_h);

        pthread_mutex_unlock(&lock);

        //wait to do reaction
        while(!staged){
            pthread_cond_wait(&cond_r, &reaction);
        }
        
        make_radical(c_id,o_id,h_id[0],h_id[1],h_id[2], name);

        h_id[0] = -1; h_id[1] = -1; h_id[2] = -1;
        staged = 0;
        r_active = 0;

        pthread_mutex_unlock(&reaction);
    }
    
	return NULL;
}

void *o_ready( void *arg )
{
	int id = *((int *)arg);
    char name[MAX_ATOM_NAME_LEN];

    sprintf(name, "o%03d", id);

#ifdef VERBOSE
	printf("%s now exists\n", name);
#endif

    pthread_mutex_lock(&lock);
    num_free_o++;

    if(!can_form_radical()){
        //participant

        //wait to be required for a recation
        while(need_o <= 0) {
            pthread_cond_wait(&cond_o, &lock);

            //if wont be used in reactions
            if(shutdown){
                num_free_o--;
                pthread_mutex_unlock(&lock);
                return NULL;
            }
            
        }
        
        o_id = id;
        need_o--;

        //check if reaction ready and signal
        if(need_h == 0 && need_c == 0 && need_o == 0){
            staged = 1;
            pthread_cond_broadcast(&cond_r);
        }
        
        pthread_mutex_unlock(&lock);
        
    }else{
        //maker thread
        pthread_mutex_lock(&reaction);

        num_free_c -= 1;
        num_free_o -= 1;
        num_free_h -= 3;

        while(r_active){
            //no process will ever end up here
            //this is a failsafe to prevent
            //reactions overlapping
            
            pthread_mutex_unlock(&lock);
            pthread_cond_wait(&cond_r, &reaction);
            pthread_mutex_lock(&lock);
        }

        r_active = 1; 
        o_id = id;

        //set flag to allow 1c 3h
        need_h = 3;
        need_c = 1;
        pthread_cond_signal(&cond_c);
        pthread_cond_signal(&cond_h);
        pthread_cond_signal(&cond_h);
        pthread_cond_signal(&cond_h);

        pthread_mutex_unlock(&lock);

        //wait to do reaction
        while(!staged){
            pthread_cond_wait(&cond_r, &reaction);
        }
        
        make_radical(c_id,o_id,h_id[0],h_id[1],h_id[2], name);

        h_id[0] = -1; h_id[1] = -1; h_id[2] = -1;
        
        staged = 0;
        r_active = 0;

        pthread_mutex_unlock(&reaction);
    }
    
	return NULL;
}

/* 
 * Note: The function below need not be used, as the code for making radicals
 * could be located with c_ready, h_ready, or o_ready. However, it is
 * perfectly possible that you have a solution which depends on such a
 * function having a purpose as intended by the function's name.
 */
void make_radical(int c, int o, int h1, int h2, int h3, char *maker)
{
#ifdef VERBOSE
	fprintf(stdout, "A methoxy radical was made: c%03d  o%03d  h%03d h%03d h%03d \n",
		c, o, h1, h2, h3);
#endif
    kosmos_log_add_entry(radicals, c, o, h1, h2, h3, maker);
    radicals++;
    
}

void wait_to_terminate(int expected_num_radicals) {
    /* A rather lazy way of doing it, for now. */
    sleep(MAX_KOSMOS_SECONDS);

    /*
    I wanted to join all threads
    but I dont have access to atom :(

    I made a shutdown procedure, but it
    depended on a race and without access
    to the threads, I cant safely destroy

    shutdown = 1;
    
    pthread_cond_broadcast(&cond_r);
    pthread_cond_broadcast(&cond_c);
    pthread_cond_broadcast(&cond_o);
    pthread_cond_broadcast(&cond_h);

    sleep(2);
    
    pthread_mutex_destroy(&lock);
    pthread_mutex_destroy(&reaction);
    pthread_cond_destroy(&cond_r);
    pthread_cond_destroy(&cond_c);
    pthread_cond_destroy(&cond_o);
    pthread_cond_destroy(&cond_h);
    */
    
    kosmos_log_dump();
    exit(0);
}
