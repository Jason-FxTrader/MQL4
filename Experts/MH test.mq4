#property strict

extern color clrObjectColour = Red;
extern int   intObjectStyle  = STYLE_DOT; 
extern int   intBarShift     = 0;

string strObjectName = "DailyOpen";

void OnTick()
{
   static datetime dtDayBarTime = EMPTY;
   
   if( iBars( _Symbol, PERIOD_M1 ) > intBarShift )
   {
      datetime dtStartTime = iTime( _Symbol, PERIOD_M1, intBarShift );
      
      if( dtDayBarTime != dtStartTime )
      {
         datetime dtEndTime    = dtStartTime + 86400;
         double   dblOpenPrice = iOpen( _Symbol, PERIOD_M1, intBarShift );
   
         if( dtDayBarTime == EMPTY )
         {
            ObjectCreate( strObjectName, OBJ_TREND, 0, dtStartTime, dblOpenPrice, dtEndTime, dblOpenPrice );
            
            ObjectSet( strObjectName, OBJPROP_HIDDEN, true           ); // Prevents accidental deletion of object by user
            ObjectSet( strObjectName, OBJPROP_RAY,   false           );  
            ObjectSet( strObjectName, OBJPROP_COLOR, clrObjectColour );      
            ObjectSet( strObjectName, OBJPROP_STYLE, intObjectStyle  );
         }
         else
         {
            ObjectMove( strObjectName, 0, dtStartTime, dblOpenPrice );
            ObjectMove( strObjectName, 1, dtEndTime,   dblOpenPrice );
         }
         
         dtDayBarTime = dtStartTime;
      }
   }
}

void OnDeinit( const int reason )
{
   ObjectDelete( strObjectName );
}