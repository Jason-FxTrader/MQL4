//+------------------------------------------------------------------+
//|                                                   MH_Globals.mqh |
//|                        Copyright 2016, Marc Hollyoak.            |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Marc Hollyoak"
#property link      "https://www.mql4.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex4"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
//-----------------------------------------------------------------------------------------------------------------------------------------
// Log string to Journal
//-----------------------------------------------------------------------------------------------------------------------------------------
void Log(string file, int line, string fn, string s)
{
   if (debug)
      Print(TimeToStr(TimeCurrent(),TIME_SECONDS) + file +": "+(string)line + ": " + fn +": " + s);
}

#define LOG(s) Log(__FILE__, __LINE__, __FUNCSIG__, s)

#property strict

#define  SIGNAL_NONE    0
#define  SIGNAL_LONG    1
#define  SIGNAL_SHORT   2

//---------------------------------------------------------------------------
//TODO: PARAMETERS NEED TO BE OPTIMIZED
//Strategy Tester Report - MH sMiner v0.23 - see OneNote
//Pass	Profit	Total trades	Profit factor	Expected Payoff	Drawdown $	Drawdown %
//174	   54660.78	81	            5.65	         674.82	         6134.91	   25.12%	0.00000000	K=12 	D=13 	slowing=9	EntryCondS1=49 OB=75 	OS=25 	SwingHigh=10 	RiskRatio=0.03 	RiskRatioTotal=0.06 	BaseTimeFrame=5
//6	   22220.84	330	         1.49	         67.34	            27183.40	   78.82%	0.00000000	K=15 	D=6 	slowing=7 	EntryCondS1=2	OB=75 	OS=25 	SwingHigh=10 	RiskRatio=0.03 	RiskRatioTotal=0.06 	BaseTimeFrame=-1
extern bool debug = FALSE;  //enable debugging output
extern double OB = 80; //Overbought level
extern double OS = 20; //Oversold level
extern int K = 14;
extern int D = 9;
extern int slowing=12;
extern int SwingHigh=10;      //Lookback period for SwingHigh
extern int EntryCondS1 = 49;
extern double RiskRatio = 0.03;      //3% Maximum capital exposure on any one trade - Miner p.159
extern double RiskRatioTotal = 0.06; //6% Maximum capital exposure on ALL trades - Miner p.159
extern int BaseTimeFrame = -1;  //Base TimeFrame - only use when optimising - to find the most profitable timeframe
//---------------------------------------------------------------------------
int MagicNumber = 12345;  //this EA's unique ID

int period1;  //current timeframe (from current selected chart)
int period2;  //current timeframe + 1
int period3;  //current timeframe + 2
int period4;  //current timeframe + 3
int period5;  //current timeframe + 4
int period6;  //current timeframe + 5
int period7;  //current timeframe + 6
int period8;  //current timeframe + 7
int period9;  //current timeframe + 8

//---------------------------------------------------------------------------
int pf = 0; //price field:  0 = Low/High, 1 = Close/Close (default)
double K1, K2, K3, K4, K5, K6, K7, K8, K9, D1, D2, D3, D4, D5, D6, D7, D8, D9, K1_1, K2_1, K3_1, K4_1, K5_1, K6_1, K7_1, K8_1, K9_1, D1_1, D2_1, D3_1, D4_1, D5_1, D6_1, D7_1, D8_1, D9_1;
//---------------------------------------------------------------------------
uint ObjGUID = 0; //GUID for name

int MainWin = 0;  //main chart window
int SubWin = 1;   //subwindow

CDictionary TradeUnits();        //Live Trades reflecting Opened (Market) or Pending Orders
CDictionary TradeUnitsHistory(); //History Trades reflecting Closed Market Orders or Cancelled (Deleted) Pending Orders

string Month[]= {NULL, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};