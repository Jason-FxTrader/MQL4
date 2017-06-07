//+------------------------------------------------------------------+
//|                                                      HAN_Z-Score |
//|                                  Copyright © 2013, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, EarnForex"
#property link      "http://www.earnforex.com"

#include <stdlib.mqh>

/*

Uses Heiken Ashi candles.
Sells on bullish HA candle, its body is longer than previous body, previous also bullish, and current candle has no lower wick.
Buys on bearish HA candle, its body is longer than previous body, previous also bearish, and current candle has no upper wick.
Exit shorts on bearish HA candle and current candle has no upper wick, previous also bearish.
Exit longs on bullish HA candle and current candle has no lower wick, previous also bullish.
Z-Score optimization with file save/load.

*/

// Money management
extern double Lots = 0.1; 		// Basic lot size
extern bool MM  = false;  	// If true - ATR-based position sizing
extern int ATR_Period = 20;
extern double ATR_Multiplier = 1;
extern double Risk = 2; // Risk tolerance in percentage points
extern double FixedBalance = 0; // If greater than 0, position size calculator will use it instead of actual account balance.
extern double MoneyRisk = 0; // Risk tolerance in base currency
extern bool UseMoneyInsteadOfPercentage = false;
extern bool UseEquityInsteadOfBalance = false;
extern int LotDigits = 2; // How many digits after dot supported in lot size. For example, 2 for 0.01, 1 for 0.1, 3 for 0.001, etc.

// Miscellaneous
extern string OrderCommentary = "HAN_Z-Score";
extern int Slippage = 100; 	// Tolerated slippage in brokers' pips
extern int Magic = 1507122013; 	// Order magic number
extern bool Mute = false; // No output about virtual trading
extern string FileName = "HAN_vt.dat";

// Global variables
// Common
int LastBars = 0;
bool HaveLongPosition;
bool HaveShortPosition;
double StopLoss; // Not actual stop-loss - just a potential loss of MM estimation.

// Trade virtualization for Z-Score optimization
bool   TradeBlock = false; // Blocks real trading, allowing virutal
int    VirtualDirection;
bool   VirtualOpen = false;
double VirtualOP; // Open price for virtual position
int    BlockTicket = -1; // The order ticket, after which real trading was blocked.
int fh; // File handle for saving and loading virtual trading data

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int init()
{
   LoadFile();
   fh = FileOpen(FileName, FILE_WRITE|FILE_BIN);
   return(0);    
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Each tick                                                        |
//+------------------------------------------------------------------+
int start()
{
   if ((!IsTradeAllowed()) || (IsTradeContextBusy()) || (!IsConnected()) || ((!MarketInfo(Symbol(), MODE_TRADEALLOWED)) && (!IsTesting()))) return(0);

	// Trade only if new bar has arrived
	if (LastBars != Bars) LastBars = Bars;
	else return(0);
   
   if (MM)
   {
      // Getting the potential loss value based on current ATR.
      StopLoss = iATR(NULL, 0, ATR_Period, 1) * ATR_Multiplier;
   }

   // Close conditions   
   bool BearishClose = false;
   bool BullishClose = false;
   
   // Signals
   bool Bullish = false;
   bool Bearish = false;

   // Heiken Ashi indicator values
   double HAOpenLatest, HAOpenPrevious, HACloseLatest, HAClosePrevious, HAHighLatest, HALowLatest;

   HAOpenLatest = iCustom(NULL, 0, "Heiken Ashi", 2, 1);
   HAOpenPrevious = iCustom(NULL, 0, "Heiken Ashi", 2, 2);
   HACloseLatest = iCustom(NULL, 0, "Heiken Ashi", 3, 1);
   HAClosePrevious = iCustom(NULL, 0, "Heiken Ashi", 3, 2);
   if (HAOpenLatest >= HACloseLatest) HAHighLatest = iCustom(NULL, 0, "Heiken Ashi", 0, 1);
   else HAHighLatest = iCustom(NULL, 0, "Heiken Ashi", 1, 1);
   if (HAOpenLatest >= HACloseLatest) HALowLatest = iCustom(NULL, 0, "Heiken Ashi", 1, 1);
   else HALowLatest = iCustom(NULL, 0, "Heiken Ashi", 0, 1);
   
   // REVERSED!!!
   
   // Close signals
   // Bullish HA candle, current has no lower wick, previous also bullish
   if ((HAOpenLatest < HACloseLatest) && (HALowLatest == HAOpenLatest) && (HAOpenPrevious < HAClosePrevious))
   {
      BullishClose = true;
   }
   // Bearish HA candle, current has no upper wick, previous also bearish
   else if ((HAOpenLatest > HACloseLatest) && (HAHighLatest == HAOpenLatest) && (HAOpenPrevious > HAClosePrevious))
   {
      BearishClose = true;
   }

   // Sell entry condition
   // Bullish HA candle, and body is longer than previous body, previous also bullish, current has no lower wick
   if ((HAOpenLatest < HACloseLatest) && (HACloseLatest - HAOpenLatest > MathAbs(HAClosePrevious - HAOpenPrevious)) && (HAOpenPrevious < HAClosePrevious) && (HALowLatest == HAOpenLatest))
   {
      Bullish = false;
      Bearish = true;
   }
   // Buy entry condition
   // Bearish HA candle, and body is longer than previous body, previous also bearish, current has no upper wick
   else if ((HAOpenLatest > HACloseLatest) && (HAOpenLatest - HACloseLatest > MathAbs(HAClosePrevious - HAOpenPrevious)) && (HAOpenPrevious > HAClosePrevious) && (HAHighLatest == HAOpenLatest))
   {
      Bullish = true;
      Bearish = false;
   }
   else
   {
      Bullish = false;
      Bearish = false;
   }
   
   GetPositionStates();
   
   if ((HaveShortPosition) && (BearishClose)) ClosePrevious();
   if ((HaveLongPosition) && (BullishClose)) ClosePrevious();

   // Virtual trading - blocking trading following a profitable trade.
   // Positive Z-Score means that losers are likely to be followed by winners and vice versa.
   if (!TradeBlock)
   {
      int tickets[];
      int nTickets = GetHistoryOrderByCloseTime(tickets);

      OrderSelect(tickets[0], SELECT_BY_TICKET);
      if ((OrderProfit() > 0) && (OrderTicket() != BlockTicket))
      {
         TradeBlock = true;
         BlockTicket = OrderTicket();
         SaveFile();
         if (!Mute) Print("Real trading blocked on: ", tickets[0], " ", OrderOpenPrice(), " ", OrderProfit());
      }
   }

   if (Bullish)
   {
      if (!HaveLongPosition) fBuy();
   }
   else if (Bearish)
   {
      if (!HaveShortPosition) fSell();
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Check what position is currently open										|
//+------------------------------------------------------------------+
void GetPositionStates()
{
   if (TradeBlock) // Virtual Check
   {
      if (VirtualOpen)
      {
         if (VirtualDirection == OP_BUY)
         {
   			HaveLongPosition = true;
			   HaveShortPosition = false;
         }
         else if (VirtualDirection == OP_SELL)
         {
			   HaveLongPosition = false;
   			HaveShortPosition = true;
         }
      }
      else
      {
		   HaveLongPosition = false;
		   HaveShortPosition = false;
		}
      return;
   }

   int total = OrdersTotal();
   for (int cnt = 0; cnt < total; cnt++)
   {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if (OrderMagicNumber() != Magic) continue;
      if (OrderSymbol() != Symbol()) continue;

      if (OrderType() == OP_BUY)
      {
			HaveLongPosition = true;
			HaveShortPosition = false;
			return;
		}
      else if (OrderType() == OP_SELL)
      {
			HaveLongPosition = false;
			HaveShortPosition = true;
			return;
		}
	}
   HaveLongPosition = false;
	HaveShortPosition = false;
}

//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
void fBuy()
{
	RefreshRates();
   if (TradeBlock) // Virtual Buy
   {
      VirtualDirection = OP_BUY;
      VirtualOpen = true;
      VirtualOP = Ask;
      SaveFile();
      if (!Mute) Print("Entered Virtual Long at ", VirtualOP, ".");
      return;
   }

	int result = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, Slippage, 0, 0,OrderCommentary, Magic);
	if (result == -1)
	{
		int e = GetLastError();
		Print("OrderSend Error: ", e);
	}
}

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
void fSell()
{
	RefreshRates();
   if (TradeBlock) // Virtual Sell
   {
      VirtualDirection = OP_SELL;
      VirtualOpen = true;
      VirtualOP = Bid;
      SaveFile();
      if (!Mute) Print("Entered Virtual Short at ", VirtualOP, ".");
      return;
   }

	int result = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, Slippage, 0, 0, OrderCommentary, Magic);
	if (result == -1)
	{
		int e = GetLastError();
		Print("OrderSend Error: ", e);
	}
}

//+------------------------------------------------------------------+
//| Calculate position size depending on money management parameters.|
//+------------------------------------------------------------------+
double LotsOptimized()
{
	if (!MM) return (Lots);
	
   double Size, RiskMoney, PositionSize = 0;

   if (AccountCurrency() == "") return(0);

   if (FixedBalance > 0)
   {
      Size = FixedBalance;
   }
   else if (UseEquityInsteadOfBalance)
   {
      Size = AccountEquity();
   }
   else
   {
      Size = AccountBalance();
   }
   
   if (!UseMoneyInsteadOfPercentage) RiskMoney = Size * Risk / 100;
   else RiskMoney = MoneyRisk;

   double UnitCost = MarketInfo(Symbol(), MODE_TICKVALUE);
   double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   
   if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0)) PositionSize = NormalizeDouble(RiskMoney / (StopLoss * UnitCost / TickSize), LotDigits);
   
   if (PositionSize < MarketInfo(Symbol(), MODE_MINLOT)) PositionSize = MarketInfo(Symbol(), MODE_MINLOT);
   else if (PositionSize > MarketInfo(Symbol(), MODE_MAXLOT)) PositionSize = MarketInfo(Symbol(), MODE_MAXLOT);
   
   return(PositionSize);
} 

//+------------------------------------------------------------------+
//| Close previous position                                          |
//+------------------------------------------------------------------+
void ClosePrevious()
{
   if (TradeBlock) // Virtual Exit
   {
      if (VirtualOpen)
      {
         if (VirtualDirection == OP_BUY)
         {
          	// We lost, so the virtual trading can be turned off.
          	if (Bid < VirtualOP) TradeBlock = false;
            if (!Mute) Print("Closed Virtual Long at ", Bid, " with Open at ", VirtualOP);
         }
         else if (VirtualDirection == OP_SELL)
         {
          	// We lost, so the virtual trading can be turned off.
            if (Ask > VirtualOP) TradeBlock = false;
            if (!Mute) Print("Closed Virtual Short at ", Ask, " with Open at ", VirtualOP);
         }
         VirtualDirection = -1;
         VirtualOpen = false;
         VirtualOP = 0;
         SaveFile();
      }
      return;
   }

   int total = OrdersTotal();
   for (int i = 0; i < total; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS) == false) continue;
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic))
      {
         if (OrderType() == OP_BUY)
         {
            RefreshRates();
            OrderClose(OrderTicket(), OrderLots(), Bid, Slippage);
         }
         else if (OrderType() == OP_SELL)
         {
            RefreshRates();
            OrderClose(OrderTicket(), OrderLots(), Ask, Slippage);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Saves Virtual Trading data to a file                             |
//+------------------------------------------------------------------+
void SaveFile()
{
   // Need it to overwrite the data, not to append it each time we save.
   FileSeek(fh, 0, SEEK_SET);
   FileWriteInteger(fh, TradeBlock, CHAR_VALUE);
   FileWriteInteger(fh, VirtualDirection, CHAR_VALUE);
   FileWriteInteger(fh, VirtualOpen, CHAR_VALUE);
   FileWriteDouble(fh, VirtualOP, DOUBLE_VALUE);
   FileWriteInteger(fh, BlockTicket, LONG_VALUE);
}

//+------------------------------------------------------------------+
//| Loads Virtual Trading data from a file                           |
//+------------------------------------------------------------------+
void LoadFile()
{
   fh = FileOpen(FileName, FILE_READ|FILE_BIN);
   if (fh < 0)
   {
      int err = GetLastError();
      if (err == 4103) Print("No saved file to load.");
      else Print(ErrorDescription(GetLastError()));
      return;
   }
   TradeBlock = FileReadInteger(fh, CHAR_VALUE);
   VirtualDirection = FileReadInteger(fh, CHAR_VALUE);
   VirtualOpen = FileReadInteger(fh, CHAR_VALUE);
   VirtualOP = FileReadDouble(fh, DOUBLE_VALUE);
   BlockTicket = FileReadInteger(fh, LONG_VALUE);
   Print("Loaded virtual trading data. TradeBlock = ", TradeBlock, " VirtualDirection = ", VirtualDirection, " VirtualOpen = ", VirtualOpen, " VirtualOP = ", VirtualOP, " BlockTicket = ", BlockTicket);
   FileClose(fh);
}

//+------------------------------------------------------------------+
//| Order History Sorting Function by WHRoeder:                      |
//| http://www.mql4.com/users/WHRoeder                               |
//+------------------------------------------------------------------+
int GetHistoryOrderByCloseTime(int& tickets[], int dsc = 1)
{
   /* http://forum.mql4.com/46182 zzuegg says history ordering "is not reliable
    * (as said in the doc)" [not in doc] dabbler says "the order of entries is
    * mysterious (by actual test)" */

   int nOrders = 0;
   datetime OCTs[];

   for (int iPos = OrdersHistoryTotal() - 1; iPos >= 0; iPos--)
   {
      if ((OrderSelect(iPos, SELECT_BY_POS, MODE_HISTORY))  // Only orders w/
      &&  (OrderMagicNumber() == Magic)             // my magic number
      &&  (OrderSymbol()      == Symbol())             // and my pair.
      &&  (OrderType()        <= OP_SELL) // Avoid cr/bal forum.mql4.com/32363#325360
      )
      {
         int nextTkt = OrderTicket();
         datetime nextOCT = OrderCloseTime();
         nOrders++;
         ArrayResize(tickets, nOrders);
         ArrayResize(OCTs, nOrders);
         // Insertn sort.
         for (int iOrders = nOrders - 1; iOrders > 0; iOrders--)
         {
            datetime prevOCT = OCTs[iOrders-1];
            if ((prevOCT - nextOCT) * dsc >= 0) break;
            
            int prevTkt = tickets[iOrders - 1];
            tickets[iOrders] = prevTkt;
            OCTs[iOrders] = prevOCT;
         }
         tickets[iOrders] = nextTkt;
         OCTs[iOrders] = nextOCT; // Insert.
      }
   }  
   return(nOrders);
}
//+------------------------------------------------------------------+