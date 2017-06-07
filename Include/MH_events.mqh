//--------------------------------------------------------------------------------
// Events.mqh
// The code should be used for educational purpose only.
//--------------------------------------------------------------------------- 1 --
// Event tracking function.
// Global variables:
// Level_new            The new value of the minimum distance
// Level_old            The preceding value of the minimum distance
// Mas_Ord_New[31][9]   The last known array of orders
// Mas_Ord_Old[31][9]   The old array of orders
//--------------------------------------------------------------------------- 2 --
void Events() // User-defined function
  {
   bool Conc_Nom_Ord;                     // Matching orders in the old and the new arrays
//--------------------------------------------------------------------------- 3 --
   Level_new=(int)MarketInfo(Symbol(),MODE_STOPLEVEL);// Last known
   if(Level_old!=Level_new) // New is not the same as old..
     {                                    // it means the condition have been changed
      Level_old=Level_new;                // New "old value"
      Inform(10,Level_new);               // Message: new distance
     }
//--------------------------------------------------------------------------- 4 --
// Searching for lost, type-changed, partly closed and reopened orders
   for(int old=1;old<=Mas_Ord_Old[0][0];old++)// In the array of old orders
     {                                    // Assuming the..
      Conc_Nom_Ord=false;                 // ..orders don't match
      //--------------------------------------------------------------------- 5 --
      for(int New=1;New<=Mas_Ord_New[0][0];New++)//Cycle for the array ..
        {                                 //..of new orders
         //------------------------------------------------------------------ 6 --
         if(Mas_Ord_Old[old][OTN]==Mas_Ord_New[New][OTN])// Matched number 
           {                              // Order type becomes ..
            if(Mas_Ord_New[New][OTY]!=Mas_Ord_Old[old][OTY])//.. different
               Inform(7,(int)Mas_Ord_New[New][OTN]);// Message: modified:)
            Conc_Nom_Ord=true;            // The order is found, ..
            break;                        // ..so exiting ..
           }                              // .. the internal cycle
         //------------------------------------------------------------------ 7 --
         // Order number does not match
         if(Mas_Ord_Old[old][OMN]>0 && // MagicNumber matches
            Mas_Ord_Old[old][OMN]==Mas_Ord_New[New][OMN])//.. with the old one
           {               //it means it is reopened or partly closed
            // If volumes match,.. 
            if(Mas_Ord_Old[old][OVL]==Mas_Ord_New[New][OVL])
               Inform(8,(int)Mas_Ord_Old[old][OTN]);// ..it is reopening
            else                             // Otherwise, it was.. 
            Inform(9,(int)Mas_Ord_Old[old][OTN]);// ..partly closing
            Conc_Nom_Ord=true;               // The order is found, ..
            break;                           // ..so exiting ..
           }                                 // .. the internal cycle
        }
      //--------------------------------------------------------------------- 8 --
      if(Conc_Nom_Ord==false) // If we are here,..
        {                                    // ..it means no order found:(
         if(Mas_Ord_Old[old][OTY]==0)
            Inform(1,(int)Mas_Ord_Old[old][OTN]);  // Order Buy closed
         if(Mas_Ord_Old[old][OTY]==1)
            Inform(2,(int)Mas_Ord_Old[old][OTN]);  // Order Sell closed
         if(Mas_Ord_Old[old][OTY]>1)
            Inform(3,(int)Mas_Ord_Old[old][OTN]);  // Pending order deleted
        }
     }
//--------------------------------------------------------------------------- 9 --
// Search for new orders
   for(int New=1; New<=Mas_Ord_New[0][0]; New++)// In the array of new orders
     {
      if(Mas_Ord_New[New][OCA]>0) //This one is not new, but reopened
         continue;                          //..or partly closed
      Conc_Nom_Ord=false;                   // As long as no matches found
      for(int old=1; old<=Mas_Ord_Old[0][0]; old++)// Searching for this order 
        {                                   // ..in the array of old orders
         if(Mas_Ord_New[New][OTN]==Mas_Ord_Old[old][OTN])//Matched number..
           {                                          //.. of the order
            Conc_Nom_Ord=true;              // The order is found, ..
            break;                          // ..so exiting ..
           }                                // .. the internal cycle
        }
      if(Conc_Nom_Ord==false) // If no matches found,..
        {                                   // ..the order is new :)
         if(Mas_Ord_New[New][OTY]==0)
            Inform(4,(int)Mas_Ord_New[New][OTN]); // Order Buy opened
         if(Mas_Ord_New[New][OTY]==1)
            Inform(5,(int)Mas_Ord_New[New][OTN]); // Order Sell opened
         if(Mas_Ord_New[New][OTY]>1)
            Inform(6,(int)Mas_Ord_New[New][OTN]); // Pending order placed
        }
     }
//-------------------------------------------------------------------------- 10 --
   return;
  }
//-------------------------------------------------------------------------- 11 --
