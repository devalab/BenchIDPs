#ifndef _InputModule_h
#define _InputModule_h

#include<iostream>
#include<fstream>
//#include "DipolCorrFunc.h"
using namespace std;

class InputModule
{
	private:
	ifstream inFile;
	ifstream inFileAllId;
	ifstream inFileX;
	ifstream inFileY;
	ifstream inFileZ;
//	char fileName[60];
//	char fileNameX[60];
//	char fileNameY[60];
//	char fileNameZ[60];

	public:
	void getUserData(unsigned &numInitFrame, unsigned &numCalcFrame, unsigned &numFrames, unsigned &maxIdVal);
//	unsigned numFrames;
	
	void getFileData(unsigned ** idTable, double ** xTable, double ** yTable, double ** zTable,  unsigned numFrames,unsigned maxIdVal);
};

#endif

