//+------------------------------------------------------------------+
//|                                                 MH_TradeUnit.mqh |
//+------------------------------------------------------------------+
//-----------------------------------------------------------------------------------------------------------------------------------------
// Trade Unit Class
//-----------------------------------------------------------------------------------------------------------------------------------------

#define  TAKEPROFIT  0   //Miner wants to let profits run and take profit by trailing profit stops, not by using Take Profit (TP)
#define  SLIPPAGE    0  //0 as not used for placing pending orders
#define  EXPIRATION  0


enum ENUM_TRADE_STATE
{
   STATE0,
   STATE1,
   STATE2,
   STATE3,
   STATE_HISTORY
};
//OP_BUY       = 0   Buy order
//OP_SELL      = 1   Sell order
//OP_BUYLIMIT  = 2   Buy limit pending order
//OP_SELLLIMIT = 3   Sell limit pending order
//OP_BUYSTOP   = 4   Buy stop pending order
//OP_SELLSTOP  = 5   Sell stop pending order

typedef ENUM_TRADE_STATE (*Function)(ENUM_TRADE_STATE);  //'Function' is defined as a pointer to a function
Function TS_STU_StateEvent[STATE3+1][OP_SELLSTOP+1];          //State Table is implemented as an array of pointers to functions, each of which performing a state/event action
Function TS_LTU_StateEvent[STATE3+1][OP_SELLSTOP+1];           //State Table is implemented as an array of pointers to functions, each of which performing a state/event action

void InitStateEvents()
{
         TS_STU_StateEvent[STATE0][OP_BUY]         = StateEventError;
         TS_STU_StateEvent[STATE0][OP_SELL]        = TS_STU_State0Sell;
         TS_STU_StateEvent[STATE0][OP_BUYLIMIT]    = StateEventError;
         TS_STU_StateEvent[STATE0][OP_SELLLIMIT]   = StateEventError;
         TS_STU_StateEvent[STATE0][OP_BUYSTOP]     = StateEventError;
         TS_STU_StateEvent[STATE0][OP_SELLSTOP]    = State0SellStop;

         TS_STU_StateEvent[STATE1][OP_BUY]         = StateEventError;
         TS_STU_StateEvent[STATE1][OP_SELL]        = TS_STU_State1Sell;
         TS_STU_StateEvent[STATE1][OP_BUYLIMIT]    = StateEventError;
         TS_STU_StateEvent[STATE1][OP_SELLLIMIT]   = StateEventError;
         TS_STU_StateEvent[STATE1][OP_BUYSTOP]     = StateEventError;
         TS_STU_StateEvent[STATE1][OP_SELLSTOP]    = StateEventError;
         
         TS_STU_StateEvent[STATE2][OP_BUY]         = StateEventError;
         TS_STU_StateEvent[STATE2][OP_SELL]        = TS_STU_State2Sell;
         TS_STU_StateEvent[STATE2][OP_BUYLIMIT]    = StateEventError;
         TS_STU_StateEvent[STATE2][OP_SELLLIMIT]   = StateEventError;
         TS_STU_StateEvent[STATE2][OP_BUYSTOP]     = StateEventError;
         TS_STU_StateEvent[STATE2][OP_SELLSTOP]    = StateEventError;
         
         TS_STU_StateEvent[STATE3][OP_BUY]         = StateEventError;
         TS_STU_StateEvent[STATE3][OP_SELL]        = StateEventError;
         TS_STU_StateEvent[STATE3][OP_BUYLIMIT]    = StateEventError;
         TS_STU_StateEvent[STATE3][OP_SELLLIMIT]   = StateEventError;
         TS_STU_StateEvent[STATE3][OP_BUYSTOP]     = StateEventError;
         TS_STU_StateEvent[STATE3][OP_SELLSTOP]    = StateEventError;
//-----------------------------------------------------------------------------------------------------------------------------------------
         TS_LTU_StateEvent[STATE0][OP_BUY]         = StateEventError;
         TS_LTU_StateEvent[STATE0][OP_SELL]        = TS_LTU_State0Sell;
         TS_LTU_StateEvent[STATE0][OP_BUYLIMIT]    = StateEventError;
         TS_LTU_StateEvent[STATE0][OP_SELLLIMIT]   = StateEventError;
         TS_LTU_StateEvent[STATE0][OP_BUYSTOP]     = StateEventError;
         TS_LTU_StateEvent[STATE0][OP_SELLSTOP]    = State0SellStop;

         TS_LTU_StateEvent[STATE1][OP_BUY]         = StateEventError;
         TS_LTU_StateEvent[STATE1][OP_SELL]        = TS_LTU_State1Sell;
         TS_LTU_StateEvent[STATE1][OP_BUYLIMIT]    = StateEventError;
         TS_LTU_StateEvent[STATE1][OP_SELLLIMIT]   = StateEventError;
         TS_LTU_StateEvent[STATE1][OP_BUYSTOP]     = StateEventError;
         TS_LTU_StateEvent[STATE1][OP_SELLSTOP]    = StateEventError;
         
         TS_LTU_StateEvent[STATE2][OP_BUY]         = StateEventError;
         TS_LTU_StateEvent[STATE2][OP_SELL]        = TS_LTU_State2Sell;
         TS_LTU_StateEvent[STATE2][OP_BUYLIMIT]    = StateEventError;
         TS_LTU_StateEvent[STATE2][OP_SELLLIMIT]   = StateEventError;
         TS_LTU_StateEvent[STATE2][OP_BUYSTOP]     = StateEventError;
         TS_LTU_StateEvent[STATE2][OP_SELLSTOP]    = StateEventError;
         
         TS_LTU_StateEvent[STATE3][OP_BUY]         = StateEventError;
         TS_LTU_StateEvent[STATE3][OP_SELL]        = TS_LTU_State3Sell;
         TS_LTU_StateEvent[STATE3][OP_BUYLIMIT]    = StateEventError;
         TS_LTU_StateEvent[STATE3][OP_SELLLIMIT]   = StateEventError;
         TS_LTU_StateEvent[STATE3][OP_BUYSTOP]     = StateEventError;
         TS_LTU_StateEvent[STATE3][OP_SELLSTOP]    = StateEventError;
}
//=========================================================================================================================================
//-----------------------------------------------------------------------------------------------------------------------------------------
// PLACE PENDING ORDER, TYPE = SELL STOP, FOR BOTH TRADE UNITS
//-----------------------------------------------------------------------------------------------------------------------------------------
#define UNITS  2  //number of units

void SellStop_TwoUnits_Order(double TCE)
{   LOG("");
   double OP, SL;
   SellStop_OpenPriceSL_Get(OP, SL);
   SellStop_Place_EnsureValid(OP, SL); //adjust OP and SL for STOPLEVEL and FREEZELEVEL

   double CE = MathAbs(SL-OP); /* capital exposure for Trade Unit Pair */
   double lots = TradeUnit_PositionSize_Get(CE);   /*Miner p.192 Max Position Size = Available Capital x Risk% / Capital Exposure per Unit */
   lots = lots / UNITS;                                  //Divide by 2 to get equal lotsize for STU and LTU
   lots = Lots_Normalize(lots);                          /*Ensure lots is a multiple of allowed lotsize */

   if (lots * UNITS * MarketInfo(_Symbol,MODE_MARGINREQUIRED) > AccountFreeMargin())  // if margin required to buy lots is larger than available margin
      LOG(StringFormat("Not enough free margin to cover %f required lots", lots));
   else
   {
//      Print("Line: ", __LINE__, " Total capital exposure: ", TCE, " + (current order CE: ", CE, " * lots: ", lots, " * Units: ", UNITS, ") = ", TCE+(CE*lots*UNITS), ".  Risk limit of 6% AccountEquity: ", RiskRatioTotal * Currency_ConvertDepositToQuote(AccountEquity()), " GBP");
      if (TCE + (CE * lots * UNITS) >= RiskRatioTotal * Currency_ConvertDepositToQuote(AccountEquity()))        //if total capital exposure over all trades > risk limit
      {
         LOG(": Total CE all trades > risk limit, so not placing orders. TCE + (CE * lots * UNITS) >= RiskRatioTotal * Currency_ConvertDepositToQuote(AccountEquity())");
         LOG(StringFormat(", %f + (%f * %f * %d) >=  %f * %f", TCE, CE, lots, UNITS, RiskRatioTotal, Currency_ConvertDepositToQuote(AccountEquity())));
      }
      else  
      {
         TCE += (CE * lots * UNITS);   //Add in to total
      //         MarketInfo_Print();
      //         AccountPropertiesFinancials_Print();
//--------------------------------------------Create Pending Order, Sell Stop, Short Term Unit
         TS *tu;
         tu = new TS_STU(lots, OP, SL);
         if (tu == NULL)
            LOG("Error in creating SellStop STU");
         else
            TradeUnits.AddObject(tu.ticket, tu);
//--------------------------------------------Create Pending Order, Sell Stop, Long Term Unit
         tu = new TS_LTU(lots, OP, SL);
         if (tu == NULL)
            LOG("Error in creating SellStop LTU");
         else
            TradeUnits.AddObject(tu.ticket, tu);
      }
   }
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Calculate total capital exposure for all open trades
//-----------------------------------------------------------------------------------------------------------------------------------------
double Orders_Trading_TotalCE_Calc()
{
   int i=1, j, Total = OrdersTotal();
   double TCE = 0;   //total CE

   for (j = 0; j < Total; j++)
   {
      while(TRUE)
      {
         if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
            break;
         else
            Error_Manage(i++);
      }
      
      if (OrderSymbol() != _Symbol)
      {
         LOG("Error: Invalid symbol - not open in current chart");
         continue;
      }
      if (OrderMagicNumber() != MagicNumber)
      {
         LOG("Error: Trade not for this EA");
         continue ;
      }

      RefreshRates();            //Get latest trade values

      switch(OrderType())
      {
         case OP_SELLSTOP:       //sell stop pending order
         case OP_SELL:           //sell order
            TCE += (OrderStopLoss() - Bid) * OrderLots();
            break;
         case OP_BUYSTOP:        //buy stop pending order
         case OP_BUY:            //Market Buy order executed from Buy Stop
         case OP_BUYLIMIT:       //buy limit pending order - ERROR
         case OP_SELLLIMIT:      //sell limit pending order - ERROR
         default: //ERROR
            LOG(StringFormat("Error: Invalid return from OrderType():", OrderType())); 
            break;
      }
   }
   return (TCE);
}
//=========================================================================================================================================
class TS : public CObject //Trade Short
  {
   public: 
      ENUM_TRADE_STATE State; //state
      int ticket;                      //Order Ticket associated with this trade object
         
      void           TS()     {   State = STATE0;  }
      virtual void Manage()   {                    }
};
//=========================================================================================================================================
class TS_STU : public TS   //Trade Short - Short Term Unit
{
   public:
      void TS_STU(double lots, double op, double sl)
      {  LOG(StringFormat("(%.2f, %.1f, %.1f)", lots, op, sl));

         ticket = SellStop_Place(lots, op, sl, "TS_STU_SS");
         Text_Plot(StringFormat("#%dTS_STU_SS", ticket), MainWin);
      }
      
      void Manage();
      void SellStop_Modify();
      void Sell_Modify();
};
//=========================================================================================================================================
class TS_LTU : public TS //Trade Short - Long Term Unit
{
   public:
      void TS_LTU(double lots, double op, double sl)
      {  LOG(StringFormat("(0, %.2f, %.1f, %.1f)", lots, op, sl));

         ticket = SellStop_Place(lots, op, sl, "TS_LTU_SS");
         Text_Plot(StringFormat("#%dTS_LTU_SS", ticket), MainWin);
      }
      void Manage();
};
//-----------------------------------------------------------------------------------------------------------------------------------------
// CALCULATE SWING HIGH FOR THE LAST n BARS
//-----------------------------------------------------------------------------------------------------------------------------------------
double CalcSwingHigh()
{
   int i, j = 0;
   double Highest = 0;
   double SH;
   
   RefreshRates();
   for (i = 1; i < SwingHigh; i++)
   {
      if (High[i] > High[i+1] && High[i] > High[i-1]) //if currently selected high is a potential swing high
         if (High[i] > Highest)                       //if hightest potential swing high so far
         {
            Highest = High[i];   //New highest
            j = i;               //New index of highest
         }
   }
    
   if(j > 0)   // swing high found
   {
      SH=High[j]; 
//#ifdef _DEBUG      Print("SwingHigh @: ", Time[j], " = ", SH); #endif
   }
   else
      SH=iHighest(NULL,0,MODE_HIGH,SwingHigh);   // swing high not found, so just return the highest value for the range
   return (SH);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
/* REQUIREMENTS AND LIMITATIONS IN MAKING TRADES
NOTE: Limit Orders and TakeProfit(TP) NOT USED BY ROBERT MINER SO THEY ARE LEFT OUT OF THE RULES BELOW

https://book.mql4.com/trading/orders
The limitation related to the position of stop orders of a pending order is calculated on the basis of the *requested open price* of the pending order and has *no relation to market prices*.
The term 'OpenPrice' below == "Requested Open Price".
StopLoss and TakeProfit of a pending order cannot be placed closer to the requested price (OpenPrice) than at the minimum distance.
The positions of StopLoss and TakeProfit of pending orders are not limited by freeze distance.

https://book.mql4.com/appendix/limits
Tables below show calculation values that limit the conduction of trades when opening, closing, placing, deleting or modifying orders.
To get the minimum distance to StopLevel and freezing distance FreezeLevel the MarketInfo() function should be called.

REQUIREMENTS
Correct prices used when performing trade operations:
-----------------------------------------------------------------------------------------------------------------------------
Order Type     Open Price     Close Price    Open Price of a Pending Order    Transforming a Pending Order into aMarket Order
-----------------------------------------------------------------------------------------------------------------------------
Buy            Ask            Bid
Sell           Bid            Ask
BuyStop                                      Above the current Ask price      Ask price reaches open price
SellStop                                     Below the current Bid price      Bid price reaches open price
-----------------------------------------------------------------------------------------------------------------------------

STOPLEVEL MINIMUM DISTANCE LIMITATION
A trade operation will not be performed if any of the following conditions are disrupted:
-----------------------------------------------------------------------------------------------------------------------------
Order Type     Open Price                    StopLoss(SL)                  
-----------------------------------------------------------------------------------------------------------------------------
Buy            Modification is prohibited    Bid-SL ≥ StopLevel
Sell           Modification is prohibited    SL-Ask ≥ StopLevel
BuyStop        OpenPrice-Ask ≥ StopLevel	   OpenPrice-SL ≥ StopLevel
SellStop       Bid-OpenPrice ≥ StopLevel	   SL-OpenPrice ≥ StopLevel
-----------------------------------------------------------------------------------------------------------------------------

FREEZELEVEL LIMITATION (FREEZING DISTANCE)
(ROBERT MINER DOES NOT REQUIRE ORDERCLOSE OF MARKET ORDERS AS ONLY RELIES ON THE MARKET TAKING OUT THE TRADE VIA SL.)  A Market order can not be closed if the StopLoss value violates the FreezeLevel parameter requirements.
A Pending order can not be deleted or modified if the declared open price (OpenPrice) violates the FreezeLevel parameter requirements.
-----------------------------------------------------------------------------------------------------------------------------
Order Type     Open Price	                  StopLoss (SL)
-----------------------------------------------------------------------------------------------------------------------------
Buy            Modification is prohibited	   Bid-SL > FreezeLevel
Sell           Modification is prohibited    SL-Ask > FreezeLevel
BuyStop        OpenPrice-Ask > FreezeLevel	Regulated by the StopLevel parameter
SellStop       Bid-OpenPrice > FreezeLevel	Regulated by the StopLevel parameter
-----------------------------------------------------------------------------------------------------------------------------
*/
#define  STOPLEVEL_SELL_SL       ((SL-Ask) >= StopLevel)          //SL-Ask ≥ StopLevel
#define  STOPLEVEL_SELLSTOP_OP   ((Bid-OpenPrice) >= StopLevel)   //Bid-OpenPrice ≥ StopLevel
#define  STOPLEVEL_SELLSTOP_SL   ((SL-OpenPrice) >= StopLevel)    //SL-OpenPrice ≥ StopLevel
#define  FREEZELEVEL_SELL_SL     ((SL-Ask) > FreezeLevel)         //SL-Ask > FreezeLevel
#define  FREEZELEVEL_SELLSTOP_OP ((Bid-OpenPrice) > FreezeLevel)  //Bid-OpenPrice > FreezeLevel
//-----------------------------------------------------------------------------------------------------------------------------------------
// EnsureValid OP and SL for SellStop Place
//-----------------------------------------------------------------------------------------------------------------------------------------
void SellStop_Place_EnsureValid(double &OpenPrice, double &SL)
{
   RefreshRates();
   double StopLevel = MarketInfo(_Symbol,MODE_STOPLEVEL) * Point;   //Point is the current symbol point value in the *quote* currency
   LOG(StringFormat("!((Bid-OpenPrice) >= StopLevel) == !(%.1f-%.1f) = %.1f >= %0.1f == %d", Bid, OpenPrice, Bid-OpenPrice, StopLevel, !STOPLEVEL_SELLSTOP_OP));
   if (!STOPLEVEL_SELLSTOP_OP)   //if OpenPrice too close
   {
      OpenPrice = Bid - StopLevel;  /* Price set to minimum distance below Bid */
      LOG(StringFormat("Wanted price within StopLevel ... Resetting Wanted price to closest. OpenPrice = Bid - StopLevel = %.1f-%.0f = %.1f", Bid, StopLevel, Bid - StopLevel));
   }
   OpenPrice = NormalizeDouble(OpenPrice, Digits);

   LOG(StringFormat("!((SL-OpenPrice) >= StopLevel) == !(%.1f-%.1f) = %.1f >= %0.1f == %d", SL, OpenPrice, SL-OpenPrice, StopLevel, !STOPLEVEL_SELLSTOP_SL));
   if (!STOPLEVEL_SELLSTOP_SL)          //if SL too close
   {
      SL = OpenPrice + StopLevel;
      LOG(StringFormat("Wanted SL within StopLevel. Resetting Wanted SL to closest. SL = OpenPrice + StopLevel = %.1f+%.0f = %.1f", OpenPrice, StopLevel, OpenPrice + StopLevel));
   }
   SL = NormalizeDouble(SL, Digits);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// EnsureValid OP and SL for SellStop Modify
//-----------------------------------------------------------------------------------------------------------------------------------------
void SellStop_ModifyDelete_EnsureValid(double &OpenPrice, double &SL)
{   LOG("");
   RefreshRates();

   double StopLevel = MarketInfo(_Symbol,MODE_STOPLEVEL) * Point;   //Point is the current symbol point value in the *quote* currency

   if (!STOPLEVEL_SELLSTOP_OP)   //if OpenPrice too close
   {
      OpenPrice = Bid - StopLevel;  /* Price set to minimum distance below Bid */
      LOG(StringFormat("Wanted OpenPrice within StopLevel ... Resetting Wanted OpenPrice to closest. OpenPrice = Bid - StopLevel = %.1f-%.0f = %.1f", Bid, StopLevel, Bid - StopLevel));
   }
   OpenPrice = NormalizeDouble(OpenPrice, Digits);


   LOG(StringFormat("!((SL-OpenPrice) >= StopLevel) == !(%.1f-%.1f) = %.1f >= %0.1f == %d", SL, OpenPrice, SL-OpenPrice, StopLevel, !STOPLEVEL_SELLSTOP_SL));
 
   if (!STOPLEVEL_SELLSTOP_SL)          //if SL too close
   {
      SL = OpenPrice + StopLevel;
      LOG(StringFormat("Wanted SL within StopLevel. Resetting Wanted SL to closest. SL = OpenPrice + StopLevel = %.1f+%.0f = %.1f", OpenPrice, StopLevel, OpenPrice + StopLevel));
   }
   SL = NormalizeDouble(SL, Digits);


   double FreezeLevel = MarketInfo(_Symbol,MODE_FREEZELEVEL) * Point;   //Point is the current symbol point value in the *quote* currency
   LOG("Bid = "+string(Bid)+"; OpenPrice = "+string(OpenPrice)+"; SL = "+string(SL)+"; FreezeLevel = "+string(FreezeLevel));
   if (!FREEZELEVEL_SELLSTOP_OP)   //if OpenPrice too close
   {
      OpenPrice = Bid - FreezeLevel;  /* Price set to minimum distance below Bid */
      LOG(StringFormat("Wanted OpenPrice within FreezeLevel ... Resetting Wanted OpenPrice to closest. OpenPrice = Bid - FreezeLevel = %.1f-%.0f = %.1f", Bid, FreezeLevel, Bid - FreezeLevel));
   }
   OpenPrice = NormalizeDouble(OpenPrice, Digits);

}
//-----------------------------------------------------------------------------------------------------------------------------------------
// EnsureValid SL for Sell Modify
//-----------------------------------------------------------------------------------------------------------------------------------------
void Sell_SL_EnsureValid(double &SL)
{
   RefreshRates();

   double StopLevel = MarketInfo(_Symbol,MODE_STOPLEVEL) * Point;   //Point is the current symbol point value in the *quote* currency

   LOG(StringFormat("!((SL-Ask) >= StopLevel) == !(%.1f-%.1f) = %.1f >= %0.1f == %d", SL, Ask, SL-Ask, StopLevel, !STOPLEVEL_SELL_SL));
 
   if (!STOPLEVEL_SELL_SL)          //if SL too close
   {
      SL = Ask + StopLevel;
      LOG(StringFormat("Wanted SL within StopLevel. Resetting Wanted SL to closest. SL = Ask + StopLevel = %.1f+%.0f = %.1f", Ask, StopLevel, Ask + StopLevel));
   }
   SL = NormalizeDouble(SL, Digits);


   double FreezeLevel = MarketInfo(_Symbol,MODE_FREEZELEVEL) * Point;
//#ifdef _DEBUG   printf("!((SL-Ask) >= FreezeLevel) == !(%.1f-%.1f >= %0.1f == %d", SL, Ask, FreezeLevel, !FREEZELEVEL_SELL_SL); #endif
   if (!FREEZELEVEL_SELL_SL)          //if SL too close
   {
      SL = Ask + FreezeLevel;
      LOG(StringFormat("Wanted SL within FreezeLevel. Resetting Wanted SL to closest. SL = Ask + FreezeLevel = %.1f+%.0f = %.1f", Ask, FreezeLevel, Ask + FreezeLevel));
   }
   SL = NormalizeDouble(SL, Digits);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Adjust the target entry price to Tr-1BL (last bar low minus 1 point (tick)
//Adjust SellStop SL to the latest before entry (See p.142) ... The initial protective buy-stop was placed one tick above the bar number 3 high (Swing High)
//-----------------------------------------------------------------------------------------------------------------------------------------
void SellStop_OpenPriceSL_Get(double &op, double &sl)
{
   RefreshRates();
   op=Low[1]-Point;   /* Miner ... The target entry price is set by Tr-1BL (last bar low minus 1 point (tick) */

   sl = CalcSwingHigh() + Point;      /* stop loss level. Requested price of SL: ref Miner, SL = swing high + 1 tick */

   LOG(StringFormat("Wanted SellStop OpenPrice = Low[1]-Point = %.1f-%.1f = %.1f", Low[1], Point, op));
   LOG(StringFormat("Wanted SellStop SL = CalcSwingHigh+Point = %.1f+%.1f = %.1f", CalcSwingHigh(), Point, sl));
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// PLACE SELL STOP ORDER
//-----------------------------------------------------------------------------------------------------------------------------------------
int SellStop_Place(double lots, double op, double sl, string comment)
{
   
   int t=0;   //ticket         
   int i = 1;  //retry counter
   
   while (TRUE)
   {
//      else if (!IsTradeAllowed()) //is Expert Advisor not allowed to trade OR trading context is busy? ****** NEED TO REPLACE THIS WITH A SEMAPHORE AT THE TOP LEVEL INSTEAD
//TODO: decide whether to calculate lots again as price may have moved
      SellStop_Place_EnsureValid(op, sl);
      if ((t = OrderSend(_Symbol, OP_SELLSTOP, lots, op, SLIPPAGE, sl, TAKEPROFIT, comment, MagicNumber, EXPIRATION, clrGreen)) >= 0)
         break;      //SUCCESS - break out of retry loop
      Error_Manage(i++);
   }
//      Log(string(__LINE__)+StringFormat(": OrderSend(OP_SELLSTOP, lots=%.2f, op=%.0f, sl=%.0f) => ticket=%d", lots, op, sl, ticket)); 
//   OrderPrint();           //print out details of the order
   Text_Plot(StringFormat("#%dSSPlace(SL&OP)", t), MainWin);
   return (t);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// SELL TRADE ENTRY STRATEGY Tr-1BL & STOP SWING HIGH + 1: OPERATION: MODIFY SELL STOP ACCORDING TO Tr-1BL. USED FOR BOTH LT AND ST UNITS
// MODIFY PENDING ORDER, TYPE = SELL STOP

// ENTRY STRATEGY - TRAILING ONE BAR ENTRY and STOP (Miner p140)
// P140: Once the conditions are in place for a reversal and following the lower time frame momentum reversal, trail
// the sell-stop to enter the trade one tick below the low of the last completed bar.
// Place the protective stop one tick beyond the swing high made prior to entry.
//-----------------------------------------------------------------------------------------------------------------------------------------
void SellStop_Modify()
{   LOG(": Modifying Sell Stop Order at Tr-1BL");
   double OP, SL;
   int i = 1;  //retry counter

   while (TRUE)
   {
      SellStop_OpenPriceSL_Get(OP, SL);
      SellStop_ModifyDelete_EnsureValid(OP, SL);
      if (OP > OrderOpenPrice()) //if wanted SellStop.OpenPrice is greater than current SellStop.OpenPrice, then modify the SellStop.OpenPrice upwards (to respect Tr-1BL rule)
      {
         LOG("OrderModify(ticket=#"+(string)OrderTicket()+", OP="+(string)OP+", SL="+string(SL)+", ...)");
         if (OrderModify(OrderTicket(), OP, SL, TAKEPROFIT, EXPIRATION, Blue))     //Take profit level is 0 - Miner wants to let profits run and take profit by trailing profit stops
            break;      //SUCCESS - break out of retry loop
         Error_Manage(i++);
      }
      else
         break;      //Break out of retry loop
      Text_Plot(StringFormat("#%dSSMod(SL&OP)@Tr-1BL", OrderTicket()), MainWin);
   }
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// SELLSTOP DELETE
// DELETE PENDING ORDER
//-----------------------------------------------------------------------------------------------------------------------------------------
void SellStop_Delete()
{
   int i = 1;  //retry counter

   while (TRUE)
   {
//IF ORDERDELETE IS WITHIN FREEZELEVEL THEN IT WILL RETURN ERROR - SO NEED TO REPEAT ORDERDELETE UNTIL IT RETURNS SUCCESSFULLY
      if (OrderDelete(OrderTicket()))   //Delete Pending Order
         break;      //SUCCESS - break out of retry loop
      Error_Manage(i++);
   }
   Text_Plot(StringFormat("#%dSSDel", OrderTicket()), MainWin);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// SELL TRADE EXIT STRATEGY Tr-1BH: OPERATION: MODIFY SELL SL ACCORDING TO Tr-1BH. USED FOR BOTH LT AND ST UNITS
// MODIFY MARKET ORDER, TYPE = SELL
//-----------------------------------------------------------------------------------------------------------------------------------------
//Miner p.172 Trade management (short-term unit): Trail the SL at the 1B(H).
void Sell_Modify()
{   LOG("");
   int i = 1;  //retry counter

   while (TRUE)
   {
      RefreshRates();
      double sl = High[1] + Point;      //stop loss level. Wanted price of SL: Tr-1BH, SL = last High + 1 point
      LOG(StringFormat("Wanted Sell SL = Tr_1BH = High[1]+Point = %.1f+%.1f = %.1f", High[1], Point, sl));
      Sell_SL_EnsureValid(sl);
   
      if (sl < OrderStopLoss()) //if wanted SL is less than current SL, then modify the SL downwards (to respect Tr-1BH rule)
      {
         if (OrderModify(OrderTicket(), OrderOpenPrice(), sl, 0, 0, Blue))//Take profit level is 0 - Miner wants to let profits run and take profit by trailing profit stops
            break;      //SUCCESS - break out of retry loop
         Error_Manage(i++);
      }
      else
         break;      //Break out of retry loop      
   }
   Text_Plot(StringFormat("#%dSELL Sell_Modify", OrderTicket()), MainWin);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Manage Trade Short - Short Term Unit from Entry to Exit
// Miner p.172 if market reaches the 61.8% retracement OR following the second daily momentum bearish reversal
// then Trail the SL at the 1BH 
//-----------------------------------------------------------------------------------------------------------------------------------------/*
void TS_STU::Manage()
{  LOG("");

   if (State != STATE_HISTORY)   //only process active trades for efficiency (those not in history pool - server closed orders or deleted pending orders)
   {
      if (OrderSelect(ticket, SELECT_BY_TICKET) == False)   //doesn't need pool parameter as ticket is unique across pools
         Print("Error: Line: ", __LINE__, ". ErrorCode: ", GetLastError(), ", Description: ",ErrorDescription(GetLastError()));
      else if (OrderCloseTime() > 0)  //if Close Time > 0, then order must have just been closed by server and now in history pool 
      {
         Text_Plot(StringFormat("#%dTS_STU SELL Closed", OrderTicket()), MainWin);
         State = STATE_HISTORY;
      }
      else //else order must be in trading pool (open or pending orders)
      {
         LOG(": State: "+ (string)State + ", Event: " + (string)OrderType() + ", ticket: #" + (string)OrderTicket());
         State = TS_STU_StateEvent[State][OrderType()](State);   //Call the function relating to State and Event combination to perform the action
      }
   }
}
//=========================================================================================================================================
// Manage Long Term Unit of OP_SELL Trade from Entry to Exit
// Deduced from Miner p.180.  If a second LTF momentum bullish reversal occurs AFTER the HTF (weekly) momentum reaches the OS zone, then trail the stop at the LTF 1BH
// (TODO: OR trail the stop at the 1BH if the market reaches a probable Wave-C price target.)
//-----------------------------------------------------------------------------------------------------------------------------------------
void TS_LTU::Manage()
{  LOG("");

   if (State != STATE_HISTORY)   //only process active trades for efficiency (those not in history pool - server closed orders or deleted pending orders)
   {
      if (OrderSelect(ticket, SELECT_BY_TICKET) == False)   //doesn't need pool parameter as ticket is unique across pools
         Print("Error: Line: ", __LINE__, ". ErrorCode: ", GetLastError(), ", Description: ",ErrorDescription(GetLastError()));
      else if (OrderCloseTime() > 0)  //if Close Time > 0, then order must have just been closed by server and now in history pool 
      {
         Text_Plot(StringFormat("#%dTS_LTU SELL Closed", OrderTicket()), MainWin);
         State = STATE_HISTORY;
      }else //else order must be in trading pool (open or pending orders)
      {
         LOG(": State: "+ (string)State + ", Event: " + (string)OrderType() + ", ticket: #" + (string)OrderTicket());
         State = TS_LTU_StateEvent[State][OrderType()](State);   //Call the function relating to State and Event combination to perform the action
      }
   }
}
//=========================================================================================================================================
//ENTRY STRATEGY for both short term and long term units
//State 0   initial state - Setup has been achieved and state is now waiting for Trade Entry (SELL EVENT)
//State=0 Event= SELLSTOP - sell still pending, so modify Sell Stop Pending Order at Tr-1BL.  If LTF stochastic is bullish reversal or oversold, then delete pending order.

   // Miner p.142 Following the lower time frame momentum bearish reversal, the Tr-1BL entry strategy continues as long as the momentum remains bearish and does not reach the oversold zone.
   // If the momentum makes a bullish reversal or reaches the oversold zone before a Tr-1BL is taken out and the trade executed, the entry is canceled.
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE State0SellStop(ENUM_TRADE_STATE st)
{  LOG("");

   if (BullishReversalOrOversold())  //if STOCH is BullishReversal or Oversold on previous bar
   {
      LOG(": STOCH is BullishReversal or Oversold on previous bar, Deleting Sell Stop Pending Order #"+(string)OrderTicket());
      SellStop_Delete();

      st = STATE_HISTORY;
      Text_Plot(StringFormat("#%dLTFBullRevOrOS>SS_Del", OrderTicket()), MainWin);
   }
   else
   {
      LOG(": STOCH not BullishReversal or Oversold on previous bar, so modifying Tr-1BL Sell Stop Pending Order #"+(string)OrderTicket());
      SellStop_Modify();   //Modify Sell Stop Pending Order for one trade unit at Tr-1BL
   }
   
   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
// State = 0, initial state - Trade Setup condition achieved, waiting for Trade Entry (SELL EVENT)
// Event = SELL, trade just entered
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_STU_State0Sell(ENUM_TRADE_STATE st)
{  LOG("");

   Text_Plot(StringFormat("#%dTS_STU SELL", OrderTicket()), MainWin);

   if (LTF_BullishReversal())   //if first LTF Bullish Reversal found
   {
   //            printf("FIRST BULLISH REVERSAL for OrderTicket: %d, changing Trade state to 1", ticket);
      Text_Plot(StringFormat(" 1LTF BullRev", OrderTicket()), MainWin);
      st = STATE1;    //change state to indicate first BullishReversal occurance
   }
   
   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
// State = 1, First Bullish Reversal found
// Event = SELL
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_STU_State1Sell(ENUM_TRADE_STATE st)
{  LOG("");
   if (LTF_BullishReversal())   //if second LTF Bullish Reversal found (pp.172 if the price either reaches the 61.8% retracement or following the second daily momentum (bullish) reversal)
   {
  //            printf("SECOND BULLISH REVERSAL found for OrderTicket: %d, changing Trade state to 2 and start trailing SL @ Tr-1BH on ST-Unit", ticket);
      Text_Plot(StringFormat("#%dTS_STU SELL 2LTF BullRev>Sell_Modify", OrderTicket()), MainWin);
      Sell_Modify();   //Start trailing SL @ Tr-1BH on ST unit
      st = STATE2;    //change state to indicate second BullishReversal occurance
   }
   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
// State = 2, Second Bullish Reversal found
// Event = SELL
// Action = Tr_1BH
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_STU_State2Sell(ENUM_TRADE_STATE st)
{  LOG("");
   Text_Plot(StringFormat("#%dTS_STU SELL>Sell_Modify", OrderTicket()), MainWin);
   Sell_Modify();   //Keep trailing SL @ Tr-1BH on ST unit
   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
//LONG TERM UNIT
// State = 0, initial state - Trade Setup condition achieved, waiting for Trade Entry (SELL EVENT)
// Event = SELL, trade just entered
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_LTU_State0Sell(ENUM_TRADE_STATE st)
{  LOG("");

   Text_Plot(StringFormat("#%dTS_LTU SELL", OrderTicket()), MainWin);
   
   if (HTF_Oversold())   //if HTF is Oversold
   {
      LOG(StringFormat("HTF is Oversold for LongTerm Unit, OrderTicket: %d, changing Trade state to 1", OrderTicket()));
      Text_Plot(StringFormat("#%dTS_LTU SELL HTF Oversold", OrderTicket()), MainWin);
      st = STATE1;    //change state to indicate HTF oversold occurance
      if (LTF_BullishReversal())   //if a LTF bullish Reversal found
      {
         LOG(StringFormat("FIRST BULLISH REVERSAL found after HTF OS for OrderTicket: #%d, changing Trade state to 2", OrderTicket()));
         Text_Plot(StringFormat(" 1st LTF BullRev", OrderTicket()), MainWin);
         st = STATE2;    //change state to indicate first BullishReversal occurance after HTF is OS
      }
   }

   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
//LONG TERM UNIT
// State = 1, HTF Oversold
// Event = SELL
// Condition = if first LTF momentum bullish reversal ocurred
// Action = Change state to 2 to indicate first LTF momentum bullish reversal ocurred 
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_LTU_State1Sell(ENUM_TRADE_STATE st)
{  LOG("");

   if (LTF_BullishReversal())   //if a LTF bullish Reversal found
   {
      LOG(StringFormat("FIRST BULLISH REVERSAL found after HTF OS for OrderTicket: #%d, changing Trade state to 2", OrderTicket()));
      Text_Plot(StringFormat("#%dTS_LTU SELL 1st LTF BullRev", OrderTicket()), MainWin);
      st = STATE2;    //change state to indicate first BullishReversal occurance after HTF is OS
   }

   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
//LONG TERM UNIT
// Description: HTF oversold AND First Bullish Reversal found, check for second Bullish Reversal and start trailing SL @ Tr-1BH
// State = 2, HTF Oversold and First Bullish Reversal found
// Event = SELL
// Condition = if second LTF momentum bullish reversal ocurred
// Action = Tr_1BH and change state to 3
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_LTU_State2Sell(ENUM_TRADE_STATE st)
{  LOG("");

   if (LTF_BullishReversal())   //if second Bullish Reversal found
   {
      LOG(StringFormat("SECOND BULLISH REVERSAL found after HTF OS for OrderTicket: #%d, start trailing SL @ Tr-1BH on ST-Unit and change Trade state to 3", OrderTicket()));
      Text_Plot(StringFormat("#%dTS_LTU SELL 2nd LTF BullRev>Sell_Modify", OrderTicket()), MainWin);
      Sell_Modify();   //Trail SL @ Tr-1BH
      st = STATE3;    //change state to indicate second BullishReversal occurance after HTF is OS
   }

   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
//LONG TERM UNIT
// Description: HTF oversold AND Second Bullish Reversal found, keep trailing SL @ Tr-1BH
// State = 2, HTF Oversold and Second Bullish Reversal found
// Event = SELL
// Condition = None
// Action = Tr_1BH
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE TS_LTU_State3Sell(ENUM_TRADE_STATE st)
{  LOG("");

   Text_Plot(StringFormat("#%dTS_LTU SELL>Sell_Modify", OrderTicket()), MainWin);
   Sell_Modify();   //Trail SL @ Tr-1BH
   return (st);
};
//-----------------------------------------------------------------------------------------------------------------------------------------
ENUM_TRADE_STATE StateEventError(ENUM_TRADE_STATE st)
{  LOG(": ERROR Invalid State/Event combination: State: "+ (string)st + ", Event: " + (string)OrderType() + ", ticket: #" + (string)OrderTicket() + ",  OrderCloseTime: " + (string)OrderCloseTime());
   return (st);
};