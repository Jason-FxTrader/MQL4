//----------------------------------------------------------------------------------
// MH_Check.mqh
//----------------------------------------------------------------------------- 1 --
// The function checking legality of the program used
// Inputs:
// - global variable 'Parol'
// - local constant "Monecor (London) Ltd."
// Returned values:
// true  - if the conditions of use are met
// false - if the conditions of use are violated
//----------------------------------------------------------------------------- 2 --
extern int Parol=12345; // Password to work on a real account
//----------------------------------------------------------------------------- 3 --
bool Check()                           // User-defined unction
{
   bool rv = false;

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      Print("TERMINAL_TRADE_ALLOWED = FALSE: Automatic Trading is disabled in the terminal settings (either AutoTrading button or in checkbox Options/Expert Advisors/Allow Automated Trading)");
   else if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      Alert("MQL_TRADE_ALLOWED = FALSE: Automated trading is disabled in the program settings for ",__FILE__);

//   Print("IsDemo(): ", IsDemo());
//   Print("AccountCompany(): ", AccountCompany());
//   Print("AccountNumber(): ", AccountNumber());
   
   if (IsDemo()==true)                                   // If it is a demo account, then..
      rv = true;                                         // .. there are no other limitations
   else if (AccountCompany()=="Monecor (London) Ltd.")   // For corporate clients..
      rv = true;                                         // .. no password is required
   else if (Parol==AccountNumber()*2+1000001)            // If the password is true, then..
      rv = true;                                         // .. allow the user to work on a real account
   else
      Inform(14);                                        // Message about unauthorized use
   
//   Print("rv = ", rv);   
   return (rv);
}