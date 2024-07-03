
CC=gcc

# The line with -DDEBUG can be used for development. When
# building your code for evaluation, however, the line *without*
# the -DDEBUG will be used.
#

CFLAGS=-c -Wall -g -DDEBUG -D_GNU_SOURCE -std=c99 -O0


all: music_manager

music_manager: music_manager.o list.o emalloc.o
	$(CC) music_manager.o list.o emalloc.o -o music_manager

music_manager.o: music_manager.c list.h emalloc.h
	$(CC) $(CFLAGS) music_manager.c

list.o: list.c list.h emalloc.h
	$(CC) $(CFLAGS) list.c

emalloc.o: emalloc.c emalloc.h
	$(CC) $(CFLAGS) emalloc.c

clean:
	rm -rf *.o music_manager 
