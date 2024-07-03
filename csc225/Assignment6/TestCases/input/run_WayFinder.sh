#!/bin/bash

# Compile WayFinder.java
javac WayFinder.java

# Iterate through input files
for input_file in input*.txt
do
    # Run WayFinder on input file and measure runtime
    runtime=$( ( time -p java WayFinder $input_file > temp_output.txt ) 2>&1 | awk '/^real/ { print $2 }' )
    
    # Get corresponding output file name
    output_file=$(echo $input_file | sed 's/input/output/')
    
    # Print output from input file
    echo "Output from $input_file:"
    cat temp_output.txt
    
    # Print output from output file
    echo "Expected output from $output_file:"
    cat output/$output_file
    
    # Print the runtime of the program
    echo "Runtime: ${runtime} seconds"

    echo " "
    echo " "
    
    # Remove temporary output file
    rm temp_output.txt
done
