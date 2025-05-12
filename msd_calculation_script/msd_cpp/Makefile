CXXFLAGS= -O2 -Wall

CXXCOMPILE=g++ -march=opteron $(CXXFLAGS) -c -o  
CXXLINK=g++ $(CXXFLAGS) -o

all: Execut

Execut: Execut.o InputModule.o OutputModule.o 
	$(CXXLINK) Execut Execut.o InputModule.o OutputModule.o 

Execut.o: meansquaredisp.cpp meansquaredisp.h inputModule.h outputModule.h 
	$(CXXCOMPILE) Execut.o meansquaredisp.cpp

InputModule.o: inputModule.cpp inputModule.h
	$(CXXCOMPILE) InputModule.o inputModule.cpp

OutputModule.o: outputModule.cpp outputModule.h 
	$(CXXCOMPILE) OutputModule.o outputModule.cpp
	
clean: 
	rm *.o Execut
