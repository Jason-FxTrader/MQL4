//--------------------------------------------------------------------
// Terminal.mqh
// The code should be used for educational purpose only.
//------------------------------------------------------------------------------ 1 --
// Order accounting function
// Global variables:
// Mas_Ord_New[31][9]   // The latest known orders array
// Mas_Ord_Old[31][9]   // The preceding (old) orders array
                        // 1st index = order number 

                        // [][0] not defined
#define OOP  1          // [][1] order open price (abs. price value)
#define OSL  2          // [][2] StopLoss of the order (abs. price value)
#define OTP  3          // [][3] TakeProfit of the order (abs. price value)
#define OTN  4          // [][4] Order Ticket Number        
#define OVL  5          // [][5] Order Volume in Lots (abs. price value)
#define OTY  6          // [][6] Order TYpe 0=B,1=S,2=BL,3=SL,4=BS,5=SS
#define OMN  7          // [][7] Order Magic nnumber
#define OCA  8          // [][8] 0/1 Comment Availability

// Mas_Tip[6]           // Array of the amount of orders of all types
                        // [] order type: 0=B,1=S,2=BL,3=SL,4=BS,5=SS
//------------------------------------------------------------------------------ 2 --
void Terminal()
  {
   int Qnt=0;                          // Orders counter
 
//------------------------------------------------------------------------------ 3 --
   ArrayCopy(Mas_Ord_Old, Mas_Ord_New);// Saves the preceding history
   Qnt=0;                              // Zeroize orders counter
   ArrayInitialize(Mas_Ord_New,0);     // Zeroize the array
   ArrayInitialize(Mas_Tip,    0);     // Zeroize the array
//------------------------------------------------------------------------------ 4 --
   for(int i=0; i<OrdersTotal(); i++) // For market and pending orders
     {
      if((OrderSelect(i,SELECT_BY_POS)==true)      //If there is the next one
      && (OrderSymbol()==Symbol()))                //.. and our currency pair
        {
         //--------------------------------------------------------------------- 5 --
         Qnt++;                                    // Amount of orders
         Mas_Ord_New[Qnt][OOP]=OrderOpenPrice();   // Order open price
         Mas_Ord_New[Qnt][OSL]=OrderStopLoss();    // SL price
         Mas_Ord_New[Qnt][OTP]=OrderTakeProfit();  // TP price 
         Mas_Ord_New[Qnt][OTN]=OrderTicket();      // Order number
         Mas_Ord_New[Qnt][OVL]=OrderLots();        // Amount of lots
         Mas_Tip[OrderType()]++;                   // Amount of orders of the type
         Mas_Ord_New[Qnt][OTY]=OrderType();        // Order type
         Mas_Ord_New[Qnt][OMN]=OrderMagicNumber(); // Magic number 
         if (OrderComment()=="")
            Mas_Ord_New[Qnt][OCA]=0;               // If there is no comment
         else
            Mas_Ord_New[Qnt][OCA]=1;               // If there is a comment
         //--------------------------------------------------------------------- 6 --
        }
     }
   Mas_Ord_New[0][0]=Qnt;                         // Amount of orders
//------------------------------------------------------------------------------ 7 --
   return;
  }
//------------------------------------------------------------------------------ 8 --