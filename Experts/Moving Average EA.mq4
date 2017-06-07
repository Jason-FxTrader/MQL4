//+------------------------------------------------------------------+
//|                                            Moving Average EA.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int TakeProfit=900;
extern int StopLoss=780;
extern int FastMA=7;
extern int FastMaShift=0;
extern int FastMaMethod=0;
extern int FastMaAppliedTo=0;
extern int SlowMA=33;
extern int SlowMaShift=0;
extern int SlowMaMethod=0;
extern int SlowMaAppliedTo=0;
extern double LotSize=1;
extern int MagicNumber=1234;
double pips;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double ticksize=MarketInfo(Symbol(), MODE_TICKSIZE);
   if (ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else pips=ticksize;
   
   Print("ticksize: ", ticksize, "; pips: ", pips);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void start()
  {
     static datetime LastOpenTime = Time[0];   //time of the open of the last bar - must be static so as to remember the last value between calls to start().
   if (Time[0] > LastOpenTime)   //if new bar
   {//Log(string(__LINE__)+": NEW BAR");
      LastOpenTime = Time[0];          //new bar so save the time of the Open of the current bar

      go();
   }
   
  }
//+------------------------------------------------------------------+
void go()
{
   double PreviousFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,2);
//   Print("PreviousFast: ", PreviousFast);
   double CurrentFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,1);
//   Print("CurrentFast: ", CurrentFast);
   double PreviousSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,2);
//   Print("PreviousSlow: ", PreviousSlow);
   double CurrentSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,1);
//   Print("CurrentSlow: ", CurrentSlow);
   if (PreviousFast<PreviousSlow && CurrentFast>CurrentSlow)
      if (OrdersTotal()==0)
         OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,Ask-(StopLoss*pips),Ask+(TakeProfit*pips),NULL,MagicNumber,0,clrGreen); 
   if (PreviousFast>PreviousSlow && CurrentFast<CurrentSlow)
      if (OrdersTotal()==0)
         OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,Bid+(StopLoss*pips),Bid-(TakeProfit*pips),NULL,MagicNumber,0,clrRed); 
 }     
