//--------------------------------------------------------------------
// MH Errors.mqh

//--------------------------------------------------------------- 1 --
// Error processing function.
// Returned values:
// true  - if the error is overcomable (i.e. work can be continued)
// false - if the error is critical (i.e. trading is impossible)
//--------------------------------------------------------------- 2 --
bool Errors(int Error) // Custom function
  {
   int recoverable = FALSE;
   
   if(Error==0)
      return(false);                      // No error
   Inform(15,Error);                      // Message
//--------------------------------------------------------------- 3 --
   switch(Error)
     {   // Overcomable errors:
      case 0:           // ERR_NO_ERROR  Trade Operation Succeeded (shouldn't actually get here as the Errors function should not be called unless there is an error
      
      case 129:         // Wrong price
      case 135:         // Price changed
         RefreshRates();                  // Renew data
         return(true);                    // Error is overcomable
      case 136:         // No quotes. Waiting for the tick to come
         while(RefreshRates()==false)     // Before new tick
         Sleep(1);                     // Delay in the cycle
         return(true);                    // Error is overcomable
      case 146:         // The trade subsystem is busy
         Sleep(500);                      // Simple solution
         RefreshRates();                  // Renew data
         return(true);                    // Error is overcomable
                                          // Critical errors:
      case 2 :          // Common error
      case 5 :          // Old version of the client terminal
      case 64:          // Account blocked
      case 133:         // Trading is prohibited
         default:          // Other variants
         return(false);                   // Critical error
     }
//--------------------------------------------------------------- 4 --
  }
//--------------------------------------------------------------------
//Taken from: https://www.mql5.com/en/forum/150158
//https://docs.mql4.com/constants/errorswarnings/enum_trade_return_codes

//Please see the list below for the most common MT4 error code listings returned from trade server. which includes a complete listing of MT4 error codes and MQL4 Run Time Error Codes
//All retries up to a limit, then if the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.

Retry Immediately
ERR_PRICE_CHANGED	               135	MH OK - The price has changed. The data can be refreshed without any delay using the Refresh Rates function and make a retry.
ERR_TRADE_EXPIRATION_DENIED	   147	The use of pending order expiration date has been denied by the broker. The operation can only be repeated if the expiration parameter has been zeroed.


Retry after 5 Seconds
ERR_NO_CONNECTION	               6	   No connection to the trade server. It is necessary to make sure that connection has not been broken and repeat the attempt after a certain period of time (over 5 seconds).
ERR_OFF_QUOTES	                  136	No quotes. The broker has not supplied with prices or refused, for any reason (for example, no prices at the session start, unconfirmed prices, fast market). After 5-second (or more) delay, it is necessary to refresh data using the Refresh Rates function and make a retry.
ERR_INVALID_STOPS	               130	MH CHECKED (CAN RETRY AS CODE SHOULD PREVENT STOPS BEING TOO CLOSE AND THE ERROR SHOULD BE BECAUSE OF PRICE OBSOLESCENCE: Stops are too close, or prices are ill-calculated or unnormalized (or in the open price of a pending order). The attempt can be repeated only if the error occurred due to the price obsolescence. After 5-second (or more) delay, it is necessary to refresh data using the Refresh Rates function and make a retry. If the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.
ERR_REQUOTE	                     138	MH CHECKED: The requested price has become out of date or bid and ask prices have been mixed up. The data can be refreshed without any delay using the Refresh Rates function and make a retry. If the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.

SHOULD NEVER GET THESE AS CODING ERRORS???
ERR_INVALID_PRICE	               129	MH CHECKED: FIX IN CODE: Invalid bid or ask price, perhaps, unnormalized price. After 5-second (or more) delay, it is necessary to refresh data using the Refresh Rates function and make a retry. If the error does not disappear, all attempts to trade must be stopped, the program logic must be changed.
ERR_NOT_ENOUGH_MONEY	            134	Not enough money to make an operation. The trade with the same parameters must not be repeated. After 5-second (or more) delay, the attempt can be repeated with a smaller volume, but it is necessary to make sure that there is enough money to complete the operation.

Retry after 15 seconds
ERR_TRADE_MODIFY_DENIED	         145	Modifying has been denied since the order is too close to market and locked for possible soon execution. The data can be refreshed after more than 15 seconds using the Refresh Rates function, and a retry can be made.

Retry after 1 minute
ERR_TRADE_TIMEOUT	               128	Timeout for the trade has been reached. Before retry (at least, in 1-minute time), it is necessary to make sure that trading operation has not really succeeded (a new position has not been opened, or the existing order has not been modified or deleted, or the existing position has not been closed)
                                 142	The order has been queued. It is not an error but an interaction code between the client terminal and the trade server. This code can be got rarely, when the disconnection and the reconnection happen during the execution of a trade operation. This code should be processed in the same way as error 128.
                                 143	The order was accepted by the dealer for execution. It is an interaction code between the client terminal and the trade server. It can appear for the same reason as code 142. This code should be processed in the same way as error 128.

Retry after significant delay (several minutes)
ERR_SERVER_BUSY	               4	Trade server is busy. The attempt can be repeated after a rather long period of time (over several minutes).
ERR_MARKET_CLOSED	               132	Market is closed. The attempt can be repeated after a rather long period of time (over several minutes).

Operation Unrecoverable
ERR_LONG_POSITIONS_ONLY_ALLOWED	140	Only buying operation is allowed. The SELL operation must not be repeated.
                                 144	The order was discarded by the client during manual confirmation. It is an interaction code between the client terminal and the trade server.
ERR_TRADE_TOO_MANY_ORDERS	      148	The amount of open and pending orders has reached the limit set by the broker. New open positions and pending orders can be placed only after the existing positions or orders have been closed or deleted.


Program Unrecoverable - STOP IMMEDIATELY
ERR_NO_RESULT	                  1	Order Modify attempts to replace the values already set with the same values. One or more values must be changed, then modification attempt can be repeated. MH: shouldn't happen if my code was correct!
ERR_COMMON_ERROR	               2	Common error. All attempts to trade must be stopped until reasons are clarified. Restart of operation system and client terminal will possibly be needed.
ERR_INVALID_TRADE_PARAMETERS	   3	Invalid parameters were passed to the trading function, for example, wrong symbol, unknown trade operation, negative slippage, non-existing ticket number, etc. The program logic must be changed.
ERR_OLD_VERSION	               5	Old version of the client terminal. The latest version of the client terminal must be installed.
ERR_TOO_FREQUENT_REQUESTS	      8	Requests are too frequent. The frequency of requesting must be reduced, the program logic must be changed.
ERR_ACCOUNT_DISABLED	            64	The account was disabled. All attempts to trade must be stopped.
ERR_INVALID_ACCOUNT	            65	The account number is invalid. All attempts to trade must be stopped.
ERR_INVALID_TRADE_VOLUME	      131	Invalid trade volume, error in the volume granularity. All attempts to trade must be stopped, and the program logic must be changed.
ERR_TRADE_DISABLED	            133	Trade is disabled. All attempts to trade must be stopped.
ERR_ORDER_LOCKED	               139	The order has been locked and under processing. All attempts to make trading operations must be stopped, and the program logic must be changed.
ERR_TOO_MANY_REQUESTS	         141	Too many requests. The frequency of requesting must be reduced, the program logic must be changed.
ERR_TRADE_HEDGE_PROHIBITED	      149	An attempt to open a position opposite to the existing one when hedging is disabled. First the existing opposite position should be closed, all attempts of such trade operations must be stopped, or the program logic must be changed.
ERR_TRADE_PROHIBITED_BY_FIFO	   150	An attempt to close a symbol position contravening the FIFO rule. First earlier existing position(s) should be closed, all attempts of such trade operations must be stopped, or the program logic must be changed.


What are these and how to handle?
ERR_MALFUNCTIONAL_TRADE          9     Malfunctional trade operation
ERR_BROKER_BUSY                  137   Broker is busy
ERR_TRADE_CONTEXT_BUSY	         146	The trade thread is busy. Retry again with Trade Context Busy Support

7
ERR_NOT_ENOUGH_RIGHTS   Not enough rights

Just return with SUCCESS
ERR_NO_ERROR                     0  MH CHECKED: Trade operation succeeded. MH - should never get this 'error' so it must be a system fault, therefore all attempts to trade must be stopped.

**** TODO: NEED TO CLOSE ALL OPEN ORDERS IN DEINIT() *****