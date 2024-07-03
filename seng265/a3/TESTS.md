# Tests for `SENG 265`, Assignment #3

## Compilation and Requirements

1. You need to allow the execution of tester: `chmod u+x tester`
2. You need to configure the testing environment for the reference platform: `setSENG265`
3. Run the command `make` to compile your code before running the tests.

## Tests

* Test 1
    * Input: `top_songs_1999.csv`
    * Expected output: `test01.csv`
    * Command: `./music_manager --sortBy=popularity --display=10 --files=top_songs_1999.csv`
    * Test: `./tester 1`

* Test 2
    * Input: `top_songs_1999.csv`
    * Expected output: `test02.csv`
    * Command: `./music_manager --sortBy=energy --display=5 --files=top_songs_1999.csv`
    * Test: `./tester 2`

* Test 3
    * Input: `top_songs_1999.csv`
    * Expected output: `test03.csv`
    * Command: `./music_manager --sortBy=danceability --display=3 --files=top_songs_1999.csv`
    * Test: `./tester 3`

* Test 4
    * Input: `top_songs_2009.csv`
    * Expected output: `test04.csv`
    * Command: `./music_manager --sortBy=popularity --display=3 --files=top_songs_2009.csv`
    * Test: `./tester 4`

* Test 5
    * Input: `top_songs_2019.csv`
    * Expected output: `test05.csv`
    * Command: `./music_manager --sortBy=danceability --display=5 --files=top_songs_2019.csv`
    * Test: `./tester 5`