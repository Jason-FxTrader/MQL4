//+-------------------------------------------------------------------+
//|                                                       Reversi.mq4 |
//|                                  Copyright © 2009, Steve Hopwood  |
//|                              http://www.hopwood3.freeserve.co.uk  |
//+-------------------------------------------------------------------+
#property copyright "Copyright © 2009, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"
#define  up "Up"
#define  down "Down"
#define  none "None"
#define  buy "Buy"
#define  sell "Sell"
#define  ranging "Ranging"
#define  confused "Confused, and so cannot trade"
#define  trending "Trending"
#define  opentrade "There is a trade open"
#define  stopped "Trading is stopped"
#define  breakevenlinename "Break even line"
#define  reentrylinename "Re entry line"

//From iExposure
#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6


/*


FUNCTIONS LIST
int init()
int start()

----Trading----

void GetStats()
void LookForTradingOpportunities()
bool IsTradingAllowed()
bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
bool DirectionEstablished()
bool DoesTradeExist(int type)
void CountOpenTrades()
bool CloseTrade(int ticket)
void LookForTradeClosure()
bool CheckTradingTimes()

----Balance filters etc----
void TradeDirectionBySwap()
bool IsThisPairTradable()
bool BalancedPair(int type)

----Trend detection module----
void TrendDetectionModule()
double GetRsi(int tf, int period, int ap, int shift)
double GetMa(int tf, int period, int mashift, int method, int ap, int shift)

----Hanover module----
bool HanoverFilter(int type)
void SetUpArrays()
void CleanUpInputString()
int CalculateParamsPassed()
void ReadHanover()
int LoadRSvalues()  
double ReadStrength(string curr, string tf, int shift)

----Matt's Order Reliable library code
bool O_R_CheckForHistory(int ticket) Cheers Matt, You are a star.
void O_R_Sleep(double mean_time, double max_time)

----Recovery----
void RecoveryModule()
void CheckRecoveryTakeProfit()
int Analyze()
int SymbolsIndex(string SymbolName)
void RecoveryCandlesticktrailingStop()
void LockInRecoveryProfit()
void AddReEntryLine(double price)
void CalculateReEntryLinePips() not included yet
void ReplaceReEntryLine()

----Trade management module----
void TradeManagementModule()
void BreakEvenStopLoss()
bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )
void JumpingStopLoss() 
void HiddenTakeProfit()
void HiddenStopLoss()
void TrailingStopLoss()
void CloseAllTrades()

*/

//Defined constants from hanover. Thanks David
#define AUD 0
#define CAD 1
#define CHF 2
#define EUR 3
#define GBP 4
#define JPY 5
#define NZD 6
#define USD 7

#define M1  0
#define M5  1
#define M15 2
#define M30 3
#define H1  4
#define H4  5
#define D1  6
#define W1  7
#define MN  8



extern string  gen="----General inputs----";
extern double  Lot=0.01;
extern bool    StopTrading=false;
extern bool    TradeLong=true;
extern bool    TradeShort=true;
extern int     TakeProfit=300;
extern int     StopLoss=0;
extern int     MagicNumber=0;
extern string  TradeComment="";
extern bool    CriminalIsECN=true;
extern int     MaxOpenPairsAllowed=10;
extern double  MaxSpread=120;

extern string  tts="----Trade triggers----";
extern bool    UseInsideBarTrigger=true;

extern string  tbc="----Trade balance checks----";
extern bool    UseZeljko=true;
extern bool    OnlyTradeCurrencyTwice=true;

extern string  amc="----Available Margin checks----";
extern string  sco="Scoobs";
extern bool    UseScoobsMarginCheck=false;
extern string  fk="ForexKiwi";
extern bool    UseForexKiwi=true;
extern int     FkMinimumMarginPercent=500;

//extern int     CandleDirectionTrigger=0;//In case we decide to use a trigger-candle-must-move filter
extern string  cst="----Candle statistics inputs----";
extern int     CandlesInSeries=0;
extern bool    AutoCalculateStats=true;
extern int     CalculationCandlesCount=0;
extern bool    UseLongestSequence=false;
extern bool    UseMostFrequentSequence=true;
extern int     SequenceMinimuCandles=6;
extern int     MinimumCandleBodySize=3;//To filter out candles too small to be considered in the x-move calculation
extern bool    ShowStats=true;

//Hanover
extern string  hm="----Hanover module----";
extern bool    UseHanover=true;
extern string  ctf="Time frames";
//extern string  TimeFrames="M1,M5,M15,M30,H1,H4,D1,W1,MN";
extern string  TimeFrames="D1";
extern int     SlopeConfirmationCandles=0;
extern int     StrongThreshold=0;
extern int     WeakThreshold=0;
extern string  hof="Hanover output file";
extern string  OutputFile            = "Output---Recent Strength.CSV";
extern int     NumPoints=15;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Arrays etc
string         InputString;//All purpose string to pass to CleanUpInputString() to remove unwanted leading/trailing stuff
int            NoOfTimeFrames;//The number for timeframes inputted into the TimeFrames input
string         Tf[];//Holds the time frames inputted into the TimeFrames input
string         StrongWeak[];//Holds the pair that represents the strongest and weakest in each time frame
string         StrongestCcy[], WeakestCcy[];//Go on, take a guess
double         StrongVal[], PrevStrongVal[], WeakVal[], PrevWeakVal[];//Another guess?
string         ConstructedPair[];//Holds the pairs made out of the currencies
string         Ccy1, Ccy2;//First and second currency in the pair

//Variables copied from the Strength Alerts indi. int LoadRSvalues() came from this
int      dig, tmf, h, i, j, k;
string alrt[11];
double   RSvalue[8,9,99];   // [currency,timeframe,datapoint#]
                            // currency: 0=AUD, 1=CAD, 2=CHF, 3=EUR, 4=GBP, 5=JPY, 6=NZD, 7=USD
                            // timeframe: 0=M1, 1=M5, 2=M15, 3=M30, 4=H1, 5=H4, 6=D1, 7=W1, 8=MN
                         
string   ccy[8] = {"AUD","CAD","CHF","EUR","GBP","JPY","NZD","USD"};
string   tf[9]  = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
string   arr[11];

int      ReadBars;//Bot reads the output file when this != Bars   
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  tdm="----Trend detection module----";
extern bool    RisingTrend=false;
extern bool    FallingTrend=false;
extern bool    UseTrendDetection=true;

extern string  trsi="Rsi trend detection";
extern bool    UseRsiTrendDetection=false;
extern int     RsiTdTf=1440;
extern int     RsiTdPeriod=20;
extern string  trs="Applied price: 0=Close; 1=Open; 2=High";
extern string  trs1="3=Low; 4=Median; 5=Typical; 6=Weighted";
extern int     RsiTdAppliedPrice=0;

//Fast ma > slow, trend is up & vice versa
extern string  tmas="Two MA - 'slowkey'";
extern bool    UseSlowkey=false;
extern int     FastMaTdTF=0;//Time frame defaults to current chart 
extern int     FastMaTdPeriod=100;
extern int     FastMaTdShift=0;//The MA Shift input
extern string  tmame="Method: 0=sma; 1=ema; 2=smma;  3=lwma";
extern int     FastMaTdMethod=0;
extern string  tmaap="Applied price: 0=Close; 1=Open; 2=High";
extern string  tmaap1="3=Low; 4=Median; 5=Typical; 6=Weighted";
extern int     FastMaTdAppliedPrice=0;
extern int     SlowMaTdTF=0;//Time frame defaults to current chart 
extern int     SlowMaTdPeriod=200;
extern int     SlowMaTdShift=0;
extern int     SlowMaTdMethod=0;
extern int     SlowMaTdAppliedPrice=0;

//Single, much longer term MA. Rising MA the trend is up and vice-versa
extern string  sima="Single moving average";
extern bool    UseMaTrendDetection=true;
extern int     SingleMaTdTF=10080;//Time frame defaults to W1
extern int     SingleMaTdPeriod=10;
extern int     SingleMaTdShift=0;//The MA Shift input
extern string  stmame="Method: 0=sma; 1=ema; 2=smma;  3=lwma";
extern int     SingleMaTdMethod=0;
extern string  stmaap="Applied price: 0=Close; 1=Open; 2=High";
extern string  stmaap1="3=Low; 4=Median; 5=Typical; 6=Weighted";
extern int     SingleMaTdAppliedPrice=0;
extern int     CompareWithCandles=5;
extern int     MinimumAcceptableMovement=300;//Pure guesswork to make sure there has bee a decent movement in the ma
//Confirmation ma
extern int     ConSingleMaTdTF=10080;//Time frame defaults to W1
extern int     ConSingleMaTdPeriod=8;
extern int     ConSingleMaTdShift=0;//The MA Shift input
extern int     ConSingleMaTdMethod=0;
extern int     ConSingleMaTdAppliedPrice=0;


extern string  tt="----Trading hours----";
extern string  Trade_Hours= "Set Morning & Evening Hours";
extern string  Trade_Hoursi= "Use 24 hour, local time clock";
extern string  Trade_Hours_M= "Morning Hours 0-12";
extern  int    start_hourm = 0;
extern  int    end_hourm = 12;
extern string  Trade_Hours_E= "Evening Hours 12-24";
extern  int    start_houre = 12;
extern  int    end_houre = 24;

extern string  pts="----Swap filter----";
extern bool    CadPairsPositiveOnly=true;
extern bool    AudPairsPositiveOnly=true;
extern bool    NzdPairsPositiveOnly=true;

extern string  rec="----Recovery----";
extern bool    UseRecovery=true;
extern int     Start_Recovery_at_trades=2;  //DC
extern bool    Use1.1.3.3Recovery=false;
extern bool    Use1.1.2.4Recovery=false;
extern bool    Use1.2.6Recovery=true;//Pippo's idea
extern int     ReEntryLinePips=100;
extern color   ReEntryLineColour=Turquoise;
extern color   BreakEvenLineColour=Blue;
extern int     RecoveryBreakEvenProfitPips=20;
extern bool    UseRecoveryTradeProfitLockin=false;
extern string  rts="Recovery trailing stop";
extern bool    UseRecoveryTrailingStop=true;
extern int     RecoveryTrailingStopAt=10;
extern color   RecoveryStopLossLineColour=Red;
bool    UseHardRecoveryStop=false;//Doesn't work but is part of the code and I cannot be bothered to remove it

extern string  hdg="----Hedging----";
extern bool    UseHedging=true;
extern double  HedgeLotMultiplier=2;

extern string  tmm="----Trade management module----";
extern string  BE="Break even settings";
extern bool    BreakEven=false;
extern int     BreakEvenPips=25;
extern int     BreakEvenProfit=10;
extern bool    HideBreakEvenStop=false;
extern int     PipsAwayFromVisualBE=5;
extern string  cts="Candlestick trailing stop";
extern bool    UseCandlestickTrailingStop=false;
extern string  JSL="Jumping stop loss settings";
extern bool    JumpingStop=true;
extern int     JumpingStopPips=50;
extern bool    AddBEP=true;
extern bool    JumpAfterBreakevenOnly=false;
extern bool    HideJumpingStop=false;
extern int     PipsAwayFromVisualJS=10;
extern string  TSL="Trailing stop loss settings";
extern bool    TrailingStop=false;
extern int     TrailingStopPips=50;
extern bool    HideTrailingStop=false;
extern int     PipsAwayFromVisualTS=10;
extern bool    TrailAfterBreakevenOnly=false;
extern bool    StopTrailAtPipsProfit=false;
extern int     StopTrailPips=0;
extern string  hsl1="Hidden stop loss settings";
extern bool    HideStopLossEnabled=false;
extern int     HiddenStopLossPips=20;
extern string  htp="Hidden take profit settings";
extern bool    HideTakeProfitEnabled=false;
extern int     HiddenTakeProfitPips=20;
extern string  mis="----Odds and ends----";
extern bool    ShowManagementAlerts=true;
extern int     DisplayGapSize=30;


//Matt's O-R stuff
int 	         O_R_Setting_max_retries 	= 10;
double 	      O_R_Setting_sleep_time 		= 4.0; /* seconds */
double 	      O_R_Setting_sleep_max 		= 15.0; /* seconds */

//Trading variables
int            TicketNo, OpenTrades;
string         TradeDirection;
bool           BuyOpen, SellOpen;
bool           ForceAllTradeDeletion;
bool           CanTradeThisPair;//Will be false when this pair fails the currency can only trade twice filter, or the balanced trade filter

//Reversal variables
int            Candle[50];//Holds frequency of candle movement 
int            HighestSequence;//Holds the highest number of moves in one direction before a reverse
int            CommonFrequency;//Holds the most common no of candles in one direction before a reverse
int            DiscardedCandles;//Total of candles that fail the min candle body size test

//Margin filters
bool           ScoobsOk, FkOk;

//Trend detection
string         trend;
double         TrendRsiVal;//Rsi
double         FastTrendMaVal, SlowTrendMaVal;//2 MA trend
double         SingleTrendMaVal, PrevSingleTrendMaVal, ConSingleTrendMaVal;//Single trend ma

//Hedging
bool           HedgingInProgress;
double         BasketUpl, TotalLotsOpen;

//Misc
string         Gap, ScreenMessage;
int            OldBars, OldRecoverTrailBars;
int            OldCstBars;//For candlestick ts
string         PipDescription=" pips";

//Recovery
bool           RecoveryInProgress, TpMoved;
int            RecoveryLockProfitsAt=50;
int            RecoveryLockInPips=10;
string ExtSymbols[SYMBOLS_MAX];
int    ExtSymbolsTotal=0;
double ExtSymbolsSummaries[SYMBOLS_MAX][7];
int    ExtLines=-1;
string ExtCols[8]={"Symbol",
                   "Deals",
                   "Buy lots",
                   "Buy price",
                   "Sell lots",
                   "Sell price",
                   "Net lots",
                   "Profit"};
int    ExtShifts[8]={ 10, 80, 130, 180, 260, 310, 390, 460 };
int    ExtVertShift=14;
double buy_price=0.0;
double sell_price=0.0;

void DisplayUserFeedback()
{
   
   if (IsTesting() && !IsVisualMode()) return;

   ScreenMessage = "";
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), NL );
   /*
   //Code for time to bar-end display from Candle Time by Nick Bilak
   double i;
   int m,s,k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, m + " minutes " + s + " seconds left to bar end", NL);
   */
      
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);      
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Lot size: ", Lot, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Take profit: ", TakeProfit, PipDescription,  NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Stop loss: ", StopLoss, PipDescription,  NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Magic number: ", MagicNumber, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trade comment: ", TradeComment, NL);
   if (CriminalIsECN) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CriminalIsECN = true", NL);
   else ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CriminalIsECN = false", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Criminal's minimum lot size: ", MarketInfo(Symbol(), MODE_MINLOT), NL, NL );
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trading hours", NL);
   if (start_hourm == 0 && end_hourm == 12 && start_houre && end_houre == 24) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            24H trading", NL);
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            start_hourm: ", DoubleToStr(start_hourm, 2), 
                      ": end_hourm: ", DoubleToStr(end_hourm, 2), NL);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            start_houre: ", DoubleToStr(start_houre, 2), 
                      ": end_houre: ", DoubleToStr(end_houre, 2), NL);
                      
   }//else

   //Trend
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trend is ", trend, NL);
   if (UseTrendDetection)
   {
      //Rsi
      if (UseRsiTrendDetection)
      {
         ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trend Rsi ", TrendRsiVal, NL);
      }//if (UseRsiTrendDetection)
      
      //slowkey 2 moving average
      if (UseSlowkey)
      {
         ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Fast MA ", FastTrendMaVal, ":  Slow MA ", SlowTrendMaVal,  NL);
      }//if (UseSlowkey)
      
      //Single moving average
      if (UseMaTrendDetection)
      {
         ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Current MA ", DoubleToStr(SingleTrendMaVal, Digits), ":  ", CompareWithCandles, " candles ago ", 
         DoubleToStr(PrevSingleTrendMaVal, Digits), ": Confirmation MA ", DoubleToStr(ConSingleTrendMaVal, Digits), NL);
         
      }//if (UseMaTrendDetection)
   }//if (UseTrendDetection)

   
   if (UseHanover)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);      
      string now, then;         
      for (int cc = 0; cc < ArraySize(Tf); cc++)
      {
         double strength1 = ReadStrength(Ccy1, Tf[cc], 0);
         double strength2 = ReadStrength(Ccy2, Tf[cc], 0);
         if (SlopeConfirmationCandles > 0) 
         {
            double prevstrength1 = ReadStrength(Ccy1, Tf[cc], SlopeConfirmationCandles);
            now = StringConcatenate(": Shift ",SlopeConfirmationCandles, " = ", DoubleToStr(prevstrength1, 2));
            double prevstrength2 = ReadStrength(Ccy2, Tf[cc], SlopeConfirmationCandles);
            then = StringConcatenate(": Shift ", SlopeConfirmationCandles, " = ", DoubleToStr(prevstrength2, 2));
         }//if (SlopeCandles[cc] > 0) 
      
         ScreenMessage = StringConcatenate(ScreenMessage,Gap, "TF ", Tf[cc], 
                                           ": ", Ccy1, ": Now = ", DoubleToStr(strength1, 2),
                                           now,
                                           ": ", Ccy2, ": Now = ", DoubleToStr(strength2, 2),
                                           then,
                                           NL);
      }//for (int cc = 0; cc < ArraySize(Tf); cc++)
      if (StrongThreshold > 0 && WeakThreshold > 0)
      {
         bool tradeable = false;
         if (strength1 > StrongThreshold && strength2 < WeakThreshold)
         {
            ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Threshold: Can trade this pair long", NL);
            tradeable = true;
         }//if (strength1 > StrongThreshold && strength2 < WeakThreshold)
         
         if (strength2 > StrongThreshold && strength1 < WeakThreshold)
         {
            ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Threshold: Can trade this pair short", NL);
            tradeable = true;
         }//if (strength1 > StrongThreshold && strength2 < WeakThreshold)
         
         if (!tradeable) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Threshold: Cannot trade this pair yet", NL);
      }//if (StrongThreshold > 0 && WeakThreshold > 0)
      
   }//if (UseHanover)
   
   //Display statistics
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CalculationCandlesCount = ", CalculationCandlesCount, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CandlesInSeries = ", CandlesInSeries, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "DiscardedCandles = ", DiscardedCandles, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Statistics", NL);
   if (ShowStats)
   {
      for (cc = 1; cc <= ArraySize(Candle); cc++)
      {
         if (Candle[cc] > 0)
         {
            ScreenMessage = StringConcatenate(ScreenMessage,Gap, cc, " candle moves: ", Candle[cc], NL);
         }//if (Candle[cc] > 0)
         
      }//for (cc = 1; cc <= ArraySize(Candle); cc++)
      
   }//if (ShowStats)
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Highest run before reversing: ", HighestSequence, NL); 
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Most common sequence of candles before reversing >= ", 
                   SequenceMinimuCandles, " is ", CommonFrequency, " (", Candle[CommonFrequency], " times)", NL); 
   
   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);

   if (UseHedging)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Hedging on a trend change. HedgeLotMultiplier = ", HedgeLotMultiplier, NL);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "       Open lots = ", TotalLotsOpen, ": Basket upl = ", DoubleToStr(BasketUpl, Digits), NL);
   }//if (UseHedging)
   

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   if (BreakEven)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Breakeven is set to ", BreakEvenPips, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,": BreakEvenProfit = ", BreakEvenProfit, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL); 
   }//if (BreakEven)


   if (UseCandlestickTrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Using candlestick trailing stop", NL);      
   }//if (UseCandlestickTrailingStop)
   
   if (JumpingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Jumping stop is set to ", JumpingStopPips, PipDescription);
      if (AddBEP) ScreenMessage = StringConcatenate(ScreenMessage,": BreakEvenProfit = ", BreakEvenProfit, PipDescription);
      if (JumpAfterBreakevenOnly) ScreenMessage = StringConcatenate(ScreenMessage, ": JumpAfterBreakevenOnly = true");
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);   
   }//if (JumpingStop)
   

   if (TrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trailing stop is set to ", TrailingStopPips, PipDescription);
      if (TrailAfterBreakevenOnly) ScreenMessage = StringConcatenate(ScreenMessage, ": TrailAfterBreakevenOnly = true");
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);   
   }//if (TrailingStop)

   if (HideStopLossEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Hidden stop loss enabled at ", HiddenStopLossPips, PipDescription, NL);
   }//if (HideStopLossEnabled)
   
   if (HideTakeProfitEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Hidden take profit enabled at ", HideTakeProfitEnabled, PipDescription, NL);
   }//if (HideTakeProfitEnabled)

   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   
   Comment(ScreenMessage);


}//void DisplayUserFeedback()


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

   //Adapt to x digit criminals
   int multiplier;
   if(Digits == 2 || Digits == 4) multiplier = 1;
   if(Digits == 3 || Digits == 5) multiplier = 10;
   if(Digits == 6) multiplier = 100;   
   if(Digits == 7) multiplier = 1000;   
   
   if (multiplier > 1) PipDescription = " points";
   
   TakeProfit*= multiplier;
   StopLoss*= multiplier;
   BreakEvenPips*= multiplier;
   BreakEvenProfit*= multiplier;
   PipsAwayFromVisualBE*= multiplier;
   JumpingStopPips*= multiplier;
   PipsAwayFromVisualJS*= multiplier;
   TrailingStopPips*= multiplier;
   PipsAwayFromVisualTS*= multiplier;
   StopTrailPips*= multiplier;
   HiddenStopLossPips*= multiplier;
   HiddenTakeProfitPips*= multiplier;
   RecoveryLockProfitsAt*= multiplier;
   RecoveryLockInPips*= multiplier;
   RecoveryTrailingStopAt*= multiplier;
   ReEntryLinePips*= multiplier;
   MinimumCandleBodySize*= multiplier;
   
   
   Gap="";
   if (DisplayGapSize >0)
   {
      for (int cc=0; cc< DisplayGapSize; cc++)
      {
         Gap = StringConcatenate(Gap, " ");
      }   
   }//if (DisplayGapSize >0)
   
   //Set up the arrays
   if (UseHanover)
   {
      SetUpArrays();
      Ccy1 = StringSubstr(Symbol(), 0, 3);
      Ccy2 = StringSubstr(Symbol(), 3, 3);
      ReadBars = iBars(NULL, PERIOD_M1);//Don't need it again when start() triggers
      ReadHanover();
   }//if (UseHanover)

   if (TradeComment == "") TradeComment = " ";
   //OldBars = Bars;
   //ReadIndicatorValues();//For initial display in case user has turned of constant re-display
   //DisplayUserFeedback();
   if (CalculationCandlesCount == 0) CalculationCandlesCount = Bars;
   start();
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----
   Comment("");
//----
   return(0);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//TRADE MANAGEMENT MODULE

bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )
{
   //Reusable code that can be called by any of the stop loss manipulation routines except HiddenStopLoss().
   //Checks to see if the market has hit the hidden sl and attempts to close the trade if so. 
   //Returns true if trade closure is successful, else returns false
   
   //Check buy trade
   if (type == OP_BUY)
   {
      double sl = NormalizeDouble(stop + (iPipsAboveVisual * Point), Digits);
      if (Bid <= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Bid <= sl)  
   }//if (type = OP_BUY)
   
   //Check buy trade
   if (type == OP_SELL)
   {
      sl = NormalizeDouble(stop - (iPipsAboveVisual * Point), Digits);
      if (Ask >= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Ask >= sl)  
   }//if (type = OP_SELL)
   

}//End bool CheckForHiddenStopLossHit(int type, int iPipsAboveVisual, double stop )


void BreakEvenStopLoss() // Move stop loss to breakeven
{

   //Check hidden BE for trade closure
   if (HideBreakEvenStop)
   {
      bool TradeClosed = CheckForHiddenStopLossHit(OrderType(), PipsAwayFromVisualBE, OrderStopLoss() );
      if (TradeClosed) return;//Trade has closed, so nothing else to do
   }//if (HideBreakEvenStop)


   bool result;

   if (OrderType()==OP_BUY)
         {
            if (Bid >= OrderOpenPrice () + (Point*BreakEvenPips) && 
                OrderStopLoss()<OrderOpenPrice())
            {
               while(IsTradeContextBusy()) Sleep(100);
               result = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+(BreakEvenProfit*Point), Digits),OrderTakeProfit(),0,CLR_NONE);
               if (result && ShowManagementAlerts==true) Alert("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               if (!result)
               {
                  int err=GetLastError();
                  if (ShowManagementAlerts==true) Alert("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
                  Print("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
               }//if !result && ShowManagementAlerts)      
               //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               //{
               //   bool PartCloseSuccess = PartCloseTradeFunction();
               //   if (!PartCloseSuccess) SetAGlobalTicketVariable();
               //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }
   	   }               			         
          
   if (OrderType()==OP_SELL)
         {
           if (Ask <= OrderOpenPrice() - (Point*BreakEvenPips) &&
              (OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0)) 
            {
               while(IsTradeContextBusy()) Sleep(100);
               result = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-(BreakEvenProfit*Point), Digits),OrderTakeProfit(),0,CLR_NONE);
               if (result && ShowManagementAlerts==true) Alert("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Breakeven set on ", OrderSymbol(), " ticket no ", OrderTicket());
               if (!result && ShowManagementAlerts)
               {
                  err=GetLastError();
                  if (ShowManagementAlerts==true) Alert("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
                  Print("Setting of breakeven SL ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
               }//if !result && ShowManagementAlerts)      
              //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
              // {
              //    PartCloseSuccess = PartCloseTradeFunction();
              //    if (!PartCloseSuccess) SetAGlobalTicketVariable();
              // }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }    
         }
      

} // End BreakevenStopLoss sub

void JumpingStopLoss() 
{
   // Jump sl by pips and at intervals chosen by user .
   // Also carry out partial closure if the user requires this

   // Abort the routine if JumpAfterBreakevenOnly is set to true and be sl is not yet set
   if (JumpAfterBreakevenOnly && OrderType()==OP_BUY)
   {
      if(OrderStopLoss()<OrderOpenPrice()) return(0);
   }
  
   if (JumpAfterBreakevenOnly && OrderType()==OP_SELL)
   {
      if(OrderStopLoss()>OrderOpenPrice() || OrderStopLoss() == 0 ) return(0);
   }
  
   double sl=OrderStopLoss(); //Stop loss

   if (OrderType()==OP_BUY)
   {
      //Check hidden js for trade closure
      if (HideJumpingStop)
      {
         bool TradeClosed = CheckForHiddenStopLossHit(OP_BUY, PipsAwayFromVisualJS, OrderStopLoss() );
         if (TradeClosed) return;//Trade has closed, so nothing else to do
      }//if (HideJumpingStop)
      
      // First check if sl needs setting to breakeven
      if (sl==0 || sl<OrderOpenPrice())
      {
         if (Ask >= OrderOpenPrice() + (JumpingStopPips*Point))
         {
            sl=OrderOpenPrice();
            if (AddBEP==true) sl=sl+(BreakEvenProfit*Point); // If user wants to add a profit to the break even
            while(IsTradeContextBusy()) Sleep(100);
            bool result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               if (ShowManagementAlerts==true) Alert("Jumping stop set at breakeven ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
               Print("Jumping stop set at breakeven: ", OrderSymbol(), ": SL ", sl, ": Ask ", Bid);
               //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               //{
                  //bool PartCloseSuccess = PartCloseTradeFunction();
                  //if (!PartCloseSuccess) SetAGlobalTicketVariable();
               //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }//if (result)
            if (!result)
            {
               int err=GetLastError();
               if (ShowManagementAlerts) Alert(OrderSymbol(), "Ticket ", OrderTicket(), " buy trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
               Print(OrderSymbol(), " buy trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
            }//if (!result)
             
            return(0);
         }//if (Ask >= OrderOpenPrice() + (JumpingStopPips*Point))
      } //close if (sl==0 || sl<OrderOpenPrice()

  
      // Increment sl by sl + JumpingStopPips.
      // This will happen when market price >= (sl + JumpingStopPips)
      if (Bid>= sl + ((JumpingStopPips*2)*Point) && sl>= OrderOpenPrice())      
      {
         sl=sl+(JumpingStopPips*Point);
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": SL ", sl, ": Ask ", Ask);
            //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
            //{
               //PartCloseSuccess = PartCloseTradeFunction();
               //if (!PartCloseSuccess) SetAGlobalTicketVariable();
            //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
         }//if (result)
         if (!result)
         {
            err=GetLastError();
            if (ShowManagementAlerts) Alert(OrderSymbol(), " buy trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
            Print(OrderSymbol(), " buy trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
         }//if (!result)
             
      }// if (Bid>= sl + (JumpingStopPips*Point) && sl>= OrderOpenPrice())      
   }//if (OrderType()==OP_BUY)
   
   if (OrderType()==OP_SELL)
   {
      //Check hidden js for trade closure
      if (HideJumpingStop)
      {
         TradeClosed = CheckForHiddenStopLossHit(OP_SELL, PipsAwayFromVisualJS, OrderStopLoss() );
         if (TradeClosed) return;//Trade has closed, so nothing else to do
      }//if (HideJumpingStop)
            
      // First check if sl needs setting to breakeven
      if (sl==0 || sl>OrderOpenPrice())
      {
         if (Ask <= OrderOpenPrice() - (JumpingStopPips*Point))
         {
            sl = OrderOpenPrice();
            if (AddBEP==true) sl=sl-(BreakEvenProfit*Point); // If user wants to add a profit to the break even
            while(IsTradeContextBusy()) Sleep(100);
            result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
            if (result)
            {
               //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
               //{
                 // PartCloseSuccess = PartCloseTradeFunction();
                  //if (!PartCloseSuccess) SetAGlobalTicketVariable();
               //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
            }//if (result)
            if (!result)
            {
               err=GetLastError();
               if (ShowManagementAlerts) Alert(OrderSymbol(), " sell trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
               Print(OrderSymbol(), " sell trade. Jumping stop function failed to set SL at breakeven, with error(",err,"): ",ErrorDescription(err));
            }//if (!result)
             
            return(0);
         }//if (Ask <= OrderOpenPrice() - (JumpingStopPips*Point))
      } // if (sl==0 || sl>OrderOpenPrice()
   
      // Decrement sl by sl - JumpingStopPips.
      // This will happen when market price <= (sl - JumpingStopPips)
      if (Bid<= sl - ((JumpingStopPips*2)*Point) && sl<= OrderOpenPrice())      
      {
         sl=sl-(JumpingStopPips*Point);
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Jumping stop set at ",sl, " ", OrderSymbol(), " ticket no ", OrderTicket());
            Print("Jumping stop set: ", OrderSymbol(), ": SL ", sl, ": Ask ", Ask);
            //if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
            //{
              // PartCloseSuccess = PartCloseTradeFunction();
               //if (!PartCloseSuccess) SetAGlobalTicketVariable();
            //}//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
         }//if (result)          
         if (!result)
         {
            err=GetLastError();
            if (ShowManagementAlerts) Alert(OrderSymbol(), " sell trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
            Print(OrderSymbol(), " sell trade. Jumping stop function failed with error(",err,"): ",ErrorDescription(err));
         }//if (!result)

      }// close if (Bid>= sl + (JumpingStopPips*Point) && sl>= OrderOpenPrice())         
   }//if (OrderType()==OP_SELL)

} //End of JumpingStopLoss sub

void HiddenStopLoss()
{
   //Called from ManageTrade if HideStopLossEnabled = true


   //Should the order close because the stop has been passed?
   //Buy trade
   if (OrderType() == OP_BUY)
   {
      double sl = NormalizeDouble(OrderOpenPrice() - (HiddenStopLossPips * Point), Digits);
      if (Bid <= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Bid <= sl)      
   }//if (OrderType() == OP_BUY)
   
   //Sell trade
   if (OrderType() == OP_SELL)
   {
      sl = NormalizeDouble(OrderOpenPrice() + (HiddenStopLossPips * Point), Digits);
      if (Ask >= sl)
      {
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Stop loss hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Ask >= sl)   
   }//if (OrderType() == OP_SELL)
   

}//End void HiddenStopLoss()

void HiddenTakeProfit()
{
   //Called from ManageTrade if HideStopLossEnabled = true


   //Should the order close because the stop has been passed?
   //Buy trade
   if (OrderType() == OP_BUY)
   {
      double tp = NormalizeDouble(OrderOpenPrice() + (HiddenTakeProfitPips * Point), Digits);
      if (Bid >= tp)
      {
         while(IsTradeContextBusy()) Sleep(100);
         bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            int err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Ask >= tp)      
   }//if (OrderType() == OP_BUY)
   
   //Sell trade
   if (OrderType() == OP_SELL)
   {
      tp = NormalizeDouble(OrderOpenPrice() - (HiddenTakeProfitPips * Point), Digits);
      if (Ask <= tp)
      {
         while(IsTradeContextBusy()) Sleep(100);
         result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
         if (result)
         {
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket());      
         }//if (result)
         else
         {
            err=GetLastError();
            if (ShowManagementAlerts==true) Alert("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
            Print("Take profit hit. Close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         }//else
      }//if (Bid <= tp)   
   }//if (OrderType() == OP_SELL)
   

}//End void HiddenTakeProfit()

void TrailingStopLoss()
{
      if (TrailAfterBreakevenOnly && OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice()) return(0);
      }
     
      if (TrailAfterBreakevenOnly && OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice()) return(0);
      }
     
   
   
   bool result;
   double sl=OrderStopLoss(); //Stop loss
   double BuyStop=0, SellStop=0;
   
   if (OrderType()==OP_BUY) 
      {
         if (HideTrailingStop)
         {
            bool TradeClosed = CheckForHiddenStopLossHit(OP_BUY, PipsAwayFromVisualTS, OrderStopLoss() );
            if (TradeClosed) return;//Trade has closed, so nothing else to do
         }//if (HideJumpingStop)
		   
		   if (Bid >= OrderOpenPrice() + (TrailingStopPips*Point))
		   {
		       if (OrderStopLoss() == 0) sl = OrderOpenPrice();
		       if (Bid > sl +  (TrailingStopPips*Point))
		       {
		          sl= Bid - (TrailingStopPips*Point);
		          // Exit routine if user has chosen StopTrailAtPipsProfit and
		          // sl is past the profit Point already
		          if (StopTrailAtPipsProfit && sl>= OrderOpenPrice() + (StopTrailPips*Point)) return;
		          while(IsTradeContextBusy()) Sleep(100);
		          result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
               if (result)
               {
                  Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Ask ", Ask);
               }//if (result) 
               else
               {
                  int err=GetLastError();
                  Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
               }//else
   
		       }//if (Bid > sl +  (TrailingStopPips*Point))
		   }//if (Bid >= OrderOpenPrice() + (TrailingStopPips*Point))
      }//if (OrderType()==OP_BUY) 

      if (OrderType()==OP_SELL) 
      {
		   if (Ask <= OrderOpenPrice() - (TrailingStopPips*Point))
		   {
             if (HideTrailingStop)
             {
                TradeClosed = CheckForHiddenStopLossHit(OP_SELL, PipsAwayFromVisualTS, OrderStopLoss() );
                if (TradeClosed) return;//Trade has closed, so nothing else to do
             }//if (HideJumpingStop)
		   
		       if (OrderStopLoss() == 0) sl = OrderOpenPrice();
		       if (Ask < sl -  (TrailingStopPips*Point))
		       {
	               sl= Ask + (TrailingStopPips*Point);
  	               // Exit routine if user has chosen StopTrailAtPipsProfit and
		            // sl is past the profit Point already
		            if (StopTrailAtPipsProfit && sl<= OrderOpenPrice() - (StopTrailPips*Point)) return;
		            while(IsTradeContextBusy()) Sleep(100);
		            result = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,CLR_NONE);
                  if (result)
                  {
                     Print("Trailing stop updated: ", OrderSymbol(), ": SL ", sl, ": Bid ", Bid);
                  }//if (result)
                  else
                  {
                     err=GetLastError();
                     Print(OrderSymbol(), " order modify failed with error(",err,"): ",ErrorDescription(err));
                  }//else
    
		       }//if (Ask < sl -  (TrailingStopPips*Point))
		   }//if (Ask <= OrderOpenPrice() - (TrailingStopPips*Point))
      }//if (OrderType()==OP_SELL) 

      
} // End of TrailingStopLoss sub

void CandlestickTrailingStop()
{
   
   //Trails the stop at the hi/lo of the previous candle.
   //Only tries to do this once per bar, so an invalid stop error will only be generated once.
   
   if (OldCstBars == Bars) return;
   OldCstBars = Bars;
   bool result = false, modify = false;
   int err;
   double stop;
   
   if (OrderType() == OP_BUY)
   {
      if (Low[1] > OrderStopLoss() && OrderProfit() >= 0)
      {
         stop = NormalizeDouble(Low[1], Digits);
         modify = true;
      }//if (Close[1] > OrderStopLoss() && OrderProfit() >= 0)
   }//if (OrderType == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      if ( (High[1] < OrderStopLoss() || OrderStopLoss() == 0) && OrderProfit() >= 0)
      {
         stop = NormalizeDouble(High[1], Digits);
         modify = true;
      }//if (Close[1] > OrderStopLoss() && OrderProfit() >= 0)
   }//if (OrderType() == OP_SELL)
   
   if (modify)
   {
      result = OrderModify(OrderTicket(), OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
      if (!result)
      {
         err = GetLastError();
         if (err != 130) OldBars = 0;//Retry the modify at the next tick unless the error is invalid stops
      }//if (!result)      
   }//if (modify)

}//End void CandlestickTrailingStop()

void RecoveryCandlesticktrailingStop()
{

   //Called from start()
   //This function will only be called if Recovery is in progress.
   
/*
    * no tp in Recovery trades, just the breakeven line on the chart
    * at be +10, the breakeven line becomes the stop loss line
    * code a candlestick trail for the stop loss line
    * close the Recovery basket when the market retraces to the stop loss line
*/
   
   //Find the trade type. Function leaves an open trade selected   
   
   double target, stop;
   
   RefreshRates();
          
   if (BuyOpen)
   {
      //Should breakeven line be replaced by trailing stop line.
      //Irrelevant if be line has been deleted
      if (ObjectFind(breakevenlinename) > -1)
      {
         target = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
         if (Ask >= target + (RecoveryTrailingStopAt * Point) )
         {
            ObjectDelete(breakevenlinename);
            ObjectCreate(breakevenlinename, 1,0,TimeCurrent(),target);
            ObjectSet(breakevenlinename,OBJPROP_COLOR,RecoveryStopLossLineColour);
            ObjectSet(breakevenlinename,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSet(breakevenlinename,OBJPROP_WIDTH,2);     
            //return;
         }//if (Ask >= target + (RecoveryTrailingStopAt * Point) )
      }//if (ObjectFind(breakevenlinename) > -1)
      
      //Abort the function if be line is wrong colour
      if (ObjectGet(breakevenlinename, OBJPROP_COLOR) != RecoveryStopLossLineColour) return;
  
      //Move the stop at each new candle
      if (OldRecoverTrailBars != Bars)
      {
         target = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
         
         if (Low[1] > target)
         {
            ObjectMove(breakevenlinename, 0, TimeCurrent(), Low[1]);            
         }//if (Low[1] > target)
         OldRecoverTrailBars = Bars;
         //return;
      }//if (OldRecoverTrailBars != Bars)
      
      //Has the market retraced to the recovery stop loss
      target = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
      
      if (Ask <= target)
      {         
         ForceAllTradeDeletion = true;
         CloseAllTrades();
         ObjectDelete(breakevenlinename);
         return;
      }//if (Ask <= target)
   }//if (OrderType() == OP_BUY)
   
   //The most recent trade selected in CountOpenTrades will show the type of trades involved
   if (SellOpen)
   {
      //Should breakeven line be replaced by trailing stop line
      //Irrelevant if be line has been deleted
      if (ObjectFind(breakevenlinename) > -1)
      {
         target = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
         if (Bid <= target - (RecoveryTrailingStopAt * Point) )
         {            
            ObjectDelete(breakevenlinename);
            ObjectCreate(breakevenlinename, 1,0,TimeCurrent(),target);
            ObjectSet(breakevenlinename,OBJPROP_COLOR,RecoveryStopLossLineColour);
            ObjectSet(breakevenlinename,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSet(breakevenlinename,OBJPROP_WIDTH,2);     
            //return;
         }//if (Bid <= target - (RecoveryTrailingStopAt * Point) )
      }//if (ObjectFind(breakevenlinename) > -1)
      
      
      //Abort the function if be line is wrong colour
      if (ObjectGet(breakevenlinename, OBJPROP_COLOR) != RecoveryStopLossLineColour) return;
      
      
      
      //Move the stop at each new candle
      if (OldRecoverTrailBars != Bars)
      {
         target = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
         if (High[1] < target)
         {
            ObjectMove(breakevenlinename, 0, TimeCurrent(), High[1]);         
         }//if (High[1] < target)
         OldRecoverTrailBars = Bars;
         //return;
      }//if (OldRecoverTrailBars != Bars)
      
      //Has the market retraced to the recovery stop loss
      target = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
      //Alert("Target = ", target);
      if (Bid >= target)
      {
         ForceAllTradeDeletion = true;
         CloseAllTrades();
         ObjectDelete(breakevenlinename);
         return;
      }//if (Bid >= target)
   }//if (OrderType() == OP_SELL)
   
   

}//End void RecoveryCandlesticktrailingStop()

void CloseAllTrades()
{
   ForceAllTradeDeletion = false;
   
   if (OrdersTotal() == 0) return;
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() )
      {
         while(IsTradeContextBusy()) Sleep(100);
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 1000, CLR_NONE);
         if (result) cc++;
         if (!result) ForceAllTradeDeletion = true;
      }//if (OrderSymbol() == Symbol() )
   
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)


}//End void CloseAllTrades()



void TradeManagementModule()
{

   // Call the working subroutines one by one. 

   //Candlestick trailing stop
   if (UseCandlestickTrailingStop) CandlestickTrailingStop();

   // Hidden stop loss
   if (HideStopLossEnabled) HiddenStopLoss();

   // Hidden take profit
   if (HideTakeProfitEnabled) HiddenTakeProfit();

   // Breakeven
   if(BreakEven) BreakEvenStopLoss();

   // JumpingStop
   if(JumpingStop) JumpingStopLoss();

   //TrailingStop
   if(TrailingStop) TrailingStopLoss();

   

}//void TradeManagementModule()
//END TRADE MANAGEMENT MODULE
////////////////////////////////////////////////////////////////////////////////////////////////

bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
{
   
   
   int slippage = 10;
   if (Digits == 3 || Digits == 5) slippage = 100;
   
   color col = Red;
   if (type == OP_BUY || type == OP_BUYSTOP) col = Green;
   
   int expiry = 0;
   //if (SendPendingTrades) expiry = TimeCurrent() + (PendingExpiryMinutes * 60);

   if (!CriminalIsECN) int ticket = OrderSend(Symbol(),type, lotsize, price, slippage, stop, take, comment, MagicNumber, expiry, col);
   
   
   //Is a 2 stage criminal
   if (CriminalIsECN)
   {
      bool result;
      int err;
      ticket = OrderSend(Symbol(),type, lotsize, price, slippage, 0, 0, comment, MagicNumber, expiry, col);
      if (ticket > 0)
      {
	     
	     if (take > 0 && stop > 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), stop, take, OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL/TP  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take > 0 && stop > 0)
      
	     if (take != 0 && stop == 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take == 0 && stop != 0)

        if (take == 0 && stop != 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take == 0 && stop != 0)

      }//if (ticket > 0)
        
      
      
   }//if (CriminalIsECN)
   
   //Error trapping for both
   if (ticket < 0)
   {
      string stype;
      if (type == OP_BUY) stype = "OP_BUY";
      if (type == OP_SELL) stype = "OP_SELL";
      if (type == OP_BUYLIMIT) stype = "OP_BUYLIMIT";
      if (type == OP_SELLLIMIT) stype = "OP_SELLLIMIT";
      if (type == OP_BUYSTOP) stype = "OP_BUYSTOP";
      if (type == OP_SELLSTOP) stype = "OP_SELLSTOP";
      err=GetLastError();
      Alert(Symbol(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
      Print(Symbol(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
      return(false);
   }//if (ticket < 0)  
   
   
   TicketNo = ticket;
   //Make sure the trade has appeared in the platform's history to avoid duplicate trades.
   //My mod of Matt's code attempts to overcome the bastard crim's attempts to overcome Matt's code.
   bool TradeReturnedFromCriminal = false;
   while (!TradeReturnedFromCriminal)
   {
      TradeReturnedFromCriminal = O_R_CheckForHistory(ticket);
      if (!TradeReturnedFromCriminal)
      {
         Alert(Symbol(), " sent trade not in your trade history yet. Turn of this ea NOW.");
      }//if (!TradeReturnedFromCriminal)
   }//while (!TradeReturnedFromCriminal)
   
   //Got this far, so trade send succeeded
   return(true);
   
}//End bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)

bool DoesTradeExist(int type)
{
   
   TicketNo = -1;
   
   if (OrdersTotal() == 0) return(false);
   
   for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)
   {
      if (!OrderSelect(cc,SELECT_BY_POS)) continue;
      
      if (OrderMagicNumber()==MagicNumber && OrderSymbol() == Symbol() )      
      {
         TicketNo = OrderTicket();
         if (OrderType() == type) return(true);         
      }//if (OrderMagicNumber()==MagicNumber && OrderSymbol() == Symbol() )      
   }//for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)

   return(false);

}//End bool DoesTradeExist(int type)


bool DirectionEstablished()
{
   //Looks at the close of the previous SequenceMinimuCandles to see if there has been a continuous move in one direction.
   //Returns true if so, else false
   //Also sets TradeDirection to down if all candles rose, or up if all candles fell
   
   int cc;
   int loop = CandlesInSeries;
   //Look for a rising sequence
   TradeDirection = down;
   for (cc = 1; cc <= loop; cc++)
   {
      if (MathAbs(Open[cc] - Close[cc]) < MinimumCandleBodySize * Point)
      {
         loop++; continue;
      }
      if (MathAbs(Open[cc] - Close[cc]) >= MinimumCandleBodySize * Point)
      {
         if (Close[cc] < Open[cc] )
         {
            TradeDirection = none; break;
         }
      }//if (MathAbs(Open[cc] - Close[cc]) < MinimumCandleBodySize * Point)         
   }//for (cc = 1; cc <= SequenceMinimuCandles; cc++)   
   if (TradeDirection == down) return(true);
   
   //Look for a falling sequence
   loop = CandlesInSeries;
   TradeDirection = up;
   for (cc = 1; cc <= loop; cc++)
   {
      if (MathAbs(Open[cc] - Close[cc]) < MinimumCandleBodySize * Point)
      {
         loop++; continue;
      }
      if (MathAbs(Open[cc] - Close[cc]) >= MinimumCandleBodySize * Point)
      {
         if (Close[cc] > Open[cc] )
         {
            TradeDirection = none; break;
         }
      }//if (MathAbs(Open[cc] - Close[cc]) < MinimumCandleBodySize * Point)
      
   }//for (cc = 1; cc <= SequenceMinimuCandles; cc++)   
   if (TradeDirection == up) return(true);
   
   //Got this far, so no relevant sequence of closes
   TradeDirection = none;
   return(false);

}//End bool DirectionEstablished()


void TradeDirectionBySwap()
{

   //Sets TradeLong & TradeShort according to the positive/negative swap it attracts

   double LongSwap = MarketInfo(Symbol(), MODE_SWAPLONG);
   double ShortSwap = MarketInfo(Symbol(), MODE_SWAPSHORT);
   

   if (CadPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "CAD" || StringSubstr(Symbol(), 0, 3) == "cad" || StringSubstr(Symbol(), 3, 3) == "CAD" || StringSubstr(Symbol(), 3, 3) == "cad" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr(Symbol(), 0, 3) == "CAD" || StringSubstr(Symbol(), 0, 3) == "cad" )      
   }//if (CadPairsPositiveOnly)
   
   if (AudPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
   }//if (AudPairsPositiveOnly)
   
   
   if (NzdPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "NZD" || StringSubstr(Symbol(), 0, 3) == "nzd" || StringSubstr(Symbol(), 3, 3) == "NZD" || StringSubstr(Symbol(), 3, 3) == "nzd" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
   }//if (AudPairsPositiveOnly)
   
   

}//void TradeDirectionBySwap()

bool IsThisPairTradable()
{
   //Checks to see if either of the currencies in the pair is already being traded twice.
   //If not, then return true to show that the pair can be traded, else return false
   
   string c1 = StringSubstr(Symbol(), 0, 3);//First currency in the pair
   string c2 = StringSubstr(Symbol(), 3, 3);//Second currency in the pair
   int c1open = 0, c2open = 0;
   CanTradeThisPair = true;
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() != Symbol() ) continue;
      int index = StringFind(OrderSymbol(), c1);
      if (index > -1)
      {
         c1open++;         
      }//if (index > -1)
   
      index = StringFind(OrderSymbol(), c2);
      if (index > -1)
      {
         c2open++;         
      }//if (index > -1)
   
      if (c1open == 1 && c2open == 1) 
      {
         CanTradeThisPair = false;
         return(false);   
      }//if (c1open == 1 && c2open == 1) 
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //Got this far, so ok to trade
   return(true);
   
}//End bool IsThisPairTradable()


bool IsTradingAllowed()
{
   //Returns false if any of the filters should cancel trading, else returns true to allow trading
   
      
   //Maximum spread
   if (MarketInfo(Symbol(), MODE_SPREAD) > MaxSpread) return(false);
 
 
   //Swap filter
   if (OpenTrades == 0) TradeDirectionBySwap();

   //An individual currency can only be traded twice, so check for this
   CanTradeThisPair = true;
   if (OnlyTradeCurrencyTwice && OpenTrades == 0)
   {
      IsThisPairTradable();      
   }//if (OnlyTradeCurrencyTwice)
   if (!CanTradeThisPair) return(false);
   
   //Swap filter
   if (OpenTrades == 0) TradeDirectionBySwap();
   
   //Inside bar trigger
   if (UseInsideBarTrigger && OpenTrades == 0)
   {
      if (Low[1] < Low[2] || High[1] > High[2]) return(false);//Not an inside bar
   }//if (UseInsideBarTrigger)
   
   
   return(true);


}//End bool IsTradingAllowed()


void LookForTradingOpportunities()
{

   //Check to see if enough candles have gone in one direction to trigger a trade
   if (!DirectionEstablished() ) return;
   //Check other filters
   if (!IsTradingAllowed() ) return;
   
   RefreshRates();
   double take, stop, price, reentryprice;
   int type;
   bool SendTrade;

   double SendLots = Lot;
   //Using Recovery
   double target = ObjectGet(reentrylinename, OBJPROP_PRICE1);
   //This idea from Pippo   
   if (UseRecovery)
   {
      if (RecoveryInProgress)
      {
         if (OpenTrades == 2) 
         {
            if (Use1.1.2.4Recovery) SendLots = Lot * 2;         
            if (Use1.1.3.3Recovery) SendLots = Lot * 3;         
         }//if (OpenTrades == 2) 
      
         if (OpenTrades == 3) 
         {
            if (Use1.1.2.4Recovery) SendLots = Lot * 4;
            if (Use1.1.3.3Recovery) SendLots = Lot * 3;
         }//if (OpenTrades == 3) 
      
         if (OpenTrades == 4) return;//No further trading is possible
      
      
      }//if (RecoveryInProgress)
      
      if (Use1.2.6Recovery && OpenTrades + 1 >= Start_Recovery_at_trades)
      {
         if (OpenTrades == Start_Recovery_at_trades - 1) SendLots = Lot * 2;
         if (OpenTrades == Start_Recovery_at_trades) SendLots = Lot * 6;
         if (OpenTrades == Start_Recovery_at_trades + 1) return;      
      }//if (Use1.2.6Recovery)
   
   }//if (UseRecovery)

   //Trend
   string Ttrend = trend;//Temp trend string
      

   //Long 
   //if (TradeDirection == up && !DoesTradeExist(OP_SELL) && (Ttrend == up || Ttrend == ranging) )
   if (TradeLong && TradeDirection == up && !DoesTradeExist(OP_SELL) && (Ttrend == up || (!UseTrendDetection && Ttrend == ranging)) )
   {
      
      if (UseHanover && !HanoverFilter(OP_BUY) ) return(false);

      //Balanced pair trade filter. Only apply to pre-recovery trades
      if (OpenTrades + 1 < Start_Recovery_at_trades || !UseRecovery)
      {
         if (UseZeljko && !BalancedPair(OP_BUY) ) return;
      }//if (OpenTrades + 1 < Start_Recovery_at_trades)
      if (target > 0 && Ask > target) return;//In case of reentry for Recovery
      if (TakeProfit > 0) take = NormalizeDouble(Ask + (TakeProfit * Point), Digits);
      if (StopLoss > 0) stop = NormalizeDouble(Ask - (StopLoss * Point), Digits);
      //Will this be a hedge trade?
      if (DoesTradeExist(OP_SELL) )
      {
          if(!UseHedging || HedgingInProgress) return;//Only hedge once
          SendLots = TotalLotsOpen * HedgeLotMultiplier;
          stop = 0;
          take = 0;
      }//if (DoesTradeExist(OP_SELL) )
      type = OP_BUY;
      price = Ask;
      reentryprice = NormalizeDouble(price - (ReEntryLinePips * Point), Digits);
      SendTrade = true;
   }//if (TradeDirection == up)
   

   //Short
   //if (TradeDirection == down && !DoesTradeExist(OP_BUY) && (Ttrend == down || Ttrend == ranging) )
   if (TradeShort && TradeDirection == down && !DoesTradeExist(OP_BUY) && (Ttrend == down || (!UseTrendDetection && Ttrend == ranging)) )
   {
      if (UseHanover && !HanoverFilter(OP_SELL) ) return(false);
      
      //Balanced pair trade filter. Only apply to pre-recovery trades
      if (OpenTrades + 1 < Start_Recovery_at_trades || !UseRecovery)
      {
         if (UseZeljko && !BalancedPair(OP_SELL) ) return;
      }//if (OpenTrades + 1 < Start_Recovery_at_trades)
      if (target > 0 && Bid < target) return;//In case of reentry for Recovery
      if (TakeProfit > 0) take = NormalizeDouble(Bid - (TakeProfit * Point), Digits);
      if (StopLoss > 0) stop = NormalizeDouble(Bid + (StopLoss * Point), Digits);
      type = OP_SELL;
      //Will this be a hedge trade?
      if (DoesTradeExist(OP_BUY) )
      {
          if(!UseHedging || HedgingInProgress) return;//Only hedge once
          SendLots = TotalLotsOpen * HedgeLotMultiplier;
          stop = 0;
          take = 0;
      }//if (DoesTradeExist(OP_BUY) )
      price = Bid;
      reentryprice = NormalizeDouble(price + (ReEntryLinePips * Point), Digits);
      SendTrade = true;      
   }//if (TradeDirection == down)
   

   if (SendTrade)
   {
      bool result = SendSingleTrade(type, TradeComment, SendLots, price, stop, take);
   }//if (SendTrade)
   
   //Actions when trade send succeeds
   if (SendTrade && result)
   {
      AddReEntryLine(reentryprice);
   }//if (result)
   
   //Actions when trade send fails
   if (SendTrade && !result)
   {
      OldBars = 0;
   }//if (!result)
   
   

}//void LookForTradingOpportunities()

bool BalancedPair(int type)
{

   //Only allow an individual currency to trade if it is a balanced trade
   //e.g. UJ Buy open, so only allow Sell xxxJPY.
   //The passed parameter is the proposed trade, so an existing one must balance that

   //This code courtesy of Zeljko (zkucera) who has my grateful appreciation.
   
   string BuyCcy1, SellCcy1, BuyCcy2, SellCcy2;

   if (type == OP_BUY || type == OP_BUYSTOP)
   {
      BuyCcy1 = StringSubstr(Symbol(), 0, 3);
      SellCcy1 = StringSubstr(Symbol(), 3, 3);
   }//if (type == OP_BUY || type == OP_BUYSTOP)
   else
   {
      BuyCcy1 = StringSubstr(Symbol(), 3, 3);
      SellCcy1 = StringSubstr(Symbol(), 0, 3);
   }//else

   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS)) continue;
      if (OrderSymbol() == Symbol()) continue;
      if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP)
      {
         BuyCcy2 = StringSubstr(OrderSymbol(), 0, 3);
         SellCcy2 = StringSubstr(OrderSymbol(), 3, 3);
      }//if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP)
      else
      {
         BuyCcy2 = StringSubstr(OrderSymbol(), 3, 3);
         SellCcy2 = StringSubstr(OrderSymbol(), 0, 3);
      }//else
      if (BuyCcy1 == BuyCcy2 || SellCcy1 == SellCcy2) return(false);
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //Got this far, so it is ok to send the trade
   return(true);

}//End bool BalancedPair(int type)

bool CloseTrade(int ticket)
{   
   while(IsTradeContextBusy()) Sleep(100);
   bool result = OrderClose(ticket, OrderLots(), OrderClosePrice(), 1000, CLR_NONE);

   //Actions when trade send succeeds
   if (result)
   {
      return(true);
   }//if (result)
   
   //Actions when trade send fails
   if (!result)
   {
      return(false);
   }//if (!result)
   

}//End bool CloseTrade(ticket)


void LookForTradeClosure()
{
   //Close the trade if the new candle opens inside the bands
   
   if (!OrderSelect(TicketNo, SELECT_BY_TICKET) ) return;
   if (OrderSelect(TicketNo, SELECT_BY_TICKET) && OrderCloseTime() > 0) return;
   
   bool CloseTrade;
   
   if (OrderType() == OP_BUY)
   {

   }//if (OrderType() == OP_BUY)
   
   
   if (OrderType() == OP_SELL)
   {

   }//if (OrderType() == OP_SELL)
   
   if (CloseTrade)
   {
      bool result = CloseTrade(TicketNo);
      //Actions when trade send succeeds
      if (result)
      {
   
      }//if (result)
   
      //Actions when trade send fails
      if (!result)
      {
   
      }//if (!result)
   

   }//if (CloseTrade)
   
   
}//void LookForTradeClosure()


bool CheckTradingTimes()
{
   int hour = TimeHour(TimeLocal() );
   
   if (end_hourm < start_hourm)
	{
		end_hourm += 24;
	}
	

	if (end_houre < start_houre)
	{
		end_houre += 24;
	}
	
	bool ok2Trade = true;
	
	ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);

	// adjust for past-end-of-day cases
	// eg in AUS, USDJPY trades 09-17 and 22-06
	// so, the above check failed, check if it is because of this condition
	if (!ok2Trade && hour < 12)
	{
 		hour += 24;
		ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);		
		// so, if the trading hours are 11pm - 6am and the time is between  midnight to 11am, (say, 5am)
		// the above code will result in comparing 5+24 to see if it is between 23 (11pm) and 30(6+24), which it is...
	}


   // check for end of day by looking at *both* end-hours

   if (hour >= MathMax(end_hourm, end_houre))
   {      
      ok2Trade = false;
   }//if (hour >= MathMax(end_hourm, end_houre))

   return(ok2Trade);

}//bool CheckTradingTimes()

void CountOpenTrades()
{
   OpenTrades = 0;
   TicketNo = -1;
   BuyOpen = false;
   SellOpen = false;
   RecoveryInProgress = false;
   HedgingInProgress = false;
   BasketUpl = 0;
   TotalLotsOpen = 0;

   if (OrdersTotal() == 0) return;
   
   for (int cc = 0; cc <= OrdersTotal(); cc++)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         OpenTrades++;
         TicketNo = OrderTicket();   
         if (OrderType() == OP_BUY) BuyOpen = true;
         if (OrderType() == OP_SELL) SellOpen = true;         
         if (OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            BasketUpl++;
            TotalLotsOpen+= OrderLots();
         }//if (OrderType() == OP_BUY || OrderType() == OP_SELL)
         
         if (ObjectFind(breakevenlinename) > -1)
         {
            double take = ObjectGet(breakevenlinename, OBJPROP_PRICE1);
            if (OrderTakeProfit() != take && (OrderType() == OP_BUY || OrderType() == OP_SELL) && !UseRecoveryTrailingStop)
            {
               while(IsTradeContextBusy()) Sleep(100);
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);
            }//if (OrderTakeProfit() != take && (OrderType() == OP_BUY || OrderType() == OP_SELL) )
            //Remove unwanted tp
            if (UseRecoveryTrailingStop && OrderTakeProfit() > 0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), 0, OrderExpiration(), CLR_NONE);
         }//if (ObjectFind(breakevenlinename) > -1)

      }//if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
   }//for (int cc = 0; cc < OrdersTotal() - 1; cc++)
   
   if (OpenTrades >= Start_Recovery_at_trades) 
   {
      RecoveryInProgress = true;
      RecoveryModule();//Draws a breakeven line if not already drawn
   }//if (OpenTrades >= Start_Recovery_at_trades) 
   
   //Management
   if (OpenTrades == 1)
   {
      if (!OrderSelect(TicketNo, SELECT_BY_TICKET) ) return;
      if (OrderCloseTime() > 0) return;
      if (OrderProfit() > 0) TradeManagementModule();         
   }//if (OpenTrades == 1)
   
   //Hedging
   if (BuyOpen && SellOpen) HedgingInProgress = true;
   
}//End void CountOpenTrades();

//=============================================================================
//                           O_R_CheckForHistory()
//
//  This function is to work around a very annoying and dangerous bug in MT4:
//      immediately after you send a trade, the trade may NOT show up in the
//      order history, even though it exists according to ticket number.
//      As a result, EA's which count history to check for trade entries
//      may give many multiple entries, possibly blowing your account!
//
//  This function will take a ticket number and loop until
//  it is seen in the history.
//
//  RETURN VALUE:
//     TRUE if successful, FALSE otherwise
//
//
//  FEATURES:
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Displays various error messages on the log for debugging.
//
//  ORIGINAL AUTHOR AND DATE:
//     Matt Kennel, 2010
//
//=============================================================================
bool O_R_CheckForHistory(int ticket)
{
   //My thanks to Matt for this code. He also has the undying gratitude of all users of my trading robots
   
   int lastTicket = OrderTicket();

   int cnt = 0;
   int err = GetLastError(); // so we clear the global variable.
   err = 0;
   bool exit_loop = false;
   bool success=false;

   while (!exit_loop) {
      /* loop through open trades */
      int total=OrdersTotal();
      for(int c = 0; c < total; c++) {
         if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES) == true) {
            if (OrderTicket() == ticket) {
               success = true;
               exit_loop = true;
            }
         }
      }
      if (cnt > 3) {
         /* look through history too, as order may have opened and closed immediately */
         total=OrdersHistoryTotal();
         for(c = 0; c < total; c++) {
            if(OrderSelect(c,SELECT_BY_POS,MODE_HISTORY) == true) {
               if (OrderTicket() == ticket) {
                  success = true;
                  exit_loop = true;
               }
            }
         }
      }

      cnt = cnt+1;
      if (cnt > O_R_Setting_max_retries) {
         exit_loop = true;
      }
      if (!(success || exit_loop)) {
         Print("Did not find #"+ticket+" in history, sleeping, then doing retry #"+cnt);
         O_R_Sleep(O_R_Setting_sleep_time, O_R_Setting_sleep_max);
      }
   }
   // Select back the prior ticket num in case caller was using it.
   if (lastTicket >= 0) {
      OrderSelect(lastTicket, SELECT_BY_TICKET, MODE_TRADES);
   }
   if (!success) {
      Print("Never found #"+ticket+" in history! crap!");
   }
   return(success);
}//End bool O_R_CheckForHistory(int ticket)

//=============================================================================
//                              O_R_Sleep()
//
//  This sleeps a random amount of time defined by an exponential
//  probability distribution. The mean time, in Seconds is given
//  in 'mean_time'.
//  This returns immediately if we are backtesting
//  and does not sleep.
//
//=============================================================================
void O_R_Sleep(double mean_time, double max_time)
{
   if (IsTesting()) {
      return;   // return immediately if backtesting.
   }

   double p = (MathRand()+1) / 32768.0;
   double t = -MathLog(p)*mean_time;
   t = MathMin(t,max_time);
   int ms = t*1000;
   if (ms < 10) {
      ms=10;
   }
   Sleep(ms);
}//End void O_R_Sleep(double mean_time, double max_time)

void GetStats()
{

   /*
   - There is a declared array of Candle[50].
   - Each variable holds the number of times that the candles have moved in one direction before the next one reverses
     so Candle[3] = 5 means that there have been 5 instances of candles moving in one direction three times before reversing
   - HighestSequence holds the highest number of moves in one direction before a reverse
   - CommonFrequency holds the most common no of candles in one direction before a reverse
   - CalculationCandlesCount is the number of previous candles to involve in the calculation and is a user input
   - SequenceMinimuCandles is the minimum number of candles to accept as the CalculationCandlesCount if the count is automated
   */

   //Initialise the variables 
   ArrayInitialize(Candle, 0);
   HighestSequence = 0;
   CommonFrequency = 0;
   DiscardedCandles = 0;
   
   int CandleTotalInSequence = 0;//Candles Total in the same direction
   
   //Get the direction of the first candle
   string direction = none;
   if (Close[CalculationCandlesCount] > Open[CalculationCandlesCount] ) {direction = up; CandleTotalInSequence++; Candle[1]++;}
   if (Close[CalculationCandlesCount] < Open[CalculationCandlesCount] ) {direction = down; CandleTotalInSequence++; Candle[1]++;}
   
   //Loop through the candles and make the calculations
   for (int cc = CalculationCandlesCount - 1; cc > 0; cc--)
   {
      //Minimum body length for consideration
      if (MathAbs(Open[cc] - Close[cc]) < MinimumCandleBodySize * Point)
      {
         DiscardedCandles++;
         continue;
      }//if (MathAbs(Open[cc] - Close[cc]) < MinimumCandleBodySize * Point)
      
      
      //Direction of candle being examined
      string CandleDirection = none;
      if (Close[cc] > Open[cc] ) CandleDirection = up;
      if (Close[cc] < Open[cc] ) CandleDirection = down;
      
      
      //If this candle has moved in the same direction as the previous, then increment CandleTotalInSequence
      if (CandleDirection == direction && CandleDirection != none)
      {
         CandleTotalInSequence++;
      }//if (CandleDirection == direction && CandleDirection != none)
      
      //Candle has not moved in same direction as previous candle, so update stats
      if (CandleDirection != direction && CandleDirection != none)
      {
         Candle[CandleTotalInSequence]++;
         if (CandleTotalInSequence > HighestSequence) HighestSequence = CandleTotalInSequence;
         
         //Re-initialise CandleTotalInSequence
         CandleTotalInSequence = 1;
         direction = CandleDirection;
      }//if (CandleDirection != direction && CandleDirection != none)
      
   }//for (int cc = CalculationCandlesCount + 1; cc >= 0; cc--;)
   //Calculate the most common frequency
   int mc = 0;
   for (cc = SequenceMinimuCandles; cc <= ArraySize(Candle) + 1; cc++)
   {
      if (Candle[cc] > mc)
      {
         CommonFrequency = cc;
         mc = Candle[cc];
      }//if (Candle[cc] > mc)      
   }//for (cc = 1; cc >= ArraySize(Candle); cc++)
   
   //CandlesInSeries is a user input, so adapt it to auto-calculating
   CandlesInSeries = CommonFrequency;

}//End void GetStats()


void RecoveryModule()
{
   
   //Draw a breakeven line if there is not one in place already.
   //The bot will adjust the tp's during the CountOpenTrades function.

   if (ObjectFind(breakevenlinename) > -1) return;
   
   //Do not need a breakeven line if Recovery is already at be
   //if (ObjectFind(breakevenlinename) > -1) return;
   
   
   buy_price = 0;
   sell_price = 0;
   CheckRecoveryTakeProfit();
   double recovery_profit;
   if (buy_price > 0) 
   {
      recovery_profit = buy_price;
      recovery_profit = NormalizeDouble(buy_price + (RecoveryBreakEvenProfitPips * Point), Digits);
   }//if (buy_price > 0) 
   
   if (sell_price > 0) 
   {
      recovery_profit = sell_price;
      recovery_profit = NormalizeDouble(sell_price - (RecoveryBreakEvenProfitPips * Point), Digits);
   }//if (sell_price > 0) 

   ObjectCreate(breakevenlinename,OBJ_HLINE,0,TimeCurrent(), recovery_profit );
   ObjectSet(breakevenlinename,OBJPROP_COLOR,BreakEvenLineColour);
   ObjectSet(breakevenlinename,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(breakevenlinename,OBJPROP_WIDTH,2);
   
}//End void RecoveryModule()

void CheckRecoveryTakeProfit()
{
   //This is adapted from the NB iExposure indicator. I do not understand how it works.
   //There will be redundant code, so anybody wishing to clear it up is most welcome to do so.
   
   ExtLines = 0;
   int    i,col,line;

   ArrayInitialize(ExtSymbolsSummaries,0.0);
   int total=Analyze();
   if(total>0)
   {
      line=0;
      for(i=0; i<ExtSymbolsTotal; i++)
      {
         if (ExtSymbols[i] != Symbol() ) continue;
         if(ExtSymbolsSummaries[i][DEALS]<=0) continue;
         line++;
         //---- add line
         if(line>ExtLines)
         {
            int y_dist=ExtVertShift*(line+1)+1;
            /*for(col=0; col<8; col++)
              {
               name="Line_"+line+"_"+col;
               if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
                 {
                  ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
                  ObjectSet(name,OBJPROP_YDISTANCE,y_dist);
                 }
              }*/
            ExtLines++;
         }//if(line>ExtLines)
         //---- set line
         //color  price_colour;//Steve mod
         int    digits=MarketInfo(ExtSymbols[i],MODE_DIGITS);
         double buy_lots=ExtSymbolsSummaries[i][BUY_LOTS];
         double sell_lots=ExtSymbolsSummaries[i][SELL_LOTS];
         if(buy_lots!=0)  buy_price=NormalizeDouble(ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots, Digits);
         if(sell_lots!=0) sell_price=NormalizeDouble(ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots, Digits);
         
      }//for(i=0; i<ExtSymbolsTotal; i++)
   }//if(total>0)


}//End void CheckRecoveryTakeProfit()

int Analyze()
{
   double profit;
   int    i,index,type,total=OrdersTotal();
//----
   for(i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      type=OrderType();
      if(type!=OP_BUY && type!=OP_SELL) continue;
      index=SymbolsIndex(OrderSymbol());
      if(index<0 || index>=SYMBOLS_MAX) continue;
      //----
      ExtSymbolsSummaries[index][DEALS]++;
      profit=OrderProfit()+OrderCommission()+OrderSwap();
      ExtSymbolsSummaries[index][PROFIT]+=profit;
      if(type==OP_BUY)
        {
         ExtSymbolsSummaries[index][BUY_LOTS]+=OrderLots();
         ExtSymbolsSummaries[index][BUY_PRICE]+=OrderOpenPrice()*OrderLots();
        }
      else
        {
         ExtSymbolsSummaries[index][SELL_LOTS]+=OrderLots();
         ExtSymbolsSummaries[index][SELL_PRICE]+=OrderOpenPrice()*OrderLots();
        }
     }
//----
   total=0;
   for(i=0; i<ExtSymbolsTotal; i++)
     {
      if(ExtSymbolsSummaries[i][DEALS]>0) total++;
     }
//----
   return(total);
}//int Analyze()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SymbolsIndex(string SymbolName)
{
   bool found=false;
//----
   for(int i=0; i<ExtSymbolsTotal; i++)
     {
      if(SymbolName==ExtSymbols[i])
        {
         found=true;
         break;
        }
     }
//----
   if(found) return(i);
   if(ExtSymbolsTotal>=SYMBOLS_MAX) return(-1);
//----
   i=ExtSymbolsTotal;
   ExtSymbolsTotal++;
   ExtSymbols[i]=SymbolName;
   ExtSymbolsSummaries[i][DEALS]=0;
   ExtSymbolsSummaries[i][BUY_LOTS]=0;
   ExtSymbolsSummaries[i][BUY_PRICE]=0;
   ExtSymbolsSummaries[i][SELL_LOTS]=0;
   ExtSymbolsSummaries[i][SELL_PRICE]=0;
   ExtSymbolsSummaries[i][NET_LOTS]=0;
   ExtSymbolsSummaries[i][PROFIT]=0;
//----
   return(i);
}//End int SymbolsIndex(string SymbolName)

void AddReEntryLine(double price)
{
   if (ObjectFind(reentrylinename) > -1) ObjectDelete(reentrylinename);   
   
   
   if (!ObjectCreate(reentrylinename,OBJ_HLINE,0,TimeCurrent(),price) )
   {
      int err=GetLastError();      
      Alert("Re-entry line draw failed with error(",err,"): ",ErrorDescription(err));
      Print("Re-entry line draw failed with error(",err,"): ",ErrorDescription(err));
      return(0);

   }//if (!ObjectCreate(reentrylinename,OBJ_HLINE,0,TimeCurrent(),price) )
   
   ObjectSet(reentrylinename,OBJPROP_COLOR,ReEntryLineColour);
   ObjectSet(reentrylinename,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(reentrylinename,OBJPROP_WIDTH,2);     


}//void AddReEntryLine(int type, double price)

void ReplaceReEntryLine()
{

   //Find the most recent trade in the sequence and replace the missing re-entry line
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {      
      if (OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) )
      {
         if (OrderSymbol() == Symbol())
         {            
            if (OrderType() == OP_BUY) AddReEntryLine(NormalizeDouble(OrderOpenPrice() - (ReEntryLinePips * Point), Digits) );
            if (OrderType() == OP_SELL) AddReEntryLine(NormalizeDouble(OrderOpenPrice() + (ReEntryLinePips * Point), Digits) );
            return;
         }//if (OrderSymbol() == Symbol() && OrderCloseTime() == 0)      
         
      }//if (OrderSelect(cc, SELECT_BY_POS) )
      
   }//for (cc = OpenTrades; cc >= 0; cc--)
            


}//void ReplaceReEntryLine()

///////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend detection module
double GetRsi(int tf, int period, int ap, int shift)
{
   return(iRSI(NULL, tf, period, ap, shift) );
}//End double GetRsi(int tf, int period, int ap, int shift)



double GetMa(int tf, int period, int mashift, int method, int ap, int shift)
{
   return(iMA(NULL, tf, period, mashift, method, ap, shift) );
}//End double GetMa(int tf, int period, int mashift, int method, int ap, int shift)

void TrendDetectionModule()
{

   //Define the trend according to the user's choices.
   //Only called if UseTrendDetection is set to true
   trend = ranging;//Default
   
   //Rsi. This one is scooby-doo's suggestion and is based on a 20 period D1 Rsi.
   if (UseRsiTrendDetection)
   {
      TrendRsiVal = GetRsi(RsiTdTf, RsiTdPeriod, RsiTdAppliedPrice, 0);
      if (TrendRsiVal > 55) trend = up;
      if (TrendRsiVal < 45) trend = down;
   }//if (UseRsiTrendDetection)
   
   //'slowkey' - double moving average.
   //Slow MA > Fast MA - trend is up and vice versa
   if (UseSlowkey)
   {
      FastTrendMaVal = GetMa(FastMaTdTF, FastMaTdPeriod, FastMaTdShift, FastMaTdMethod, FastMaTdAppliedPrice, 0);   
      SlowTrendMaVal = GetMa(SlowMaTdTF, SlowMaTdPeriod, SlowMaTdShift, SlowMaTdMethod, SlowMaTdAppliedPrice, 0); 
      if (FastTrendMaVal > SlowTrendMaVal) trend = up;
      if (FastTrendMaVal < SlowTrendMaVal) trend = down;
   }//if (UseSlowkey)

   /*
   I picked this up from the book 'Trading Day by Day - Winning the Zero Sum Game' by FH Goslin.
   10 week MA is rising - trend is up.
   10 week MA is falling - trend is down.
   */
   if (UseMaTrendDetection)
   {
      SingleTrendMaVal = GetMa(SingleMaTdTF, SingleMaTdPeriod, SingleMaTdShift, SingleMaTdMethod, SingleMaTdAppliedPrice, 0);   
      PrevSingleTrendMaVal = GetMa(SingleMaTdTF, SingleMaTdPeriod, SingleMaTdShift, SingleMaTdMethod, SingleMaTdAppliedPrice, CompareWithCandles);   
      ConSingleTrendMaVal = GetMa(ConSingleMaTdTF, ConSingleMaTdPeriod, ConSingleMaTdShift, ConSingleMaTdMethod, ConSingleMaTdAppliedPrice, 0);   
      if (SingleTrendMaVal > PrevSingleTrendMaVal &&  SingleTrendMaVal - PrevSingleTrendMaVal >= (MinimumAcceptableMovement * Point) && ConSingleTrendMaVal > SingleTrendMaVal) trend = up;
      if (SingleTrendMaVal < PrevSingleTrendMaVal &&  PrevSingleTrendMaVal - SingleTrendMaVal >= (MinimumAcceptableMovement * Point) && ConSingleTrendMaVal < SingleTrendMaVal ) trend = down;      
   }//if (UseMaTrendDetection)
   
   
}//void TrendDetectionModule()


//End Trend detection module
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
//Hanover module
void SetUpArrays()
{
   //Sets up all the arrays required by this program

   int cc;
   int Index = 0;//For searching InputString
   int LastIndex = 0;//Points the the most recent Index
   

   //TimeFrames
   InputString = TimeFrames;
   CleanUpInputString();
   TimeFrames = InputString;
   NoOfTimeFrames = CalculateParamsPassed();
   string NewArray2 = ArrayResize(Tf, NoOfTimeFrames);
   
   Index = 0;//For searching InputString
   LastIndex = 0;//Points the the most recent Index
   for (cc = 0; cc < NoOfTimeFrames; cc ++)
   {
      Index = StringFind(InputString, ",",LastIndex);
      if (Index > -1)
      {
         Tf[cc] = StringSubstr(InputString, LastIndex,Index-LastIndex);
         Tf[cc] = StringTrimLeft(Tf[cc]);
         Tf[cc] = StringTrimRight(Tf[cc]);
         LastIndex = Index+1;
      }//if (Index > -1)      
   }//for (cc = 0; cc < NoOfTimeFrames; cc ++)

   //StrongWeak
   string NewArray3 = ArrayResize(StrongWeak, NoOfTimeFrames);
   string NewArray4 = ArrayResize(StrongestCcy, NoOfTimeFrames);
   string NewArray5 = ArrayResize(WeakestCcy, NoOfTimeFrames);
   double NewArray6 = ArrayResize(StrongVal, NoOfTimeFrames);
   double NewArray7 = ArrayResize(WeakVal, NoOfTimeFrames);
   double NewArray8 = ArrayResize(PrevStrongVal, NoOfTimeFrames);
   double NewArray9 = ArrayResize(PrevWeakVal, NoOfTimeFrames);
   double NewArray10 = ArrayResize(ConstructedPair, NoOfTimeFrames);
   
   
   
   
}//End void SetUpArrays()

void CleanUpInputString()
{
   // Does any tidying up of the user inputs
   
   //Remove unwanted spaces
   InputString = StringTrimLeft(InputString);
   InputString = StringTrimRight(InputString);

   //Add final comma if ommitted by user
   if (StringSubstr(InputString, StringLen(InputString)-1) != ",") 
      InputString = StringConcatenate(InputString,",");
      
   
}//void CleanUpInputString

int CalculateParamsPassed()
{
   // Calculates the numbers of paramaters passed in LongMagicNumber and TradeComment.
   
   int Index = 0;//For searching NoTradePairs
   int LastIndex;//Points the the most recent Index
   int NoOfParams = 0;
   
   while(Index > -1)
   {
      Index = StringFind(InputString, ",",LastIndex);
      if (Index > -1)
      {
         NoOfParams++;
         LastIndex = Index+1;            
      }//if (Index > -1)
   }//while(int cc > -1)
      
  return(NoOfParams);
}//int CalculateParamsPassed()


//+------------------------------------------------------------------+
string StringRight(string str, int n=1)
//+------------------------------------------------------------------+
// Returns the rightmost N characters of STR, if N is positive
// Usage:    string x=StringRight("ABCDEFG",2)  returns x = "FG"
//
// Returns all but the leftmost N characters of STR, if N is negative
// Usage:    string x=StringRight("ABCDEFG",-2)  returns x = "CDEFG"
{
  if (n > 0)  return(StringSubstr(str,StringLen(str)-n,n));
  if (n < 0)  return(StringSubstr(str,-n,StringLen(str)-n));
  return("");
}


//+------------------------------------------------------------------+
int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
{
  int c = 0;
  for (int i=0; i<StringLen(str); i++)
    if (StringSubstr(str,i,StringLen(str2)) == str2)  c++;
  return(c);
}


string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}  

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
string StringTrim(string str)
//+------------------------------------------------------------------+
// Removes all spaces (leading, traing embedded) from a string
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "TheQuickBrownFox"
{
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " ")
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}

//+------------------------------------------------------------------+
int StrToStringArray(string str, string &a[], string delim=",", string init="")  {
//+------------------------------------------------------------------+
// Breaks down a single string into string array 'a' (elements delimited by 'delim')
  for (int i=0; i<ArraySize(a); i++)
    a[i] = init;
  int z1=-1, z2=0;
  if (StringRight(str,1) != delim)  str = str + delim;
  for (i=0; i<ArraySize(a); i++)  {
    z2 = StringFind(str,delim,z1+1);
    a[i] = StringSubstr(str,z1+1,z2-z1-1);
    if (z2 >= StringLen(str)-1)   break;
    z1 = z2;
  }
  return(StringFindCount(str,delim));
}


//+------------------------------------------------------------------+
int ArrayLookupString(string str, string a[])   {
//+------------------------------------------------------------------+
 for (int i=0; i<ArraySize(a); i++)   {
   if (str == a[i])   return(i);
 }  
 return(-1);
} 

//+------------------------------------------------------------------+
double StrToNumber(string str)  {
//+------------------------------------------------------------------+
// Usage: strips all non-numeric characters out of a string, to return a numeric (double) value
//  valid numeric characters are digits 0,1,2,3,4,5,6,7,8,9, decimal point (.) and minus sign (-)
  int    dp   = -1;
  int    sgn  = 1;
  double num  = 0.0;
  for (int i=0; i<StringLen(str); i++)  {
    string s = StringSubstr(str,i,1);
    if (s == "-")  sgn = -sgn;   else
    if (s == ".")  dp = 0;       else
    if (s >= "0" && s <= "9")  {
      if (dp >= 0)  dp++;
      if (dp > 0)
        num = num + StrToInteger(s) / MathPow(10,dp);
      else
        num = num * 10 + StrToInteger(s);
    }
  }
  return(num*sgn);
}

int LoadRSvalues()  
{
  //This code courtesy of hanover. Many thanks David. You are a star.
  
  //Ccy[] holds the individual currency symbol
  //Tf[] holds the time frames
  //God knows where we go from here
  
  // Initialize array......
  for (i=0; i<8; i++)
    for (j=0; j<9; j++)
      for (k=0; k<99; k++)
         RSvalue[i][j][k] = 0;

         // Read data from Recent Strength export file into RSvalue array.......
         h = FileOpen(OutputFile,FILE_CSV|FILE_READ,'~');
         i=0; j=0; k=0;
         string prevtf = "";
         while (!FileIsEnding(h))     
         {
           StrToStringArray(FileReadString(h),arr);
           if (FileIsEnding(h))   break;
           if (arr[1] == "TF ")   
           {                                     // get ccy IDs from header record
             for (i=0; i<8; i++)  
             {
               ccy[i] = StringUpper(StringTrim(arr[i+3]));               
             }//for (i=0; i<8; i++)  
             continue;
           }//if (arr[1] == "TF ")   
           string currtf = StringUpper(StringTrimRight(arr[1]));
           j = ArrayLookupString(currtf,tf);
           if (j<0)     continue;                                    // unknown timeframe - should never happen
           if (currtf != prevtf)                                     // reset datapoint counter on change of timeframe
             k = 0;
           else
             k++;
           if (k>=99)   continue;                                    // max of 99 data points only
           for (i=0; i<8; i++)  
           {                                    // load array values for all currencies
             RSvalue[i][j][k] = StrToNumber(arr[i+3]);
             
           }//for (i=0; i<8; i++)  
           prevtf = currtf;  
         }//while (!FileIsEnding(h))     
  FileClose(h);
  return(0);
}//End int LoadRSvalues()  

void ReadHanover()
{
   //This function reads the output from the indi output file.
   LoadRSvalues();

/* Posted by hanover
If we use RSvalue[i][j][k], then
i = the currency
j = the timeframe
k = the datapoint#. Point #0 is rightmost point on the RS plot; point #1 is the second point from the right; 
point #2 is the third point from the right; and so on, up to the number of points being 
output (set by the NumPoints parameter in RS)

Hence, supposing you want to retrieve the value of the third datapoint for USD,H1, then (using the constants defined earlier) you could use the code:

double value = RSvalue[_USD][_H1][2];
*/
   //Find the strongest and weakest currency
   //Strongest
   double s, ps;//Strongest and previous strongest value
   double w, pw;//Weakest and previous weakest value


   //Currencies
   for (i = 0; i < ArraySize(StrongVal); i++)
   {
      StrongVal[i] = 0;//Initialize the strongest datapoint
      WeakVal[i] = 100000;//Initialize the weakest datapoint
   }//for (i = 0; i < ArraySize(StrongVal); i++)
   
   for (i = 0; i < ArraySize(ccy); i++)
   {
      //Timeframes
      for (j = 0; j < ArraySize(Tf); j++)
      {
         //Data point
         //Extract the timeframe - uses David's constants
         int DatapointTf;
         if (Tf[j] == "M1") DatapointTf = M1;
         if (Tf[j] == "M5") DatapointTf = M5;
         if (Tf[j] == "M15") DatapointTf = M15;
         if (Tf[j] == "M30") DatapointTf = M30;
         if (Tf[j] == "H1") DatapointTf = H1;
         if (Tf[j] == "H4") DatapointTf = H4;
         if (Tf[j] == "D1") DatapointTf = D1;
         if (Tf[j] == "W1") DatapointTf = W1;
         if (Tf[j] == "MN") DatapointTf = MN;
         
         for (k = 0; k < NumPoints; k++)
         {
            //Find the strongest datapoint on the current currency and timeframe
            if (RSvalue[i, DatapointTf, 0] > StrongVal[j])
            {
               StrongestCcy[j] = ccy[i];
               StrongVal[j] = RSvalue[i, DatapointTf, 0];
               PrevStrongVal[j] = RSvalue[i, DatapointTf, SlopeConfirmationCandles];
            }//if (RSvalue[i, j, k] > StrongVal[cc])
            
            //Find the seakest datapoint on the current currency and timeframe
            if (RSvalue[i, DatapointTf, 0] < WeakVal[j])
            {
               WeakestCcy[j] = ccy[i];
               WeakVal[j] = RSvalue[i, DatapointTf, 0];
               PrevWeakVal[j] = RSvalue[i, DatapointTf, SlopeConfirmationCandles];
            }//if (RSvalue[i, j, k] > StrongVal[cc])            
         }//for (k = 0; k <= NumPoints; k++)         
      }//for (j = 0; j < ArraySize(Tf); j++)
   }//for (i = 0; i < ArraySize(ccy); i++)
   //Alert("Strongest ", StrongestCcy[0], "  ", StrongVal[0], " Weakest ", WeakestCcy[0], "  ", WeakVal[0]);
   

   
   


}//End void ReadHanover()

double ReadStrength(string curr, string tf, int shift)
{
   /*
   Returns the strength of the individual currency referenced by the parameters:
      - curr is the currency
      - tf is the time frame
      - shift is how far back in time to look
   */

   //Extract the timeframe - uses David's constants
   int DatapointTf;
   if (tf == "M1") DatapointTf = M1;
   if (tf == "M5") DatapointTf = M5;
   if (tf == "M15") DatapointTf = M15;
   if (tf == "M30") DatapointTf = M30;
   if (tf == "H1") DatapointTf = H1;
   if (tf == "H4") DatapointTf = H4;
   if (tf == "D1") DatapointTf = D1;
   if (tf == "W1") DatapointTf = W1;
   if (tf == "MN") DatapointTf = MN;

   //Allign the curr param with David's constant
   int cc;
   if (curr == "AUD") cc = AUD;
   if (curr == "CAD") cc = CAD;
   if (curr == "CHF") cc = CHF;
   if (curr == "EUR") cc = EUR;
   if (curr == "GBP") cc = GBP;
   if (curr == "JPY") cc = JPY;
   if (curr == "NZD") cc = NZD;
   if (curr == "USD") cc = USD;
   
   return(RSvalue[cc, DatapointTf, shift]);
   
}//End double ReadStrength(string curr, string tf, int shift)

bool HanoverFilter(int type)
{
   //Returns true if the filter indicates sufficient strength/weakness in the pair.
   //Works by running through the tests and returning false if any of them fail. If all pass, the eventually
   //returns true.
   //Tests all fail if the two currencies have equal strength values

   //Read the strength values
   for (int cc = 0; cc < ArraySize(Tf); cc++)
   {
      //First filter. Compare the strength over the chosen time frames
      double strength1 = ReadStrength(Ccy1, Tf[cc], 0);
      double strength2 = ReadStrength(Ccy2, Tf[cc], 0);
      if (SlopeConfirmationCandles > 0) 
      {
         double prevstrength1 = ReadStrength(Ccy1, Tf[cc], SlopeConfirmationCandles);
         double prevstrength2 = ReadStrength(Ccy2, Tf[cc], SlopeConfirmationCandles);   
      }//if (SlopeCandles[cc] > 0)    

     
      //EA is looking to buy. 
      if (type == OP_BUY)
      {
         //First currency must be the strongest
         if (strength1 <= strength2) return(false);

         //Slope must be rising in the first curr and falling in the second
         if (SlopeConfirmationCandles > 0)
         {
            if (prevstrength1 >= strength1) return(false);
            if (prevstrength2 <= strength2) return(false);
         }//if (SlopeConfirmationCandles > 0 
         
         //Threshold. First currency must be above StrongThreshold. Second currency must be below WeakThreshopld
         if (StrongThreshold > 0 && WeakThreshold > 0)
         {
            if (strength1 < StrongThreshold || strength2 > WeakThreshold) return(false);
         }//if (StrongThreshold > 0 && WeakThreshold > 0)
      }//if (type == OP_BUY)
      
      //EA is looking to sell, so first currency must be the weakest
      if (type == OP_SELL && strength1 >= strength2) return(false);
      
      //EA is looking to sell. 
      if (type == OP_SELL)
      {
         //First currency must be the weakest
         if (strength1 >= strength2) return(false);

         //Slope must be falling in the first curr and rising in the second curr
         if (SlopeConfirmationCandles > 0)
         {
            if (prevstrength1 <= strength1) return(false);
            if (prevstrength2 >= strength2) return(false);
         }//if (SlopeConfirmationCandles > 0 
         
         //Threshold. First currency must be below WeakThreshold. Second currency must be above StrongThreshopld
         if (StrongThreshold > 0 && WeakThreshold > 0)
         {
            if (strength1 > WeakThreshold || strength2 < StrongThreshold) return(false);
         }//if (StrongThreshold > 0 && WeakThreshold > 0)
      }//if (type == OP_SELL)
         
   }//for (int cc = 0; cc < ArraySize(Tf); cc++)

   

   //Got this far, so all tests have passed.
   return(true);

}//End bool HanoverFilter()


//End Hanover module
////////////////////////////////////////////////////////////////////////////////////////////////



//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----

   static bool TradeExists;
   ScoobsOk = true;
   FkOk = true;
   
   if (ForceAllTradeDeletion) 
   {
      CloseAllTrades();
      return;
   }//if (ForceAllTradeDeletion) 
         
   if (OrdersTotal() == 0)
   {
      TicketNo = -1;
   }//if (OrdersTotal() == 0)

   ///////////////////////////////////////////////////////////////////////////////////////////////
   CountOpenTrades();            
   if (OpenTrades == 0)
   {
      if (ObjectFind(breakevenlinename) > -1) ObjectDelete(breakevenlinename);
      if (ObjectFind(reentrylinename) > -1) ObjectDelete(reentrylinename);
      
   }//if (OpenTrades == 0)
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Hedging
   if (HedgingInProgress && BasketUpl >0)
   {
      CloseAllTrades();
      return;
   }//if (HedgingInProgress && BasketUpl >0)
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   
   //Recovery
   if (UseRecovery && !HedgingInProgress)
   {
      if (OpenTrades >= Start_Recovery_at_trades) RecoveryInProgress = true;
      
      
      //Replace accidentally deleted be line
      if (RecoveryInProgress && ObjectFind(breakevenlinename) == -1)
      {
         RecoveryModule();      
      }//if (RecoveryInProgress && ObjectFind(breakevenlinename) == -1)
      
      //Recovery trailing sl
      if (RecoveryInProgress && UseRecoveryTrailingStop)
      {
         RecoveryCandlesticktrailingStop();     
      }//if (RecoveryInProgress && UseRecoveryTrailingStop)
      
      
   }//if (UseRecovery)

   //Replace deleted reentry line
   if (RecoveryInProgress && ObjectFind(reentrylinename) == -1)
   {
      ReplaceReEntryLine();
   }//if (RecoveryInProgress && ObjectFind(reentrylinename) == -1)

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Trading times
   bool TradeTimeOk = CheckTradingTimes();
   if (!TradeTimeOk)
   {
      Comment("Outside trading hours\nstart_hourm-end_hourm: ", start_hourm, "-",end_hourm, "\nstart_houre-end_houre: ", start_houre, "-",end_houre);
      return;
   }//if (hour < start_hourm)
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   //Available margin filters
   if (UseScoobsMarginCheck && OpenTrades > 0)
   {
      if(AccountMargin() > (AccountFreeMargin()/100)) 
      {
         DisplayUserFeedback();
         ScreenMessage = StringConcatenate(ScreenMessage,Gap, "There is insufficient margin to allow trading. You might want to turn off the UseScoobsMarginCheck input.", NL);
         Comment(ScreenMessage);         
         return;
      }//if(AccountMargin() > (AccountFreeMargin()/100)) 
      
   }//if (UseScoobsMarginCheck)


   if (UseForexKiwi && AccountMargin() > 0)
   {
      double ml = NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2);
      if (ml < FkMinimumMarginPercent)
      {
         DisplayUserFeedback();
         ScreenMessage = StringConcatenate(ScreenMessage,Gap, "There is insufficient margin percent to allow trading. " + DoubleToStr(ml, 2) + "%", NL);
         Comment(ScreenMessage);         
         return;
      }//if (ml < FkMinimumMarginPercent)
      
   }//if (UseForexKiwi && AccountMargin() > 0)

   ///////////////////////////////////////////////////////////////////////////////////////////////         
   if (OldBars != Bars)
   {
      OldBars = Bars;
      if (AutoCalculateStats) GetStats();
      //Trend detection      
      if (UseTrendDetection) TrendDetectionModule();
      if (!UseTrendDetection && RisingTrend) trend = up;
      if (!UseTrendDetection && FallingTrend) trend = down;
      if (!UseTrendDetection && !FallingTrend && !RisingTrend) trend = ranging;

      if (UseHanover)
      {
         ReadHanover();
      }//if (UseHanover)

      //Trading
      LookForTradingOpportunities();      
   }//if (OldBars != Bars)
   
   ///////////////////////////////////////////////////////////////////////////////////////////////      

   DisplayUserFeedback();
 
   //Does nothing but stops the ignorant whinging
   int x = 0;
   if (x == 1) LookForTradeClosure();
//----
   return(0);
}
//+------------------------------------------------------------------+