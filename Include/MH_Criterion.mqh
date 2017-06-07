//-------------------------------------------------------------------------
// Criterion.mqh
// The code should be used for educational purpose only.
//-------------------------------------------------------------------- 1 --
// Function calculating trading criteria.
// Returned values:
// 10 - opening Buy  
// 20 - opening Sell 
// 11 - closing Buy
// 21 - closing Sell
// 0  - no important criteria available
// -1 - another symbol is used
//-------------------------------------------------------------------- 2 --
// External variables:
extern int St_min=30;                  // Minimum stochastic level
extern int St_max=70;                  // Maximum stochastic level
extern double Open_Level =5;           // MACD level for opening (+/-)
extern double Close_Level=4;           // MACD level for closing (+/-)
//-------------------------------------------------------------------- 3 --
int Criterion() // User-defined function
  {
   int r=0;

   string Sym="UK100";
   if(Sym!=Symbol()) // If it is a wrong symbol
     {
      Inform(16);                      // Messaging..
      return(-1);                      // .. and exiting
     }
//-------------------------------------------------------------------- 4 --
// Parameters of technical indicators:

   Stoch_Update();                     //Update the MTF Stoch values

   bool K1XO = K1_1<=D1_1 && K1>D1; //K1 Xover
   bool K1XU = K1_1>=D1_1 && K1<D1; //K1 Xunder

//-------------------------------------------------------------------- 5 --
// Calculation of trading criteria
   if(K1XO && K1<OS)
      r=10;                      // Opening Buy    
   else if(K1XU && K1>OB)
      r=20;                      // Opening Sell 
//   if(K1XU && K1>OB)
//      r=11;                      // Closing Buy    
//   if(K1XO && K1<OS)
//      r=21;                      // Closing Sell

   if(r>0)
      Log(__LINE__,__FUNCTION__,": "+StringFormat("[K1_1: %.2f, D1_1: %.2f, K1: %.2f, D1: %.2f] [K2_1: %.2f, D2_1: %.2f, K2: %.2f, D2: %.2f] [K3_1: %.2f, D3_1: %.2f, K3: %.2f, D3: %.2f]",
          K1_1,D1_1,K1,D1,K2_1,D2_1,K2,D2,K3_1,D3_1,K3,D3));

   return (r);
  }
//-------------------------------------------------------------------- 7 --
