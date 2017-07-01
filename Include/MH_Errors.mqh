//--------------------------------------------------------------------
// MH Errors.mqh

//--------------------------------------------------------------- 1 --
// Error processing function.
//--------------------------------------------------------------- 2 --
void Error_Manage(int retrycnt)
{
//Taken from: https://www.mql5.com/en/forum/150158
//https://docs.mql4.com/constants/errorswarnings/enum_trade_return_codes

//Please see the list below for the most common MT4 error code listings returned from trade server. which includes a complete listing of MT4 error codes and MQL4 Run Time Error Codes
//All retries up to a limit, then if the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.
LOG(Error_Get());
Print(Error_Get());
#define MAXRETRIES 10
   if (retrycnt >= MAXRETRIES)
      Terminal_Close();
   else
      switch (GetLastError())
      {      
   //Retry Immediately
         case ERR_NO_ERROR:                     //0   Trade operation succeeded. MH: ILLOGICAL SO MUST BE AN OPERATION FAILURE AND THUS RETRY IMMEDIATELY???
         case ERR_PRICE_CHANGED:                //135	The price has changed. The data can be refreshed without any delay using the Refresh Rates function and make a retry.
         case ERR_REQUOTE:                      //138	The requested price has become out of date or bid and ask prices have been mixed up. The data can be refreshed without any delay using the Refresh Rates function and make a retry. If the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.
         case ERR_TRADE_CONTEXT_BUSY:           //146	The trade thread is busy (MH: by another EA.  MT4 is single threaded). Retry again with Trade Context Busy Support.  Code needs to change to include semaphore between EAs.  See: https://www.mql5.com/en/articles/1412
            RefreshRates();
            break;
   //-------------------------------------------
   //Retry after 5 Seconds
         case ERR_NO_CONNECTION:                //6   No connection to the trade server. It is necessary to make sure that connection has not been broken and repeat the attempt after a certain period of time (over 5 seconds).
            if (!IsConnected())                 //if connection to the server is NOT successfully established
               Sleep(5000);                     //Sleep for 5 seconds
            RefreshRates();
            break;
   //-------------------------------------------
         case ERR_OFF_QUOTES:                   //136	No quotes. The broker has not supplied with prices or refused, for any reason (for example, no prices at the session start, unconfirmed prices, fast market). After 5-second (or more) delay, it is necessary to refresh data using the Refresh Rates function and make a retry.
            while (RefreshRates() == FALSE)
               Sleep(5000);
            break;
   //-------------------------------------------
         case ERR_INVALID_STOPS:                //130	Stops are too close, or prices are ill-calculated or unnormalized (or in the open price of a pending order). The attempt can be repeated only if the error occurred due to the price obsolescence. After 5-second (or more) delay, it is necessary to refresh data using the Refresh Rates function and make a retry. If the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.
         case ERR_INVALID_PRICE:                //129	Invalid bid or ask price, perhaps, unnormalized price. After 5-second (or more) delay, it is necessary to refresh data using the Refresh Rates function and make a retry. If the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.
            Sleep(5000);
            RefreshRates();
            break;
   //-------------------------------------------
   //Retry after 15 seconds
         case ERR_TRADE_MODIFY_DENIED:          //145	Modifying has been denied since the order is too close to market and locked for possible soon execution. The data can be refreshed after more than 15 seconds using the Refresh Rates function, and a retry can be made.
            Sleep(15000);
            RefreshRates();
            break;
   //-------------------------------------------
   //Retry after 1 minute
         case ERR_TRADE_TIMEOUT:                //128	Timeout for the trade has been reached. Before retry (at least, in 1-minute time), it is necessary to make sure that trading operation has not really succeeded (a new position has not been opened, or the existing order has not been modified or deleted, or the existing position has not been closed)
         case 142:                              //142	The order has been queued. It is not an error but an interaction code between the client terminal and the trade server. This code can be got rarely, when the disconnection and the reconnection happen during the execution of a trade operation. This code should be processed in the same way as error 128.
         case 143:                              //143	The order was accepted by the dealer for execution. It is an interaction code between the client terminal and the trade server. It can appear for the same reason as code 142. This code should be processed in the same way as error 128.
            Sleep(60000);
            RefreshRates();
            break;
   //-------------------------------------------
   //Retry after significant delay (several minutes)
         case ERR_SERVER_BUSY:                  //4	Trade server is busy. The attempt can be repeated after a rather long period of time (over several minutes).
         case ERR_BROKER_BUSY:                  //137 Broker is busy
         case ERR_MARKET_CLOSED:                //132	Market is closed. The attempt can be repeated after a rather long period of time (over several minutes).
            Sleep(300000); //5 minutes enough?
            RefreshRates();
            break;
   //-------------------------------------------
   //Operation Unrecoverable - STOP IMMEDIATELY
         case ERR_LONG_POSITIONS_ONLY_ALLOWED:  //140	Only buying operation is allowed. The SELL operation must not be repeated.
                                                //144	The order was discarded by the client during manual confirmation. It is an interaction code between the client terminal and the trade server.
         case ERR_TRADE_TOO_MANY_ORDERS:        //148	The amount of open and pending orders has reached the limit set by the broker. New open positions and pending orders can be placed only after the existing positions or orders have been closed or deleted.
   //-------------------------------------------
   //Program Unrecoverable - STOP IMMEDIATELY
         case ERR_NO_RESULT:                    //1	Order Modify attempts to replace the values already set with the same values. One or more values must be changed, then modification attempt can be repeated. MH: shouldn't happen if my code was correct!
         case ERR_COMMON_ERROR:                 //2	Common error. All attempts to trade must be stopped until reasons are clarified. Restart of operation system and client terminal will possibly be needed.
         case ERR_INVALID_TRADE_PARAMETERS:     //3	Invalid parameters were passed to the trading function, for example, wrong symbol, unknown trade operation, negative slippage, non-existing ticket number, etc. The program logic must be changed.
         case ERR_OLD_VERSION:                  //5	Old version of the client terminal. The latest version of the client terminal must be installed.
         case ERR_NOT_ENOUGH_RIGHTS:            //7   Not enough rights
         case ERR_TOO_FREQUENT_REQUESTS:        //8	Requests are too frequent. The frequency of requesting must be reduced, the program logic must be changed.
         case ERR_MALFUNCTIONAL_TRADE:          //9   Malfunctional trade operation
         case ERR_ACCOUNT_DISABLED:             //64	The account was disabled. All attempts to trade must be stopped.
         case ERR_INVALID_ACCOUNT:              //65	The account number is invalid. All attempts to trade must be stopped.
         case ERR_INVALID_TRADE_VOLUME:         //131	Invalid trade volume, error in the volume granularity. All attempts to trade must be stopped, and the program logic must be changed.
         case ERR_TRADE_DISABLED:               //133	Trade is disabled. All attempts to trade must be stopped.
         case ERR_NOT_ENOUGH_MONEY:             //134	Not enough money to make an operation. The trade with the same parameters must not be repeated. After 5-second (or more) delay, the attempt can be repeated with a smaller volume, but it is necessary to make sure that there is enough money to complete the operation. MH: Shouldn't happen if my code was correct using AccountFreeMarginCheck():  http://EzineArticles.com/3494113
         case ERR_ORDER_LOCKED:                 //139	The order has been locked and under processing. All attempts to make trading operations must be stopped, and the program logic must be changed.
         case ERR_TOO_MANY_REQUESTS:            //141	Too many requests. The frequency of requesting must be reduced, the program logic must be changed.
         case ERR_TRADE_HEDGE_PROHIBITED:       //149	An attempt to open a position opposite to the existing one when hedging is disabled. First the existing opposite position should be closed, all attempts of such trade operations must be stopped, or the program logic must be changed.
         case ERR_TRADE_PROHIBITED_BY_FIFO:     //150	An attempt to close a symbol position contravening the FIFO rule. First earlier existing position(s) should be closed, all attempts of such trade operations must be stopped, or the program logic must be changed.
         case ERR_TRADE_EXPIRATION_DENIED:      //147	MH CHECKED: SHOULD NOT GET THIS AS I SET EXPIRATION TO 0: The use of pending order expiration date has been denied by the broker. The operation can only be repeated if the expiration parameter has been zeroed. (Pending order expiration time can be disabled in some trade servers. In this case, when a non-zero value is specified in the expiration parameter, the error 147 (ERR_TRADE_EXPIRATION_DENIED) will be generated.)
         default: //unrecoverable error
            Terminal_Close();
            break;
      }
}

void Terminal_Close()
{
//TODO:   DELETE/CLOSE ALL ORDERS
TerminalClose(GetLastError());
   //while(TRUE)
   //{
   //   Print("UNRECOVERABLE ERROR, WAITING FOR USER INTERVENTION");
   //   if (IsTesting())
   //   {
   //      for (int i=0; i< 1000000000; i++) //dummy sleep as StrategyTester doesn't execute Sleep
   //         ;
   //   }
   //   else
   //      Sleep(1000);
   //}
}

//-----------------------------------------------------------------------------------------------------------------------------------------
// GET ERROR DETAILS
//-----------------------------------------------------------------------------------------------------------------------------------------
string Error_Get()
  {
   string s;
   int error_code = GetLastError();
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   s="no error";                                                  break;
      case 2:   s="common error";                                              break;
      case 3:   s="invalid trade parameters";                                  break;
      case 4:   s="trade server is busy";                                      break;
      case 5:   s="old version of the client terminal";                        break;
      case 6:   s="no connection with trade server";                           break;
      case 7:   s="not enough rights";                                         break;
      case 8:   s="too frequent requests";                                     break;
      case 9:   s="malfunctional trade operation (never returned error)";      break;
      case 64:  s="account disabled";                                          break;
      case 65:  s="invalid account";                                           break;
      case 128: s="trade timeout";                                             break;
      case 129: s="invalid price";                                             break;
      case 130: s="invalid stops";                                             break;
      case 131: s="invalid trade volume";                                      break;
      case 132: s="market is closed";                                          break;
      case 133: s="trade is disabled";                                         break;
      case 134: s="not enough money";                                          break;
      case 135: s="price changed";                                             break;
      case 136: s="off quotes";                                                break;
      case 137: s="broker is busy (never returned error)";                     break;
      case 138: s="requote";                                                   break;
      case 139: s="order is locked";                                           break;
      case 140: s="long positions only allowed";                               break;
      case 141: s="too many requests";                                         break;
      case 145: s="modification denied because order too close to market";     break;
      case 146: s="trade context is busy";                                     break;
      case 147: s="expirations are denied by broker";                          break;
      case 148: s="amount of open and pending orders has reached the limit";   break;
      case 149: s="hedging is prohibited";                                     break;
      case 150: s="prohibited by FIFO rules";                                  break;
      //---- mql4 errors
      case 4000: s="no error (never generated code)";                          break;
      case 4001: s="wrong function pointer";                                   break;
      case 4002: s="array index is out of range";                              break;
      case 4003: s="no memory for function call stack";                        break;
      case 4004: s="recursive stack overflow";                                 break;
      case 4005: s="not enough stack for parameter";                           break;
      case 4006: s="no memory for parameter string";                           break;
      case 4007: s="no memory for temp string";                                break;
      case 4008: s="not initialized string";                                   break;
      case 4009: s="not initialized string in array";                          break;
      case 4010: s="no memory for array\' string";                             break;
      case 4011: s="too long string";                                          break;
      case 4012: s="remainder from zero divide";                               break;
      case 4013: s="zero divide";                                              break;
      case 4014: s="unknown command";                                          break;
      case 4015: s="wrong jump (never generated error)";                       break;
      case 4016: s="not initialized array";                                    break;
      case 4017: s="dll calls are not allowed";                                break;
      case 4018: s="cannot load library";                                      break;
      case 4019: s="cannot call function";                                     break;
      case 4020: s="expert function calls are not allowed";                    break;
      case 4021: s="not enough memory for temp string returned from function"; break;
      case 4022: s="system is busy (never generated error)";                   break;
      case 4050: s="invalid function parameters count";                        break;
      case 4051: s="invalid function parameter value";                         break;
      case 4052: s="string function internal error";                           break;
      case 4053: s="some array error";                                         break;
      case 4054: s="incorrect series array using";                             break;
      case 4055: s="custom indicator error";                                   break;
      case 4056: s="arrays are incompatible";                                  break;
      case 4057: s="global variables processing error";                        break;
      case 4058: s="global variable not found";                                break;
      case 4059: s="function is not allowed in testing mode";                  break;
      case 4060: s="function is not confirmed";                                break;
      case 4061: s="send mail error";                                          break;
      case 4062: s="string parameter expected";                                break;
      case 4063: s="integer parameter expected";                               break;
      case 4064: s="double parameter expected";                                break;
      case 4065: s="array as parameter expected";                              break;
      case 4066: s="requested history data in update state";                   break;
      case 4099: s="end of file";                                              break;
      case 4100: s="some file error";                                          break;
      case 4101: s="wrong file name";                                          break;
      case 4102: s="too many opened files";                                    break;
      case 4103: s="cannot open file";                                         break;
      case 4104: s="incompatible access to a file";                            break;
      case 4105: s="no order selected";                                        break;
      case 4106: s="unknown symbol";                                           break;
      case 4107: s="invalid price parameter for trade function";               break;
      case 4108: s="invalid ticket";                                           break;
      case 4109: s="trade is not allowed in the expert properties";            break;
      case 4110: s="longs are not allowed in the expert properties";           break;
      case 4111: s="shorts are not allowed in the expert properties";          break;
      case 4200: s="object is already exist";                                  break;
      case 4201: s="unknown object property";                                  break;
      case 4202: s="object is not exist";                                      break;
      case 4203: s="unknown object type";                                      break;
      case 4204: s="no object name";                                           break;
      case 4205: s="object coordinates error";                                 break;
      case 4206: s="no specified subwindow";                                   break;
      default:   s="unknown error";
     }
   return StringFormat("Error %d: \"%s\"", error_code, s);
}