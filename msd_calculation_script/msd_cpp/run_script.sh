#!/bin/bash


# Run the make command to compile the program

echo "Running the make command to compile the program"

make

echo "Make command executed"

echo "Running the executable"

# If the compilation is successful, run the executable
if [ $? -eq 0 ]; then
    ./Execut
else
    echo "Compilation failed."
fi

echo "Execution completed"
