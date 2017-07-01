//--- connect the library of control elements 
#include <ChartObjects\ChartObjectsTxtControls.mqh> 
//--- predefined constants 
#define X_PROPERTY_NAME_1    10  // ? coordinate of the property name in the first column 
#define X_PROPERTY_VALUE_1   225 // ? coordinate of the property value in the first column 
#define X_PROPERTY_NAME_2    345 // ? coordinate of the property name in the second and third columns 
#define X_PROPERTY_VALUE_2   550 // ? coordinate of the property value in the second and third columns 
#define X_BUTTON_1           285 // ? coordinate of the button in the first column 
#define X_BUTTON_2           700 // ? coordinate of the button in the second column 
#define Y_PROPERTY_1         30  // y coordinate of the beginning of the first and second column 
#define Y_PROPERTY_2         286 // y coordinate of the beginning of the third column 
#define Y_DISTANCE           16  // y axial distance between the lines 
#define LAST_PROPERTY_NUMBER 111 // number of the last graphical property 
//--- input parameters 
input color InpFirstColor=clrDodgerBlue; // Color of odd lines 
input color InpSecondColor=clrGoldenrod; // Color of even lines 
//--- variables and arrays 
CChartObjectLabel  ExtLabelsName[];  // labels for displaying property names 
CChartObjectLabel  ExtLabelsValue[]; // labels for displaying property values 
CChartObjectButton ExtButtons[];     // buttons 
int                ExtNumbers[];     // property indices 
string             ExtNames[];       // property names 
uchar              ExtDataTypes[];   // property data types (integer, double, string) 
uint               ExtGroupTypes[];  // array that stores the data on belonging of properties to one of the groups 
uchar              ExtDrawTypes[];   // array that stores the data on the type of property display 
double             ExtMaxValue[];    // maximum property values that are possible when working with the panel 
double             ExtMinValue[];    // minimum property values that are possible when working with the panel 
double             ExtStep[];        // steps for changing properties 
int                ExtCount;         // total number of all properties 
color              ExtColors[2];     // array of colors for displaying lines 
string             ExtComments[2];   // array of comments (for CHART_COMMENT property) 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- display a comment on the chart 
   Comment("SomeComment"); 
//--- store colors in the array to be able to switch between them later 
   ExtColors[0]=InpFirstColor; 
   ExtColors[1]=InpSecondColor; 
//--- store comments in the array to be able to switch between them later 
   ExtComments[0]="FirstComment"; 
   ExtComments[1]="SecondComment"; 
//--- prepare and display the control panel for managing chart properties 
   if(!PrepareControls()) 
      return(INIT_FAILED); 
//--- successful execution 
   return(INIT_SUCCEEDED); 
  } 
//+------------------------------------------------------------------+ 
//| Deinitialization function of the expert                          | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
//--- remove the comment on the chart 
   Comment(""); 
  } 
//+------------------------------------------------------------------+ 
//| Handler of a chart event                                         | 
//+------------------------------------------------------------------+ 
void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam) 
  { 
//--- check the event of clicking the chart object 
   if(id==CHARTEVENT_OBJECT_CLICK) 
     { 
      //--- divide the object name by separator 
      string obj_name[]; 
      StringSplit(sparam,'_',obj_name); 
      //--- check if the object is a button 
      if(obj_name[0]=="Button") 
        { 
         //--- receive button index 
         int index=(int)StringToInteger(obj_name[1]); 
         //--- unpress the button 
         ExtButtons[index].State(false); 
         //--- set the new value of the property depending on its type 
         if(ExtDataTypes[index]=='I') 
            ChangeIntegerProperty(index); 
         if(ExtDataTypes[index]=='D') 
            ChangeDoubleProperty(index); 
         if(ExtDataTypes[index]=='S') 
            ChangeStringProperty(index); 
        } 
     } 
//--- re-draw property values 
   RedrawProperties(); 
   ChartRedraw(); 
  } 
//+------------------------------------------------------------------+ 
//| Change the integer property of the chart                         | 
//+------------------------------------------------------------------+ 
void ChangeIntegerProperty(const int index) 
  { 
//--- receive the current property value 
   long value=ChartGetInteger(0,(ENUM_CHART_PROPERTY_INTEGER)ExtNumbers[index]); 
//--- define the following property value 
   switch(ExtDrawTypes[index]) 
     { 
      case 'C': 
         value=GetNextColor((color)value); 
         break; 
      default: 
         value=(long)GetNextValue((double)value,index); 
         break; 
     } 
//--- set the new property value 
   ChartSetInteger(0,(ENUM_CHART_PROPERTY_INTEGER)ExtNumbers[index],0,value); 
  } 
//+------------------------------------------------------------------+ 
//| Change double property of the chart                              | 
//+------------------------------------------------------------------+ 
void ChangeDoubleProperty(const int index) 
  { 
//--- receive the current property value 
   double value=ChartGetDouble(0,(ENUM_CHART_PROPERTY_DOUBLE)ExtNumbers[index]); 
//--- define the following property value 
   value=GetNextValue(value,index); 
//--- set the new property value 
   ChartSetDouble(0,(ENUM_CHART_PROPERTY_DOUBLE)ExtNumbers[index],value); 
  } 
//+------------------------------------------------------------------+ 
//| Change string property of the chart                              | 
//+------------------------------------------------------------------+ 
void ChangeStringProperty(const int index) 
  { 
//--- static variable for switching inside ExtComments array 
   static uint comment_index=1; 
//--- change index for receiving another comment 
   comment_index=1-comment_index; 
//--- set the new property value 
   ChartSetString(0,(ENUM_CHART_PROPERTY_STRING)ExtNumbers[index],ExtComments[comment_index]); 
  } 
//+------------------------------------------------------------------+ 
//| Define the next property value                                   | 
//+------------------------------------------------------------------+ 
double GetNextValue(const double value,const int index) 
  { 
   if(value+ExtStep[index]<=ExtMaxValue[index]) 
      return(value+ExtStep[index]); 
   else 
      return(ExtMinValue[index]); 
  } 
//+------------------------------------------------------------------+ 
//| Receive the next color for color type property                   | 
//+------------------------------------------------------------------+ 
color GetNextColor(const color clr) 
  { 
//--- return the following color value 
   switch(clr) 
     { 
      case clrWhite: return(clrRed); 
      case clrRed:   return(clrGreen); 
      case clrGreen: return(clrBlue); 
      case clrBlue:  return(clrBlack); 
      default:       return(clrWhite); 
     } 
  } 
//+------------------------------------------------------------------+ 
//| Re-draw property values                                          | 
//+------------------------------------------------------------------+ 
void RedrawProperties(void) 
  { 
//--- property value text 
   string text; 
   long   value; 
//--- loop of the number of properties 
   for(int i=0;i<ExtCount;i++) 
     { 
      text=""; 
      switch(ExtDataTypes[i]) 
        { 
         case 'I': 
            //--- receive the current property value 
            if(!ChartGetInteger(0,(ENUM_CHART_PROPERTY_INTEGER)ExtNumbers[i],0,value)) 
            break; 
            //--- integer property text 
            switch(ExtDrawTypes[i]) 
              { 
               //--- color property 
               case 'C': 
                  text=(string)((color)value); 
                  break; 
                  //--- boolean property 
               case 'B': 
                  text=(string)((bool)value); 
                  break; 
                  //--- ENUM_CHART_MODE enumeration property 
               case 'M': 
                  text=EnumToString((ENUM_CHART_MODE)value); 
                  break; 
                  //--- ENUM_CHART_VOLUME_MODE enumeration property 
               case 'V': 
                  text=EnumToString((ENUM_CHART_VOLUME_MODE)value); 
                  break; 
                  //--- int type number 
               default: 
                  text=IntegerToString(value); 
                  break; 
              } 
            break; 
         case 'D': 
            //--- double property text 
            text=DoubleToString(ChartGetDouble(0,(ENUM_CHART_PROPERTY_DOUBLE)ExtNumbers[i]),4); 
            break; 
         case 'S': 
            //--- string property text 
            text=ChartGetString(0,(ENUM_CHART_PROPERTY_STRING)ExtNumbers[i]); 
            break; 
        } 
      //--- display property value 
      ExtLabelsValue[i].Description(text); 
     } 
  } 
//+------------------------------------------------------------------+ 
//| Create the panel for managing chart properties                   | 
//+------------------------------------------------------------------+ 
bool PrepareControls(void) 
  { 
//--- allocate memory for arrays with a reserve 
   MemoryAllocation(LAST_PROPERTY_NUMBER+1); 
//--- variables 
   int i=0;     // loop variable 
   int col_1=0; // number of properties in the first column 
   int col_2=0; // number of properties in the second column 
   int col_3=0; // number of properties in the third column 
//--- current number of properties - 0 
   ExtCount=0; 
//--- looking for properties in the loop 
   while(i<=LAST_PROPERTY_NUMBER) 
     { 
      //--- store the current number of the property 
      ExtNumbers[ExtCount]=i; 
      //--- increase the value of the loop variable 
      i++; 
      //--- check if there is a property with such a number 
      if(CheckNumber(ExtNumbers[ExtCount],ExtNames[ExtCount],ExtDataTypes[ExtCount],ExtGroupTypes[ExtCount],ExtDrawTypes[ExtCount])) 
        { 
         //--- create control elements for the property 
         switch(ExtGroupTypes[ExtCount]) 
           { 
            case 1: 
               //--- create labels and a button for the property 
               if(!ShowProperty(ExtCount,0,X_PROPERTY_NAME_1,X_PROPERTY_VALUE_1,X_BUTTON_1,Y_PROPERTY_1+col_1*Y_DISTANCE,true)) 
               return(false); 
               //--- number of the elements in the first column has increased 
               col_1++; 
               break; 
            case 2: 
               //--- create labels and a button for the property 
               if(!ShowProperty(ExtCount,1,X_PROPERTY_NAME_2,X_PROPERTY_VALUE_2,X_BUTTON_2,Y_PROPERTY_1+col_2*Y_DISTANCE,true)) 
               return(false); 
               //--- number of the elements in the second column has increased 
               col_2++; 
               break; 
            case 3: 
               //--- create only labels for the property 
               if(!ShowProperty(ExtCount,2,X_PROPERTY_NAME_2,X_PROPERTY_VALUE_2,0,Y_PROPERTY_2+col_3*Y_DISTANCE,false)) 
               return(false); 
               //--- number of the elements in the third column has increased 
               col_3++; 
               break; 
           } 
         //--- define maximum and minimum property value and step 
         GetMaxMinStep(ExtNumbers[ExtCount],ExtMaxValue[ExtCount],ExtMinValue[ExtCount],ExtStep[ExtCount]); 
         //--- increase the number of properties 
         ExtCount++; 
        } 
     } 
//--- free the memory not used by arrays 
   MemoryAllocation(ExtCount); 
//--- re-draw property values 
   RedrawProperties(); 
   ChartRedraw(); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Allocate memory for arrays                                       | 
//+------------------------------------------------------------------+ 
void MemoryAllocation(const int size) 
  { 
   ArrayResize(ExtLabelsName,size); 
   ArrayResize(ExtLabelsValue,size); 
   ArrayResize(ExtButtons,size); 
   ArrayResize(ExtNumbers,size); 
   ArrayResize(ExtNames,size); 
   ArrayResize(ExtDataTypes,size); 
   ArrayResize(ExtGroupTypes,size); 
   ArrayResize(ExtDrawTypes,size); 
   ArrayResize(ExtMaxValue,size); 
   ArrayResize(ExtMinValue,size); 
   ArrayResize(ExtStep,size); 
  } 
//+------------------------------------------------------------------+ 
//| Check if the property index belongs to the one of                | 
//| ENUM_CHART_PROPERTIES enumerations                               | 
//+------------------------------------------------------------------+ 
bool CheckNumber(const int ind,string &name,uchar &data_type,uint &group_type,uchar &draw_type) 
  { 
//--- check if the property is of integer type 
   ResetLastError(); 
   name=EnumToString((ENUM_CHART_PROPERTY_INTEGER)ind); 
   if(_LastError==0) 
     { 
      data_type='I';                      // property from ENUM_CHART_PROPERTY_INTEGER enumeration 
      GetTypes(ind,group_type,draw_type); // define property display parameters 
      return(true); 
     } 
//--- check if the property is of double type 
   ResetLastError(); 
   name=EnumToString((ENUM_CHART_PROPERTY_DOUBLE)ind); 
   if(_LastError==0) 
     { 
      data_type='D';                      // property from ENUM_CHART_PROPERTY_DOUBLE enumeration 
      GetTypes(ind,group_type,draw_type); // define property display parameters 
      return(true); 
     } 
//--- check if the property is of string type 
   ResetLastError(); 
   name=EnumToString((ENUM_CHART_PROPERTY_STRING)ind); 
   if(_LastError==0) 
     { 
      data_type='S';                      // property from ENUM_CHART_PROPERTY_STRING enumeration 
      GetTypes(ind,group_type,draw_type); // define property display parameters 
      return(true); 
     } 
//--- property does not belong to any enumeration 
   return(false); 
  } 
//+------------------------------------------------------------------+ 
//| Define the group the property should be stored in,               | 
//| as well as its display type                                      | 
//+------------------------------------------------------------------+ 
void GetTypes(const int property_number,uint &group_type,uchar &draw_type) 
  { 
//--- check if the property belongs to the third group 
//--- third group properties are displayed in the second column starting from CHART_BRING_TO_TOP 
   if(CheckThirdGroup(property_number,group_type,draw_type)) 
      return; 
//--- check if the property belongs to the second group 
//--- second group properties are displayed at the beginning of the second column 
   if(CheckSecondGroup(property_number,group_type,draw_type)) 
      return; 
//--- if you find yourself here, the property belongs to the first group (first column) 
   CheckFirstGroup(property_number,group_type,draw_type); 
  } 
//+----------------------------------------------------------------------+ 
//| The function checks if the property belongs to the third group and   | 
//| defines its display type in case of a positive answer                | 
//+----------------------------------------------------------------------+ 
bool CheckThirdGroup(const int property_number,uint &group_type,uchar &draw_type) 
  { 
//--- check if the property belongs to the third group 
   switch(property_number) 
     { 
      //--- boolean properties 
      case CHART_WINDOW_IS_VISIBLE: 
         draw_type='B'; 
         break; 
         //--- integer properties 
      case CHART_VISIBLE_BARS: 
      case CHART_WINDOWS_TOTAL: 
      case CHART_WINDOW_HANDLE: 
      case CHART_WINDOW_YDISTANCE: 
      case CHART_FIRST_VISIBLE_BAR: 
      case CHART_WIDTH_IN_BARS: 
      case CHART_WIDTH_IN_PIXELS: 
         draw_type='I'; 
         break; 
         //--- double properties 
      case CHART_PRICE_MIN: 
      case CHART_PRICE_MAX: 
         draw_type='D'; 
         break; 
         //--- in fact, this property is a command of displaying the chart on top of all the others 
         //--- there is no need to apply this panel, as the window will always be 
         //--- on top of other ones before we use it 
      case CHART_BRING_TO_TOP: 
         draw_type=' '; 
         break; 
         //--- property does not belong to the third group 
      default: 
         return(false); 
     } 
//--- property belongs to the third group 
   group_type=3; 
   return(true); 
  } 
//+----------------------------------------------------------------------+ 
//| The function checks if the property belongs to the second group and  | 
//| defines its display type in case of a positive answer                | 
//+----------------------------------------------------------------------+ 
bool CheckSecondGroup(const int property_number,uint &group_type,uchar &draw_type) 
  { 
//--- check if the property belongs to the second group 
   switch(property_number) 
     { 
      //--- ENUM_CHART_MODE type property 
      case CHART_MODE: 
         draw_type='M'; 
         break; 
         //--- ENUM_CHART_VOLUME_MODE type property 
      case CHART_SHOW_VOLUMES: 
         draw_type='V'; 
         break; 
         //--- string property 
      case CHART_COMMENT: 
         draw_type='S'; 
         break; 
         //--- color property 
      case CHART_COLOR_BACKGROUND: 
      case CHART_COLOR_FOREGROUND: 
      case CHART_COLOR_GRID: 
      case CHART_COLOR_VOLUME: 
      case CHART_COLOR_CHART_UP: 
      case CHART_COLOR_CHART_DOWN: 
      case CHART_COLOR_CHART_LINE: 
      case CHART_COLOR_CANDLE_BULL: 
      case CHART_COLOR_CANDLE_BEAR: 
      case CHART_COLOR_BID: 
      case CHART_COLOR_ASK: 
      case CHART_COLOR_LAST: 
      case CHART_COLOR_STOP_LEVEL: 
         draw_type='C'; 
         break; 
         //--- property does not belong to the second group 
      default: 
         return(false); 
     } 
//--- property belongs to the second group 
   group_type=2; 
   return(true); 
  } 
//+-----------------------------------------------------------------------+ 
//| This function is called only if it is already known that              | 
//| the property does not belong to the second and third property groups  | 
//+-----------------------------------------------------------------------+ 
void CheckFirstGroup(const int property_number,uint &group_type,uchar &draw_type) 
  { 
//--- the property belongs to the first group 
   group_type=1; 
//--- define property display type 
   switch(property_number) 
     { 
      //--- integer properties 
      case CHART_SCALE: 
      case CHART_HEIGHT_IN_PIXELS: 
         draw_type='I'; 
         return; 
         //--- double properties 
      case CHART_SHIFT_SIZE: 
      case CHART_FIXED_POSITION: 
      case CHART_FIXED_MAX: 
      case CHART_FIXED_MIN: 
      case CHART_POINTS_PER_BAR: 
         draw_type='D'; 
         return; 
         //--- only boolean properties have remained 
      default: 
         draw_type='B'; 
         return; 
     } 
  } 
//+------------------------------------------------------------------+ 
//| Create a label and a button for the property                     | 
//+------------------------------------------------------------------+ 
bool ShowProperty(const int ind,const int type,const int x1,const int x2, 
                  const int xb,const int y,const bool btn) 
  { 
//--- static array for switching inside ExtColors color array 
   static uint color_index[3]={1,1,1}; 
//--- change index for receiving another color 
   color_index[type]=1-color_index[type]; 
//--- display labels and a button (if btn=true) for the property 
   if(!LabelCreate(ExtLabelsName[ind],"name_"+(string)ind,ExtNames[ind],ExtColors[color_index[type]],x1,y)) 
      return(false); 
   if(!LabelCreate(ExtLabelsValue[ind],"value_"+(string)ind,"",ExtColors[color_index[type]],x2,y)) 
      return(false); 
   if(btn && !ButtonCreate(ExtButtons[ind],(string)ind,xb,y+1)) 
      return(false); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Create a label                                                   | 
//+------------------------------------------------------------------+ 
bool LabelCreate(CChartObjectLabel &lbl,const string name,const string text, 
                 const color clr,const int x,const int y) 
  { 
   if(!lbl.Create(0,"Label_"+name,0,x,y)) return(false); 
   if(!lbl.Description(text))             return(false); 
   if(!lbl.FontSize(10))                  return(false); 
   if(!lbl.Color(clr))                    return(false); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Create the button                                                | 
//+------------------------------------------------------------------+ 
bool ButtonCreate(CChartObjectButton &btn,const string name, 
                  const int x,const int y) 
  { 
   if(!btn.Create(0,"Button_"+name,0,x,y,50,15)) return(false); 
   if(!btn.Description("Next"))                  return(false); 
   if(!btn.FontSize(10))                         return(false); 
   if(!btn.Color(clrBlack))                      return(false); 
   if(!btn.BackColor(clrWhite))                  return(false); 
   if(!btn.BorderColor(clrBlack))                return(false); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Define maximum and minimum property value and step               | 
//+------------------------------------------------------------------+ 
void GetMaxMinStep(const int property_number,double &max,double &min,double &step) 
  { 
   double value; 
//--- set values depending on the property type 
   switch(property_number) 
     { 
      case CHART_SCALE: 
         max=5; 
         min=0; 
         step=1; 
         break; 
      case CHART_MODE: 
      case CHART_SHOW_VOLUMES: 
         max=2; 
         min=0; 
         step=1; 
         break; 
      case CHART_SHIFT_SIZE: 
         max=50; 
         min=10; 
         step=2.5; 
         break; 
      case CHART_FIXED_POSITION: 
         max=90; 
         min=0; 
         step=15; 
         break; 
      case CHART_POINTS_PER_BAR: 
         max=19; 
         min=1; 
         step=3; 
         break; 
      case CHART_FIXED_MAX: 
         value=ChartGetDouble(0,CHART_FIXED_MAX); 
         max=value*1.25; 
         min=value; 
         step=value/32; 
         break; 
      case CHART_FIXED_MIN: 
         value=ChartGetDouble(0,CHART_FIXED_MIN); 
         max=value; 
         min=value*0.75; 
         step=value/32; 
         break; 
      case CHART_HEIGHT_IN_PIXELS: 
         max=700; 
         min=520; 
         step=30; 
         break; 
         //--- default values 
      default: 
         max=1; 
         min=0; 
         step=1; 
     } 
  }