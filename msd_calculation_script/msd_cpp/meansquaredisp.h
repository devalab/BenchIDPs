//#ifndef _ResTime_Calc_h
//#define _ResTime_Calc_h

#include <iostream>
//using namespace std;

class Execut
{
 private:
 unsigned numInitFrame;
 unsigned numCalcFrame;
 unsigned maxIdVal;
 unsigned numFrames;
 unsigned **idTable;
 double **xTable;
 double **yTable;
 double **zTable;
 double *totMSD;
 double MSD;
 unsigned *norm;	
 FILE* FP1;
 public:
 void CollectPx(unsigned** idTable,double** xTable,double** yTable,double** zTable,unsigned numFrames,unsigned maxIdVal); 
 void HigherProg();
 unsigned **resTimeTable;
//  unsigned *normalize;
  double **totalDotProdTimeTable;
  void InitValues();
  void OutputValues();
};
//#endif
