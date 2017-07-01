//-----------------------------------------------------------------------------------------------------------------------------------------
//MH MARKET INFORMATION FUNCTIONS
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
   LOG("---------------------- Start MarketInfo_Print() ----------------------");
   LOG("Symbol = "+_Symbol);
   LOG("MODE_LOW (Low day price) = "+(string)MarketInfo(_Symbol,MODE_LOW));
   LOG("MODE_HIGH (High day price) = "+(string)MarketInfo(_Symbol,MODE_HIGH));
   LOG("MODE_TIME (The last incoming tick time) = "+(string)MarketInfo(_Symbol,MODE_TIME));
   LOG("MODE_BID (Last incoming bid price) = "+(string)MarketInfo(_Symbol,MODE_BID));
   LOG("MODE_ASK (Last incoming ask price) = "+(string)MarketInfo(_Symbol,MODE_ASK));
   LOG("MODE_POINT (Point size in the quote currency) = "+(string)MarketInfo(_Symbol,MODE_POINT));
   LOG("MODE_DIGITS (Digits after decimal point) = "+(string)MarketInfo(_Symbol,MODE_DIGITS));
   LOG("MODE_SPREAD (Spread value) = "+(string)MarketInfo(_Symbol,MODE_SPREAD)+" points");
   LOG("MODE_STOPLEVEL (Stop level) = "+(string)MarketInfo(_Symbol,MODE_STOPLEVEL)+" points");
   LOG("MODE_LOTSIZE (Lot size in the base currency) = "+(string)MarketInfo(_Symbol,MODE_LOTSIZE)+" "+SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE));
   LOG("MODE_TICKVALUE (Tick value in the deposit currency) = "+(string)MarketInfo(_Symbol,MODE_TICKVALUE)+" "+AccountInfoString(ACCOUNT_CURRENCY));
   LOG("MODE_TICKSIZE (Tick size) = "+(string)MarketInfo(_Symbol,MODE_TICKSIZE)+" points"); 
   LOG("MODE_SWAPLONG (Swap of the buy order) = "+(string)MarketInfo(_Symbol,MODE_SWAPLONG));
   LOG("MODE_SWAPSHORT (Swap of the sell order) = "+(string)MarketInfo(_Symbol,MODE_SWAPSHORT));
   LOG("MODE_STARTING (Market starting date (for futures)) = "+(string)MarketInfo(_Symbol,MODE_STARTING));
   LOG("MODE_EXPIRATION (Market expiration date (for futures)) = "+(string)MarketInfo(_Symbol,MODE_EXPIRATION));
   LOG("MODE_TRADEALLOWED (Trade is allowed for the symbol) = "+(string)MarketInfo(_Symbol,MODE_TRADEALLOWED));
   LOG("MODE_MINLOT (Minimum permitted amount of a lot) = "+(string)MarketInfo(_Symbol,MODE_MINLOT)+" lots");
   LOG("MODE_LOTSTEP (Step for changing lots) = "+(string)MarketInfo(_Symbol,MODE_LOTSTEP));
   LOG("MODE_MAXLOT (Maximum permitted amount of a lot) = "+(string)MarketInfo(_Symbol,MODE_MAXLOT)+" lots");
   LOG("MODE_SWAPTYPE (Swap calculation method) = "+SwapCalcMethod());
   LOG("MODE_PROFITCALCMODE (Profit calculation mode) = "+ProfitCalcMode());
   LOG("MODE_MARGINCALCMODE (Margin calculation mode) = "+(string)MarketInfo(_Symbol,MODE_MARGINCALCMODE));
   LOG("MODE_MARGININIT (Initial margin requirements for 1 lot) = "+(string)MarketInfo(_Symbol,MODE_MARGININIT));
   LOG("MODE_MARGINMAINTENANCE (Margin to maintain open orders calculated for 1 lot) = "+(string)MarketInfo(_Symbol,MODE_MARGINMAINTENANCE));
   LOG("MODE_MARGINHEDGED (Hedged margin calculated for 1 lot) = "+(string)MarketInfo(_Symbol,MODE_MARGINHEDGED));
   LOG("MODE_MARGINREQUIRED (Free margin required to open 1 lot for buying) = "+(string)MarketInfo(_Symbol,MODE_MARGINREQUIRED)+" "+AccountInfoString(ACCOUNT_CURRENCY));
   LOG("MODE_FREEZELEVEL (Order freeze level) = "+(string)MarketInfo(_Symbol,MODE_FREEZELEVEL)+" points"); 
   LOG("---------------------- End MarketInfo_Print() ----------------------");
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