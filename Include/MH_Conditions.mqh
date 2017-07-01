//-----------------------------------------------------------------------------------------------------------------------------------------
// CONDITIONS BASED ON STOCHASTICS
//-----------------------------------------------------------------------------------------------------------------------------------------
// DETECT TRADE SETUP FOR LONG OR SHORT
//-----------------------------------------------------------------------------------------------------------------------------------------
int EntrySetup()
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
// DETECT IF LOWEST TIMEFRAME STOCH BULLISH REVERSAL OR OVERSOLD
//-----------------------------------------------------------------------------------------------------------------------------------------
int BullishReversalOrOversold()
{
   bool K1XO = K1_1<=D1_1 && K1>D1;        //K1 Xover
   bool oversold = K1 <= OS && D1 <= OS;  //Oversold //Miner p.37 both the fast and slow line must be in the OB or OS zone to consider the indicator OB or OS

/*   if (K1XO)
      Print("Bullish Reversal detected");
   if (oversold)
      Print("Oversold detected");
   if (K1XO || oversold)
      Print("K1_1: ", K1_1, ", D1_1: ", D1_1, ", K1: ", K1, " D1: ", D1);
*/
   return(K1XO || oversold);
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
// Get latest Stoch values
//-----------------------------------------------------------------------------------------------------------------------------------------
void Stoch_Update()
{
// Save values for next time through
   K1_1 = K1;
   K2_1 = K2;
   K3_1 = K3;
   K4_1 = K4;
   K5_1 = K5;
   K6_1 = K6;
   K7_1 = K7;
   K8_1 = K8;
   K9_1 = K9;

   D1_1 = D1;
   D2_1 = D2;
   D3_1 = D3;
   D4_1 = D4;
   D5_1 = D5;
   D6_1 = D6;
   D7_1 = D7;
   D8_1 = D8;
   D9_1 = D9;

   K1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K2 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K3 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K4 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);

   K5 = iStochastic(NULL, period5, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K6 = iStochastic(NULL, period6, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K7 = iStochastic(NULL, period7, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K8 = iStochastic(NULL, period8, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);
   K9 = iStochastic(NULL, period9, K, D, slowing, MODE_SMA, pf, MODE_MAIN, 0);


   D1 = iStochastic(NULL, period1, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D2 = iStochastic(NULL, period2, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D3 = iStochastic(NULL, period3, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D4 = iStochastic(NULL, period4, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);

   D5 = iStochastic(NULL, period5, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D6 = iStochastic(NULL, period6, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D7 = iStochastic(NULL, period7, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D8 = iStochastic(NULL, period8, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
   D9 = iStochastic(NULL, period9, K, D, slowing, MODE_SMA, pf, MODE_SIGNAL, 0);
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
   period5 = p[i+4];
   period6 = p[i+5];
   period7 = p[i+6];
   period8 = p[i+7];
   period9 = p[i+8];

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
   
   if (SelectedTimeframe > 5)
   {
      LOG("InitPeriodsOpt(): ERROR - CANNOT SELECT THIS TIMEFRAME, EXITING PROGRAM");
      TerminalClose(0);     //EXIT PROGRAM!!!
      return;
   }
   
   period1 = p[SelectedTimeframe];
   period2 = p[SelectedTimeframe+1];
   period3 = p[SelectedTimeframe+2];
   period4 = p[SelectedTimeframe+3];
   LOG(StringFormat("InitPeriodsOpt(): Timeframes selected: current: %d, current+1: %d, current+2: %d, current+3: %d", period1, period2, period3));
}
