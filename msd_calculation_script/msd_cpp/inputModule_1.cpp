#include "inputModule.h"

#include<iostream>
#include<fstream>
using namespace std;

void InputModule::getUserData(unsigned &numInitFrame, unsigned &numCalcFrame, unsigned &numFrames, unsigned &maxIdVal)
{
	numInitFrame = 1; 
	numCalcFrame = 3001;
	numFrames = numCalcFrame;
	maxIdVal = 120000;
}

void InputModule::getFileData(unsigned ** idTable, double ** xTable, double ** yTable, double ** zTable, unsigned numFrames, unsigned maxIdVal)
{
	inFile.open("../uniqID_shell_ab42_ildn_4A_3k_nojump.dat");
	FILE* inFileAllId;
	inFileAllId = fopen("../uniqID_allwat_ab42_ildn_4A_nojump.dat" , "r");
	inFileX.open("../input_OxyMx_ab42_ildn_4A_3k_nojump.dat");
	inFileY.open("../input_OxyMy_ab42_ildn_4A_3k_nojump.dat");
	inFileZ.open("../input_OxyMz_ab42_ildn_4A_3k_nojump.dat");	

	unsigned molsInFrame;
	unsigned idShell;
	unsigned id;
	unsigned last;
      	double x, y, z;
	long pos = ftell(inFileAllId);

	for(unsigned f=0;f<numFrames;f++)
	{
		fseek(inFileAllId, pos, SEEK_SET);
		// This is the number of molecules in the shell, at the i'th frame.
		inFile>>molsInFrame;
		if(inFile.eof())
		{
			cout<<"Something wrong.....Exiting!\n";
			exit(1);
		}
//		cout<<"M= "<<molsInFrame<<endl;

		for(unsigned s=0;s<molsInFrame;s++)
		{
			inFile>>idShell;
			idTable[idShell][f]=1;
			if(idShell>maxIdVal)
                        {
                                cout<<"Max Id of Molecule Specified by user is incorrect\n";
                                exit(1);
                        }
	//		printf("s=%d    idShell=%d       idTable[idShell][f]=%d\n",s,idShell,idTable[idShell][f]);
		}

		for(unsigned n=0;n<maxIdVal;n++)
		{
			fscanf(inFileAllId, "%d", &id);
			if(last == id)
			{
		//		printf("id=%d,   Breaking..\n",id);
				break;

			}
			inFileX>>x;
		//	printf("F = %d,       id=%d,   X  = %f\n",f,id,x);
			inFileY>>y;		
			inFileZ>>z;			
			xTable[id][f]=x; 
			yTable[id][f]=y;
			zTable[id][f]=z;
		//	printf("f = %d,  id=%d,  xTable[id][f]=%f,  idTable[id][f]=%d,  M=%d  \n\n",f,id,xTable[id][f],idTable[id][f],molsInFrame);
			last = id;
		}

	//	printf("end: f=%d \n\n",f);

	}
	inFile.close();
	fclose(inFileAllId);
	inFileX.close();
	inFileY.close();
	inFileZ.close();
}
