//+------------------------------------------------------------------+
//| MH Design from scratch

// Based on: 
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
/*
TODO:
- Ensure stoploss takes into account the spread: difference between Bid & Ask. The spread is added on the Ask side of the trade on MT4.
- Cater for distance in the capital exposure calculations i.e. SL<->OpenPrice
- pp.159 A maximum monthly loss must be no more than 10 percent. If closed trades have resulted in a 10% drawdown to the account in less than a month, stop trading for the balance of the month.
- pp.159 Implement 6% maximum exposure on all open trades.

- Implement https://forum.mql4.com/57285#831181. 
 is NEVER needed. It's a kludge, don't use it. It's use is always wrong. Normallizing Price for pending orders must be a multiple of ticksize, metals are multiple of 0.25 *not a power of ten*.
- Include the spread in the slsize calculations?  Because automatically lose the cost of the spread in the trade.
- Change deposit currency from USD to GBP (ask the broker)
- Implement Tr-1BH for ST Unit, at the 61.8% retracement point
- Implement Trade management (LT unit): trail at the 1BL if the S&P reaches a probable Wave-C price target.

- Research wheather 10 bars is the right lookback period for SWING HIGH/LOW calculation.  Prefer something more dynamic and not fixed on an arbitary number i.e. "10". #define LOOKBACK  10      //use 10 period lookback *** NEEDS TO BE VALIDATED ***
- Update PositionSize_Get() to check and do not place trades if the maximum capital exposure on all open trades is above 6 percent. At each bar, total up capital exposure for all open and pending trades i.e. using SL<->OpenPrice
- Going Long - ordering BUY
- decide if modification of trade during the bar, so as to get a better price (if the bid price goes up, then give an opportunity to raise sell stop)?

VERSION HISTORY:
v0.17 Implement Trade management (LT unit): after the second LTF momentum bearish reversal following the HTF momentum reaching the OB zone then Tr-1BH 

NOTES:
Bid is for opening short(sell)/closing long(buy) orders
Ask is for opening long/closing short orders

Orders are usually not finalized instantly, they are always delayed, especially on demo accounts. Usually a few secs, but could take longer.

On an open chart, press F8 and in the common tab you can select "show Ask line". The Ask line is the price you will get when you enter a new long position or when you close an existing short position. 

The spread is added on the Ask side of the trade on MT4, so your stoploss needs to take into account the spread, difference between Bid & Ask.
*/

#include <stdlib.mqh>
#include <Dictionary.mqh>
#include <MH_Globals.mqh>
#include <MH_variables.mqh>   // Description of variables
/*
#include <MH_Check.mqh>       // Checking legality of programs used
#include <MH_terminal.mqh>    // Order accounting
#include <MH_inform.mqh>      // Data function
#include <MH_Events.mqh>      // Event tracking function
#include <MH_Trade.mqh>       // Trade function
#include <MH_Open_Ord.mqh>    // Opening one order of the preset type
#include <MH_Close_All.mqh>  // Closing all orders of the preset type
#include <MH_Tral_Stop.mqh>  // StopLoss modification for all orders of the preset type
#include <MH_Lot.mqh>        // Calculation of the amount of lots
#include <MH_Criterion.mqh>   // Trading criteria
*/
#include <MH_Errors.mqh>      // Error processing function
#include <MH_TradeUnit.mqh>   //TradeUnit Classstate
#include <MH_Position_Size.mqh>   // Position sizing

//-----------------------------------------------------------------------------------------------------------------------------------------
// EA Initialisation
//-----------------------------------------------------------------------------------------------------------------------------------------
int init()
{
   ObjGUID = 0; //GUID for name
   TradeUnits.FreeMode(FALSE); //on DeleteObjectByKey(), do NOT delete the object as well as the container in the dictionary

   if (BaseTimeFrame == -1)
      InitPeriods();                   //Set up timeframes for stochastics
   else
      InitPeriodsOpt(BaseTimeFrame);   //used for optimisation only - to find the most profitable base timeframe

//   AccountProperties_Print();        //--- show all the static account information
//   SymbolInfo_Print();
MarketInfo_Print();

   Stoch_Update();                     //Update the MTF Stoch values
//   Level_old=(int)MarketInfo(Symbol(),MODE_STOPLEVEL );//Min. distance
//   Terminal();                         // Order accounting function 

InitStateEvents();
   return(0);
}

//SEMAPHORE
//						
//	
//	int cnt = 0;
//	while(!IsTradeAllowed() && cnt < retry_attempts) 
//	{
//		OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
//		cnt++;
//	}


//-----------------------------------------------------------------------------------------------------------------------------------------
// EA Start
//-----------------------------------------------------------------------------------------------------------------------------------------
int start()
{
//   Log("NEW TICK: " + TimeToString(TimeCurrent());
   static datetime LastOpenTime = Time[0];   //time of the open of the last bar - must be static so as to remember the last value between calls to start().
   if (Time[0] > LastOpenTime)   //if new bar
   {//Log(string(__LINE__)+": NEW BAR");
      LastOpenTime = Time[0];          //new bar so save the time of the Open of the current bar
	//if (IsStopped || !IsConnected()) 
	//{
	//   EXIT
	//}
//IMPLEMENT SEMAPHORE CHECK AND SET
 /*
     if(Check()==false)                  // If the usage conditions..
         return (0);                          // ..are not met, then exit
         PlaySound("tick.wav");              // At every tick
      Terminal();                         // Order accounting function 
      Events();                           // Information about events
//      Trade(Criterion());                 // Trade function
      Inform(0);                          // To change the color of objects
*/

      TradeManage();
//IMPLEMENT SEMAPHORE RELEASE      
      MHStoch_PlotAll();  //Plot MTF Stoch Indicator at start of bar only
   }
//   if (!MQLInfoInteger(MQL_OPTIMIZATION)) //if not optimizing
//      Indicator_Plot();//called every tick
   return(0);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// EA Deinitialisation
//-----------------------------------------------------------------------------------------------------------------------------------------
int deinit()
{
//   Inform(-1);                         // To delete objects

//TODO: CLOSE ALL ORDERS AND POSITIONS
   TradeUnits_PrintAll();
   Print("Before TradeUnits.Clear()");
   TradeUnits.Clear(); //release heap
   Print("After TradeUnits.Clear()");
   TradeUnits_PrintAll();

//**** TODO: NEED TO CLOSE ALL OPEN ORDERS IN DEINIT() *****
   return(0);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Process all Trades
//-----------------------------------------------------------------------------------------------------------------------------------------
void TradeManage()
{
   for(TS *node = TradeUnits.GetFirstNode(); node != NULL; node = TradeUnits.GetNextNode())
      node.Manage();

   double TotalCE = Orders_Trading_TotalCE_Calc();   //Calculate Total Capital Exposure across all trades
   switch (EntryCondition())  //Check for entry setup for the *last* bar (once, on the first tick of the bar).  This to wait until the last bar has fully formed before checking entry condition.
   {
//       case SIGNAL_LONG:
//            BuyStop();
//            break;
      case SIGNAL_SHORT:                           //Setup for a short trade
            LOG(": EntryCondition() == SIGNAL_SHORT");
            SellStop_TwoUnits_Order(TotalCE);   //Place Sell Stop Pending Order Pair
         break;
   }
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// DETECT TRADE SETUP FOR LONG OR SHORT
//-----------------------------------------------------------------------------------------------------------------------------------------
int EntryCondition()
{
   Stoch_Update();   //Update MTF Stoch current and previous bar values

//--------------------------------------------------------------------------------------------------------------------------
//Miner Entry CONDITIONS - Multiple Time Frame

//   bool K1XO = K1_1<=D1_1 && K1>D1; //K1 Xover
   bool K1XU = K1_1>=D1_1 && K1<D1; //K1 Xunder = bearish reversal

//-----------------INSERT ENTRY RULES HERE FROM ANALYSIS PROGRAM--------------------------------
//MINER ENTRY RULES p.46 Table 2.2
//Miner p.37 both the fast and slow line must be in the OB or OS zone to consider the indicator OB or OS

//          ---------- Long ----------
// TO FILL IN LATER WHEN IMPLEMENTING TRADING LONG
      
//          ---------- Short ----------
//          p+3 Timeframe          p+2 Timeframe         p+1 Timeframe                 Lowest Timeframe (p)                 
//          Period4                Period3               Period2                       Period1                       

//                                                       Bear and ABOVE OS Zone        Bearish reversal AND ABOVE OS Zone      
bool SC1=   K4>=OB &&              K3>=OB &&             D2>K2 && K2>OS && D2>OS &&    K1XU && K1>OS && K1>OS;

//                                                       Bull AND INSIDE OB Zone       Bearish reversal                        
bool SC2=   K4>=OB &&              K3>=OB &&             D2<K2 && K2>=OB && K2>=OB &&  K1XU;


//--------------------------------------------------------------------------------------------------------------------------

/*
   if (SC1)
      Arrow_Plot(SIGNAL_SHORT, 1);
   if (SC2)
      Arrow_Plot(SIGNAL_SHORT, 2);
   if (SC3)
      Arrow_Plot(SIGNAL_SHORT, 3);
   if (SC4)
      Arrow_Plot(SIGNAL_SHORT, 4);
   if (SC5)
      Arrow_Plot(SIGNAL_SHORT, 5);

   if (LC1)
      Arrow_Plot(SIGNAL_LONG, 1);
   if (LC2)
      Arrow_Plot(SIGNAL_LONG, 2);
   if (LC3)
      Arrow_Plot(SIGNAL_LONG, 3);
   if (LC4)
      Arrow_Plot(SIGNAL_LONG, 4);
//   if (LC5)
//      Arrow_Plot(SIGNAL_LONG, 5);
*/
   
//   if (LC1 && LC2 && LC3 && LC4 && LC5 && LC6)
 //     VLine_Plot(clrGreen);

bool S1 = SC1 || SC2;
if (S1)
   VLine_Plot(clrRed);

/*
   string st;
   if (L1)
   {
      st = "L1";
   }
   else if (S1)
   {
      st = "S1";
   }

   if (L1 || S1)
   {
      Log(string(__LINE__)+": "+StringFormat("(%s): [K1_1: %.2f, D1_1: %.2f, K1: %.2f, D1: %.2f] [K2_1: %.2f, D2_1: %.2f, K2: %.2f, D2: %.2f] [K3_1: %.2f, D3_1: %.2f, K3: %.2f, D3: %.2f]",
         st, K1_1, D1_1, K1, D1, K2_1, D2_1, K2, D2, K3_1, D3_1, K3, D3));
   }     
*/

//if (L1)
//   return(SIGNAL_LONG);    //Signal Long Condition met
//else
if (S1)
   return(SIGNAL_SHORT);   //Signal Short condition met
else
   return(SIGNAL_NONE);    //Signal no condition met
}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Get latest Stoch values
//-----------------------------------------------------------------------------------------------------------------------------------------
void Stoch_Update()
{
// Save values for next time through
   K1_1 = K1;
   K2_1 = K2;
   K3_1 = K3;
   K4_1 = K4;
/*
   K5_1 = K5;
   K6_1 = K6;
   K7_1 = K7;
   K8_1 = K8;
   K9_1 = K9;
*/
   D1_1 = D1;
   D2_1 = D2;
   D3_1 = D3;
   D4_1 = D4;
/*
   D5_1 = D5;
   D6_1 = D6;
   D7_1 = D7;
   D8_1 = D8;
   D9_1 = D9;
*/
   K1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K2 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K3 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K4 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
/*
   K5 = iStochastic(NULL, period5, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K6 = iStochastic(NULL, period6, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K7 = iStochastic(NULL, period7, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K8 = iStochastic(NULL, period8, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K9 = iStochastic(NULL, period9, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
*/

   D1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D2 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D3 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D4 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
/*
   D5 = iStochastic(NULL, period5, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D6 = iStochastic(NULL, period6, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D7 = iStochastic(NULL, period7, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D8 = iStochastic(NULL, period8, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D9 = iStochastic(NULL, period9, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
*/}
//-----------------------------------------------------------------------------------------------------------------------------------------
// PLOT MH VERSION OF MTF STOCHASTIC INDICATOR IN SUBWINDOW (to be called only at start of bar)
//-----------------------------------------------------------------------------------------------------------------------------------------
void MHStoch_PlotAll()
{
   static string LastKName;
   LastKName = Line_Plot(iTime(NULL,period1,1), K1_1, iTime(NULL,period1,0), K1, clrBlue, false);
   LastKName = Line_Plot(iTime(NULL,period1,1), K2_1, iTime(NULL,period1,0), K2, clrRed, false);
   LastKName = Line_Plot(iTime(NULL,period1,1), K3_1, iTime(NULL,period1,0), K3, clrGreen, false);
   LastKName = Line_Plot(iTime(NULL,period1,1), K4_1, iTime(NULL,period1,0), K4, clrBlack, false);
//   LastKName = Line_Plot(iTime(NULL,period1,1), K5_1, iTime(NULL,period1,0), K5, clrBlack, false);
//   LastKName = Line_Plot(iTime(NULL,period1,1), K6_1, iTime(NULL,period1,0), K6, clrBlack, false);
   //LastKName = Line_Plot(iTime(NULL,period1,1), K7_1, iTime(NULL,period1,0), K7, clrRed, false);
   //LastKName = Line_Plot(iTime(NULL,period1,1), K8_1, iTime(NULL,period1,0), K8, clrBlue, false);
   //LastKName = Line_Plot(iTime(NULL,period1,1), K9_1, iTime(NULL,period1,0), K9, clrGreen, false);

   LastKName = Line_Plot(iTime(NULL,period1,1), D1_1, iTime(NULL,period1,0), D1, clrBlue, true);
   LastKName = Line_Plot(iTime(NULL,period1,1), D2_1, iTime(NULL,period1,0), D2, clrRed, true);
   LastKName = Line_Plot(iTime(NULL,period1,1), D3_1, iTime(NULL,period1,0), D3, clrGreen, true);
   LastKName = Line_Plot(iTime(NULL,period1,1), D4_1, iTime(NULL,period1,0), D4, clrBlack, true);
//   LastKName = Line_Plot(iTime(NULL,period1,1), D5_1, iTime(NULL,period1,0), D5, clrBlack, true);
//   LastKName = Line_Plot(iTime(NULL,period1,1), D6_1, iTime(NULL,period1,0), D6, clrBlack, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D7_1, iTime(NULL,period1,0), D7, clrRed, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D8_1, iTime(NULL,period1,0), D8, clrBlue, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D9_1, iTime(NULL,period1,0), D9, clrBlack, true);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// PLOT MH VERSION OF MTF STOCHASTIC INDICATOR IN SUBWINDOW
//-----------------------------------------------------------------------------------------------------------------------------------------
//Differs from Indicator_Plot, in that it plots the stoch from the current tick in the bar, not the last close.  So it is right up to date.
void Stoch_PlotAll()
{
   static string LastK1Name = "";                           //remember Last KName so it can be deleted if necessary
   static string LastD1Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP1OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK1Name, LastD1Name, LastP1OpenTime, K1_1, D1_1, K1, D1, period1, clrBlue);

   static string LastK2Name = "";                           //remember Last KName so it can be   deleted if necessary
   static string LastD2Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP2OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK2Name, LastD2Name, LastP2OpenTime, K2_1, D2_1, K2, D2, period1, clrRed);  //note period 1 to display higher period stoch value every bar

   static string LastK3Name = "";                           //remember Last KName so it can be deleted if necessary
   static string LastD3Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP3OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK3Name, LastD3Name, LastP3OpenTime, K3_1, D3_1, K3, D3, period1, clrBlack);
}
//------------------------------------------------------------------------------------------------------------------------------------------
// DETECT IF HIGHER TIMEFRAME STOCH OVERSOLD
//-----------------------------------------------------------------------------------------------------------------------------------------
int HTF_Oversold()
{
   bool oversold = K2 <= OS && D2 <= OS;  //Overbought //Miner p.37 both the fast and slow line must be in the OB or OS zone to consider the indicator OB or OS

   if (oversold)
      LOG(StringFormat("HTF Oversold detected. K2: ", K2, " D2: ", D2));
   return(oversold);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// DETECT IF LOWEST TIMEFRAME STOCH BULLISH REVERSAL
//-----------------------------------------------------------------------------------------------------------------------------------------
int LTF_BullishReversal()
{
   bool K1XO = K1_1<=D1_1 && K1>D1;        //K1 Xover

/*
   if (K1XO)
      printf("LTF Bullish Reversal detected: K1_1: %0.2f, D1_1: %0.2f, K1: %0.2f, D1: %0.2f", K1_1, D1_1, K1, D1);
*/
   return(K1XO);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// DETECT IF LOWEST TIMEFRAME STOCH BEARISH REVERSAL
//-----------------------------------------------------------------------------------------------------------------------------------------
int LTF_BearishReversal()
{
   bool K1XU = K1_1>=D1_1 && K1<D1;       //K1 Xunder

/*
   if (K1XU)
      printf("Bearish Reversal detected: K1_1: %0.2f, D1_1: %0.2f, K1: %0.2f, D1: %0.2f", K1_1, D1_1, K1, D1);
*/
   return(K1XU);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Initialise available timeframes for Stochastic calculations
//-----------------------------------------------------------------------------------------------------------------------------------------
void InitPeriods()
{
   int p[9];
   p[0] = PERIOD_M1;
   p[1] = PERIOD_M5;
   p[2] = PERIOD_M15;
   p[3] = PERIOD_M30;
   p[4] = PERIOD_H1;
   p[5] = PERIOD_H4;
   p[6] = PERIOD_D1;
   p[7] = PERIOD_W1;
   p[8] = PERIOD_MN1;
   
   int i;   //index
   switch (Period())
      {
      case     1 :   i = 0; break;  //1 min     == M1
      case     5 :   i = 1; break;  //5 min     == M5
      case    15 :   i = 2; break;  //15 min    == M15
      case    30 :   i = 3; break;  //30 min    == M30
      case    60 :   i = 4; break;  //60 min    == H1
      case   240 :   i = 5; break;  //240 min   == H4
      case  1440 :   i = 6; break;  //1440 min  == D1
      case  10080 :  i = 7; break;  //10080 min == WK
      case  43200 :  i = 8; break;  //43200 min == MN
      default: // this ea needs current plus 3 higher timeframes to work
         LOG("CANNOT SELECT THIS TIMEFRAME, EXITING PROGRAM");
         TerminalClose(0);     //EXIT PROGRAM!!!
      }

   period1 = p[i];
   period2 = p[i+1];
   period3 = p[i+2];
   period4 = p[i+3];
//   period5 = p[i+4];
//   period6 = p[i+5];
/*
   period7 = p[i+6];
   period8 = p[i+7];
   period9 = p[i+8];
*/
   LOG(StringFormat("InitPeriods(): Timeframes selected: current: %d, current+1: %d, current+2: %d, current+3: %d, current+4: %d", period1, period2, period3, period4, period5));
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Initialise available timeframes for optimization purposes only
//-----------------------------------------------------------------------------------------------------------------------------------------
void InitPeriodsOpt(int SelectedTimeframe)
{
   int p[9];
   p[0] = PERIOD_M1;
   p[1] = PERIOD_M5;
   p[2] = PERIOD_M15;
   p[3] = PERIOD_M30;
   p[4] = PERIOD_H1;
   p[5] = PERIOD_H4;
   p[6] = PERIOD_D1;
   p[7] = PERIOD_W1;
   p[8] = PERIOD_MN1;
   
   if (SelectedTimeframe > 6)
   {
      LOG("InitPeriodsOpt(): ERROR - CANNOT SELECT THIS TIMEFRAME, EXITING PROGRAM");
      TerminalClose(0);     //EXIT PROGRAM!!!
      return;
   }
   
   period1 = p[SelectedTimeframe];
   period2 = p[SelectedTimeframe+1];
   period3 = p[SelectedTimeframe+2];
   LOG(StringFormat("InitPeriodsOpt(): Timeframes selected: current: %d, current+1: %d, current+2: %d, current+3: %d", period1, period2, period3));
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Print Account Properties: https://docs.mql4.com/constants/environment_state/accountinformation
//-----------------------------------------------------------------------------------------------------------------------------------------
void AccountProperties_Print()
{
   Print("---------------------- Start AccountProperties_Print() ----------------------");
   printf("ACCOUNT_LOGIN: %d",AccountInfoInteger(ACCOUNT_LOGIN)); 

   switch((ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE))          //--- the account type 
     { 
      case(ACCOUNT_TRADE_MODE_DEMO): 
         Print("ACCOUNT_TRADE_MODE: ACCOUNT_TRADE_MODE_DEMO (This is a demo account)"); 
         break; 
      case(ACCOUNT_TRADE_MODE_CONTEST): 
         Print("ACCOUNT_TRADE_MODE: ACCOUNT_TRADE_MODE_CONTEST (This is a competition account)"); 
         break; 
      default:
         Print("ACCOUNT_TRADE_MODE: This is a REAL account, exiting Start()!!"); 
         TerminalClose(0);    //EXIT PROGRAM!!!
         return;              //*** EXIT NOW TO STOP USING A REAL ACCOUNT! **
     } 

   printf("ACCOUNT_LEVERAGE: %d",AccountInfoInteger(ACCOUNT_LEVERAGE)); 
   printf("ACCOUNT_LIMIT_ORDERS (Maximum allowed number of active pending orders) (0-unlimited): %d",AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)); 

   switch((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)) //--- the StopOut level setting mode 
     { 
      case(ACCOUNT_STOPOUT_MODE_PERCENT): 
         Print("ACCOUNT_MARGIN_SO_MODE: ACCOUNT_STOPOUT_MODE_PERCENT (The StopOut level is specified percentage)"); 
         break; 
      case(ACCOUNT_STOPOUT_MODE_MONEY): 
         Print("ACCOUNT_MARGIN_SO_MODE: ACCOUNT_STOPOUT_MODE_MONEY (The StopOut level is specified in monetary terms)"); 
         break; 
     } 

   if(AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) 
      Print("ACCOUNT_TRADE_ALLOWED = TRUE (Trading (manual/automated) for this account is allowed)"); 
   else
   {
      Print("ACCOUNT_TRADE_ALLOWED = FALSE (Trading (manual/automated) for this account is disabled!)");
      Print("AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) may return false in the following cases:");
      Print("(1) No connection to the trade server. That can be checked using TerminalInfoInteger(TERMINAL_CONNECTED)).");
      Print("(2) Trading account switched to read-only mode (sent to the archive).");
      Print("(3) trading on the account is disabled at the trade server side.");
      Print("(4) Cconnection to a trading account has been performed in Investor mode.");
   }

   if(AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) //Automated trading can be disabled at the trade server side for the current account
      Print("ACCOUNT_TRADE_EXPERT = TRUE (Automated Trading is allowed for any Expert Advisors/scripts for the current account)"); 
   else 
      Print("Automated Trading by Expert Advisors is disabled by the trade server for this account!"); 

//------------------------------------------------------------------------------
// show all the information available from the function AccountInfoString() 
   Print("ACCOUNT_NAME (Client name): ", AccountInfoString(ACCOUNT_NAME)); 
   Print("ACCOUNT_SERVER (The name of the trade server): ", AccountInfoString(ACCOUNT_SERVER)); 
   Print("ACCOUNT_CURRENCY (Deposit currency): ", AccountInfoString(ACCOUNT_CURRENCY)); 
   Print("ACCOUNT_COMPANY (The name of the broker): ", AccountInfoString(ACCOUNT_COMPANY));
    
   Print("---------------------- End AccountProperties_Print() ----------------------");
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Print Account Properties: https://docs.mql4.com/constants/environment_state/accountinformation
//-----------------------------------------------------------------------------------------------------------------------------------------
void AccountPropertiesFinancials_Print()
{
   Print("--------------------- Start AccountPropertiesFinancials_Print() ----------------------");
   printf("ACCOUNT_BALANCE (Account balance in the deposit currency): %G %s",AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoString(ACCOUNT_CURRENCY)); 
   printf("ACCOUNT_CREDIT (Account credit in the deposit currency): %G %s", AccountInfoDouble(ACCOUNT_CREDIT), AccountInfoString(ACCOUNT_CURRENCY)); 
   printf("ACCOUNT_PROFIT (Current profit of an account in the deposit currency): %G %s", AccountInfoDouble(ACCOUNT_PROFIT), AccountInfoString(ACCOUNT_CURRENCY)); 
   printf("ACCOUNT_EQUITY (Account equity in the deposit currency): %G %s", AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoString(ACCOUNT_CURRENCY)); 
   printf("ACCOUNT_MARGIN (Account margin used in the deposit currency): %G %s", AccountInfoDouble(ACCOUNT_MARGIN), AccountInfoString(ACCOUNT_CURRENCY)); 
   printf("ACCOUNT_MARGIN_FREE (Free margin of an account in the deposit currency): %G %s",AccountInfoDouble(ACCOUNT_MARGIN_FREE), AccountInfoString(ACCOUNT_CURRENCY)); 
   printf("ACCOUNT_MARGIN_LEVEL (Account margin level): %G%%", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)); 

   switch((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)) //--- the StopOut level setting mode 
     { 
      case(ACCOUNT_STOPOUT_MODE_PERCENT): 
         printf("ACCOUNT_MARGIN_SO_CALL (Margin call level): %G%%", AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)); 
         printf("ACCOUNT_MARGIN_SO_SO (Margin stop out level): %G%%", AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)); 
         break; 
      case(ACCOUNT_STOPOUT_MODE_MONEY): 
         printf("ACCOUNT_MARGIN_SO_CALL (Margin call level): %G %s", AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL), AccountInfoString(ACCOUNT_CURRENCY)); 
         printf("ACCOUNT_MARGIN_SO_SO (Margin stop out level): %G %s", AccountInfoDouble(ACCOUNT_MARGIN_SO_SO), AccountInfoString(ACCOUNT_CURRENCY)); 
         break; 
     } 
   Print("---------------------- End AccountPropertiesFinancials_Print() -----------------------");
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// MarketInfo Returns various data about securities listed in the "Market Watch" window
//-----------------------------------------------------------------------------------------------------------------------------------------
void MarketInfo_Print()
{
   Print("---------------------- Start MarketInfo_Print() ----------------------");
   Print("Symbol = ",_Symbol);
   Print("MODE_LOW (Low day price) = ",MarketInfo(_Symbol,MODE_LOW));
   Print("MODE_HIGH (High day price) = ",MarketInfo(_Symbol,MODE_HIGH));
   Print("MODE_TIME (The last incoming tick time) = ",(MarketInfo(_Symbol,MODE_TIME)));
   Print("MODE_BID (Last incoming bid price) = ",MarketInfo(_Symbol,MODE_BID));
   Print("MODE_ASK (Last incoming ask price) = ",MarketInfo(_Symbol,MODE_ASK));
   Print("MODE_POINT (Point size in the quote currency) = ",MarketInfo(_Symbol,MODE_POINT));
   Print("MODE_DIGITS (Digits after decimal point) = ", (int) MarketInfo(_Symbol,MODE_DIGITS));
   Print("MODE_SPREAD (Spread value) = ",MarketInfo(_Symbol,MODE_SPREAD), " points");
   Print("MODE_STOPLEVEL (Stop level) = ",MarketInfo(_Symbol,MODE_STOPLEVEL), " points");
   Print("MODE_LOTSIZE (Lot size in the base currency) = ",MarketInfo(_Symbol,MODE_LOTSIZE), " ", SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE));
   Print("MODE_TICKVALUE (Tick value in the deposit currency) = ",MarketInfo(_Symbol,MODE_TICKVALUE), " ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("MODE_TICKSIZE (Tick size) = ",MarketInfo(_Symbol,MODE_TICKSIZE), " points"); 
   Print("MODE_SWAPLONG (Swap of the buy order) = ",MarketInfo(_Symbol,MODE_SWAPLONG));
   Print("MODE_SWAPSHORT (Swap of the sell order) = ",MarketInfo(_Symbol,MODE_SWAPSHORT));
   Print("MODE_STARTING (Market starting date (for futures)) = ",MarketInfo(_Symbol,MODE_STARTING));
   Print("MODE_EXPIRATION (Market expiration date (for futures)) = ",MarketInfo(_Symbol,MODE_EXPIRATION));
   Print("MODE_TRADEALLOWED (Trade is allowed for the symbol) = ",MarketInfo(_Symbol,MODE_TRADEALLOWED));
   Print("MODE_MINLOT (Minimum permitted amount of a lot) = ", MarketInfo(_Symbol,MODE_MINLOT), " lots");
   Print("MODE_LOTSTEP (Step for changing lots) = ",MarketInfo(_Symbol,MODE_LOTSTEP));
   Print("MODE_MAXLOT (Maximum permitted amount of a lot) = ", MarketInfo(_Symbol,MODE_MAXLOT), " lots");
   Print("MODE_SWAPTYPE (Swap calculation method) = ", SwapCalcMethod());
   Print("MODE_PROFITCALCMODE (Profit calculation mode) = ", ProfitCalcMode());
   Print("MODE_MARGINCALCMODE (Margin calculation mode) = ",MarketInfo(_Symbol,MODE_MARGINCALCMODE));
   Print("MODE_MARGININIT (Initial margin requirements for 1 lot) = ",MarketInfo(_Symbol,MODE_MARGININIT));
   Print("MODE_MARGINMAINTENANCE (Margin to maintain open orders calculated for 1 lot) = ",MarketInfo(_Symbol,MODE_MARGINMAINTENANCE));
   Print("MODE_MARGINHEDGED (Hedged margin calculated for 1 lot) = ",MarketInfo(_Symbol,MODE_MARGINHEDGED));
   Print("MODE_MARGINREQUIRED (Free margin required to open 1 lot for buying) = ",MarketInfo(_Symbol,MODE_MARGINREQUIRED), " ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("MODE_FREEZELEVEL (Order freeze level) = ", MarketInfo(_Symbol,MODE_FREEZELEVEL), " points"); 
   Print("---------------------- End MarketInfo_Print() ----------------------");
}

string SwapCalcMethod()
{
   string s;
   
   switch((int)MarketInfo(_Symbol,MODE_SWAPTYPE))
   {
      case 0:
         s = "In Points";
         break;
      case 1:
         s = "In the Symbol Base Currency";
         break;
      case 2:
         s = "By Interest";
         break;
      case 3:
         s = "In the Margin Currency";
         break;
   }
   return (s);
}

string ProfitCalcMode()
{
   string s;
   
   switch((int)MarketInfo(_Symbol,MODE_PROFITCALCMODE))
   {
      case 0:
         s = "Forex";
         break;
      case 1:
         s = "CFD";
         break;
      case 2:
         s = "Futures";
         break;
   }
   return (s);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// SymbolInfo prints various data about symbols
//-----------------------------------------------------------------------------------------------------------------------------------------
void SymbolInfo_Print()
{
   Print("SYMBOL_CURRENCY_BASE (Basic currency of a symbol) = ",SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE));
   Print("SYMBOL_CURRENCY_PROFIT (Profit currency) = ",SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT));
   Print("SYMBOL_CURRENCY_MARGIN (Margin currency) = ",SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN));
   Print("SYMBOL_DESCRIPTION (Symbol description) = ",SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION));
   Print("SYMBOL_PATH (Path in the symbol tree) = ",SymbolInfoString(_Symbol, SYMBOL_PATH));
}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Print info of all TradeUnit objects in Dictionary TradeUnits
//-----------------------------------------------------------------------------------------------------------------------------------------
void TradeUnits_PrintAll()
{
   int key;
   Print("Printing all remaining Trades in Dictionary ...");
   TS *node;
   for(node = TradeUnits.GetFirstNode(); node != NULL; node = TradeUnits.GetNextNode())
   {
      TradeUnits.GetCurrentKey(key);
      LOG(StringFormat("OrderTicket(): %d, state: %d", key, node.State));
   }
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Plot the indicator
//-----------------------------------------------------------------------------------------------------------------------------------------
void Indicator_Plot() //called every tick
{
   double k1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   double k2 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   double k3 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   double k4 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);

   double d1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   double d2 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   double d3 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   double d4 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);

   double k1_1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 1);
   double k2_1 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 1);
   double k3_1 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 1);
   double k4_1 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 1);

   double d1_1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 1);
   double d2_1 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 1);
   double d3_1 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 1);
   double d4_1 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 1);

//Print("For Indicator: every tick iStochastic(period1(shift 0, 1)): DateTime=", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), ", K1_1=", K1_1, ", D1_1=", D1_1, ", K1=", K1, ", D1=", D1);

   static string LastK1Name = "";                           //remember Last KName so it can be deleted if necessary
   static string LastD1Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP1OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK1Name, LastD1Name, LastP1OpenTime, k1_1, d1_1, k1, d1, period1, clrBlue);
/*
   static string LastK2Name = "";                           //remember Last KName so it can be   deleted if necessary
   static string LastD2Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP2OpenTime = iTime(NULL,period2,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK2Name, LastD2Name, LastP2OpenTime, K2_1, D2_1, K2, D2, period2, clrRed);

   static string LastK3Name = "";                           //remember Last KName so it can be deleted if necessary
   static string LastD3Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP3OpenTime = iTime(NULL,period3,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK3Name, LastD3Name, LastP3OpenTime, K3_1, D3_1, K3, D3, period3, clrBlack);

   static string LastK4Name = "";                           //remember Last KName so it can be deleted if necessary
   static string LastD4Name = "";                           //remember Last DName so it can be deleted if necessary
   static datetime LastP4OpenTime = iTime(NULL,period4,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
   Stoch_Plot(LastK4Name, LastD4Name, LastP4OpenTime, K4_1, D4_1, K4, D4, period4, clrDarkGreen);
*/
}
//------------------------------------------------------------------------------
void Stoch_Plot(string &LastKName, string &LastDName, datetime &LastPOpenTime, double K_1, double D_1, double Ka, double Da, int p, color Clr)
{ //Print("Stoch_Plot(LastKName=", LastKName, ", LastDName=", LastDName, ", LastPOpenTime=", TimeToStr(LastPOpenTime,TIME_DATE|TIME_SECONDS), ", K_1=", K_1, ", D_1=", D_1, ", Ka=", Ka, ", Da=", Da, ", p=", p, ")");
   datetime POpenTime = iTime(NULL,p,0);
   if (POpenTime > LastPOpenTime)   //if new bar
      LastPOpenTime = POpenTime;          //new bar so save the time of the Open of the current bar
   else //not first tick within bar, delete the last tick temporary trend lines
   {
      if (!ObjectDelete(LastKName))   //delete it (the very first time through will fail as previous object won't exist)
         LOG(": "+StringFormat("ObjectDelete(%s): %s", LastKName, Error_Get()));
      if (!ObjectDelete(LastDName))   //delete it (the very first time through will fail as previous object won't exist)
         LOG(": "+StringFormat("ObjectDelete(%s): %s", LastDName, Error_Get()));
   }
   LastKName = Line_Plot(iTime(NULL,p,1), K_1, iTime(NULL,p,0), Ka, Clr, false);
   LastDName = Line_Plot(iTime(NULL,p,1), D_1, iTime(NULL,p,0), Da, Clr, true);   
}
//------------------------------------------------------------------------------
string Line_Plot(datetime t1, double val1, datetime t2, double val2, color clr, bool dot)
{ //Print("Line_Plot(t1=", TimeToStr(t1,TIME_DATE|TIME_SECONDS), ", val1=", val1, ", t2=", TimeToStr(t2,TIME_DATE|TIME_SECONDS), ", val2=", val2, ")");
   string Name = IntegerToString(ObjGUID++);
   
//MAKE SURE THE SAVED MT4 CHART TEMPLATES DO NOT HAVE OBJECTS EMBEDDED WITH THEM OR THEY WILL CLASH WITH THE NEWLY PLOTTED ONES
//   if (ObjectFind(Name) > 0)  //check whether object already exists with this name
//      Log(string(__LINE__)+": "+StringFormat("Object already exists in Window: %d, with Name: %s, Object Type: %d", ObjectFind(Name), Name, ObjectType(Name)));

   if(!ObjectCreate(Name,OBJ_TREND,SubWin, t1, val1, t2, val2))
      LOG(": "+StringFormat("ObjectCreate(%s, OBJ_TREND): %s", Name, Error_Get()));

   if(!ObjectSet(Name,OBJPROP_RAY,false))
      LOG(": "+StringFormat("ObjectSet(%s, OBJPROP_RAY): %s", Name, Error_Get()));

   ObjectSet(Name,OBJPROP_COLOR,clr);
   if (dot)
      ObjectSet(Name,OBJPROP_STYLE, STYLE_DOT);

//    ChartRedraw();
   return(Name);
}
//------------------------------------------------------------------------------
//Plot a vertical line at current time
void VLine_Plot(color clr)
{
   string Name = IntegerToString(ObjGUID++);

   if(!ObjectCreate(Name,OBJ_VLINE,MainWin, TimeCurrent(), 0))
      LOG(": "+StringFormat("ObjectCreate(%s, OBJ_VLINE): %s", Name, Error_Get()));

   ObjectSet(Name,OBJPROP_COLOR,clr);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Plot text (s) below bottom of last completed bar, and vertical
//-----------------------------------------------------------------------------------------------------------------------------------------
void Text_Plot(string s, int w)
{
   string t="";
   string n = IntegerToString(ObjGUID++);
   string on;  //object name
   int ot=ObjectsTotal();  //objects total
   
   for(int i = 0; i < ot; i++) 
   { 
      on = ObjectName(i);
      if(ObjectGet(on, OBJPROP_TIME1) == Time[0] && ObjectType(on)== OBJ_TEXT)
      {
         ObjectGetString(w, on, OBJPROP_TEXT, 0, t);      //get text of existing object
//Log(__LINE__, __FUNCTION__, on);
//Log(__LINE__, __FUNCTION__, TimeToString(ObjectGet(on, OBJPROP_TIME1)));
//Log(__LINE__, __FUNCTION__, "t: " + t);
         t += "; " + s;  //add in the delimiter and the new text string
         ObjectSetString(w, on, OBJPROP_TEXT, t); 
         break;
      }
   }
   if (t == "")   //object not found, create one
   {
      ObjectCreate(n, OBJ_TEXT, w, Time[0], Low[0]-10);
      ObjectSetString(w, n, OBJPROP_TEXT, s); 
//Log(__LINE__, __FUNCTION__, "s: " + s);
      ObjectSetInteger(w, n, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(w, n, OBJPROP_COLOR, clrBlack);
      ObjectSetDouble(w, n, OBJPROP_ANGLE, -90);
      ObjectSetInteger(w, n, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   }
}
//------------------------------------------------------------------------------
void StoVal_Plot(double k, double d, double k_1, double d_1, int r)
{
   double v;   //value on Y axis (note: not pixels)
   string n = IntegerToString(ObjGUID++);

   switch(r)   //Row on chart
   {
      case 1:
         v = 6;
         break;
      case 2:
         v = 11;
         break;
      case 3:
         v = 16;
         break;
      case 4:
         v = 21;
         break;
      case 5:
         v = 26;
         break;
      case 6:
         v = 31;
         break;
      default:
         v = 6;
         break;
   }
   ObjectCreate(n, OBJ_TEXT, SubWin, Time[0], 50);
   ObjectSetString(MainWin, n, OBJPROP_TEXT, DoubleToString(k, 4)+"/"+DoubleToString(d, 4)+" ("+DoubleToString(k_1, 4)+"/"+DoubleToString(d_1, 4)+")"); 
   ObjectSetInteger(MainWin, n, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(MainWin, n, OBJPROP_COLOR, clrBlack);  
   ObjectSetDouble(MainWin,n,OBJPROP_ANGLE,90.0);
}
//------------------------------------------------------------------------------
void Arrow_Plot(int sig, int r)
{
   double v;   //value on Y axis (note: not pixels)
   string Name = IntegerToString(ObjGUID++);

   switch(r)   //Row on chart
   {
      case 1:
         v = 36;
         break;
      case 2:
         v = 41;
         break;
      case 3:
         v = 46;
         break;
      case 4:
         v = 51;
         break;
      case 5:
         v = 56;
         break;
      case 6:
         v = 61;
         break;
      case 7:
         v = 66;
         break;
      case 8:
         v = 71;
         break;
      default:
         v = 6;
         break;
   }

   if (sig == SIGNAL_LONG)
   {
      ObjectCreate(Name, OBJ_ARROW_UP, SubWin, Time[0], v);
      ObjectSet(Name, OBJPROP_COLOR, clrGreen);
    }
   else
   {
      ObjectCreate(Name,OBJ_ARROW_DOWN,SubWin,Time[0],v);
      ObjectSet(Name,OBJPROP_COLOR,clrRed);
   }
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Plot window label (s) to top left of indicator window
//-----------------------------------------------------------------------------------------------------------------------------------------
void Label_Plot(string s, int w, int r)
{
   string n = IntegerToString(ObjGUID++);
   double v;   //value on Y axis (pixels)

   switch(r)   //Row on chart
   {
      case 1:
         v = 0;
         break;
      case 2:
         v = 8;
         break;
      case 3:
         v = 16;
         break;
      case 4:
         v = 24;
         break;
      case 5:
         v = 32;
         break;
      case 6:
         v = 40;
         break;
      case 10:
         v = 100;
         break;
      default:
         v = 100;
         break;
   }

   ObjectCreate(n,OBJ_LABEL,w,0,v);
   ObjectSetText(n,s,7,NULL,clrBlack);
   ObjectSet(n,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(w, n,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSet(n,OBJPROP_XDISTANCE,0);
   ObjectSet(n,OBJPROP_YDISTANCE,v);//pixels
}

//END OF PROGRAM---------------------------------------------------------------------------------------------------------------------------