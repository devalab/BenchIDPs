#include "meansquaredisp.h"
#include "inputModule.h"
#include "outputModule.h"
#include <math.h>
#include <iostream>
using namespace std;

void Execut:: InitValues()
{
	InputModule inData;
        inData.getUserData(numInitFrame, numCalcFrame, numFrames, maxIdVal);
	
//	totMSD = new double[numFrames];
//	norm = new unsigned[numFrames];	

        idTable = new unsigned* [maxIdVal];
        xTable = new double* [maxIdVal];
        yTable = new double* [maxIdVal];
        zTable = new double* [maxIdVal];
        for(unsigned i=0;i<maxIdVal;i++)
        {
                idTable[i]=new unsigned[numFrames];
                xTable[i]=new double[numFrames];
                yTable[i]=new double[numFrames];
                zTable[i]=new double[numFrames];
        }

        for(unsigned i=0;i<maxIdVal;i++)
        {       for(unsigned j=0;j<numFrames;j++)
                {
                        idTable[i][j]=0;
                        xTable[i][j]=0.0;
                        yTable[i][j]=0.0;
                        zTable[i][j]=0.0;
                }
        }
        inData.getFileData(idTable,xTable,yTable,zTable,numFrames,maxIdVal);
}

void Execut::CollectPx(unsigned** idTable,double** xTable,double** yTable,double** zTable,unsigned numFrames,unsigned maxIdVal)
{ 
	double delr_Sq;
	double x1, y1, z1;
	double x2, y2, z2;
	double dx, dy, dz;
	unsigned nextPt;
	unsigned delT;
	double time;

	totMSD = new double[numFrames];
	norm = new unsigned[numFrames];

	FP1 = fopen("../msd_OW_4A_c36idpsff_disp_hp36_300k_1ps_1_3angs.dat" , "w");

	for(unsigned fi=0;fi<numFrames;fi++)
	{
		totMSD[fi]=0.0;
              	norm[fi]=0;                
	}

	for(unsigned n=0;n<maxIdVal;n++)	
	{
		nextPt = 0;
		for(unsigned fi=0;fi<numFrames;fi++)
		{
			if(idTable[n][fi]==1)	
			{
				for(unsigned fj=fi;fj<numFrames;fj++)
				{
					if(idTable[n][fj]==1)
					{
						delT = fj-fi;
						x1 = xTable[n][fi]; y1 = yTable[n][fi]; z1 = zTable[n][fi];
						x2 = xTable[n][fj]; y2 = yTable[n][fj]; z2 = zTable[n][fj];
						dx = (x2 - x1);
						dy = (y2 - y1);
						dz = (z2 - z1);
						delr_Sq = (dx*dx + dy*dy + dz*dz); 
						totMSD[delT] = totMSD[delT] + delr_Sq;
						norm[delT] = norm[delT] + 1; 
					}
					else
					{
						nextPt = fj;
				//		break;
					} //end else, if
				} // end for fj
			} // end if
	//		printf("%d\n",n);
		} // end for fi

		printf("id=%d\n",n);
	} // end for 'n'	

	
	for(unsigned t=0;t<numFrames;t++)
	{
		time = 1.000*t;
//		time = 1.0*t;
		MSD = (double)totMSD[t]/norm[t];
		fprintf(FP1, "%f %f\n", time, MSD);
	}

	fclose(FP1);

}

void Execut::HigherProg()
{
	CollectPx(idTable,xTable,yTable,zTable,numFrames,maxIdVal);	
}

void Execut::OutputValues()
{
	OutputModule outData;
	outData.writeData();
}

int main()
{
	Execut meansquaredisp;

	meansquaredisp.InitValues();
	cout<<"initializing vals done\n";
	meansquaredisp.HigherProg();
//	cout<<"initializing vals done\n";
	meansquaredisp.OutputValues();

	return 0;
}
