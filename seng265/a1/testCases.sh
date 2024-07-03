#!/bin/bash

# Test 1
echo "Running Test 1..."
./event_manager --start=2023/1/22 --end=2023/1/23 --file=one.ics | diff test01.txt -
echo "Test 1 completed."

# Test 2
echo "Running Test 2..."
./event_manager --start=2023/2/14 --end=2023/2/14 --file=one.ics | diff test02.txt -
echo "Test 2 completed."

# Test 3
echo "Running Test 3..."
./event_manager --start=2023/2/10 --end=2023/2/16 --file=one.ics | diff test03.txt -
echo "Test 3 completed."

# Test 4
echo "Running Test 4..."
./event_manager --start=2023/4/18 --end=2023/4/21 --file=two.ics | diff test04.txt -
echo "Test 4 completed."

# Test 5
echo "Running Test 5..."
./event_manager --start=2023/4/20 --end=2023/4/30 --file=two.ics | diff test05.txt -
echo "Test 5 completed."

# Test 6
echo "Running Test 6..."
./event_manager --start=2023/5/1 --end=2023/5/20 --file=three.ics | diff test06.txt -
echo "Test 6 completed."

# Test 7
echo "Running Test 7..."
./event_manager --start=2023/5/28 --end=2023/7/7 --file=many.ics | diff test07.txt -
echo "Test 7 completed."

# Test 8
echo "Running Test 8..."
./event_manager --start=2023/1/1 --end=2023/12/31 --file=diana-devops.ics | diff test08.txt -
echo "Test 8 completed."
