//+------------------------------------------------------------------+
//|                                               PivotPointData.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|  Extracted from Artyom Trishkin's DoEasy GStdGraphObj.mqh        |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4

#ifndef CPIVOTPOINTDATA_MQH
#define CPIVOTPOINTDATA_MQH
 #include "..\..\..\Notify\Message\Message.mqh"
 #ifndef CPIVOTPOINTDATA_MQH_DECLARATION
 #define CPIVOTPOINTDATA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Class of the dependent object pivot point data                   |
 //+------------------------------------------------------------------+
 class CPivotPointData
  {
   private:
    bool              m_axis_x;
    int               m_property[][2];
   public:
    //--- (1) Set and (2) return the flag indicating that the pivot point belongs to the X coordinate
     void              SetAxisX(const bool axis_x)         { this.m_axis_x=axis_x;             }
     bool              IsAxisX(void)                 const { return this.m_axis_x;             }
     string            AxisDescription(void)         const { return(this.m_axis_x ? "X" : "Y");}
    //--- Return the number of base object pivot points for calculating the coordinate of the dependent one
     int               GetBasePivotsNum(void)  const { return ::ArrayRange(this.m_property,0);  }
    //--- Add the new pivot point of the base object for calculating the coordinate of a dependent one
     bool              AddNewBasePivotPoint(const string source,const int pivot_prop,const int pivot_num);
    //--- Change the specified pivot point of the base object for calculating the coordinate of a dependent one
     bool              ChangeBasePivotPoint(const string source,const int pivot_index,const int pivot_prop,const int pivot_num);
    //--- Return(1) a property and (2) a modifier of the property from the array
     int               GetProperty(const string source,const int index)     const;
     int               GetPropertyModifier(const string source,const int index)  const;
     string            GetBasePivotsNumDescription(void) const;
    //--- Constructor/destructor
                     CPivotPointData(void){;}
                    ~CPivotPointData(void){;}
  };
 #endif // CPIVOTPOINTDATA_MQH_DECLARATION
 #ifndef CPIVOTPOINTDATA_MQH_IMPLEMENTATION
 #define CPIVOTPOINTDATA_MQH_IMPLEMENTATION
  //--- Add the new pivot point of the base object for calculating the coordinate of a dependent one
   bool CPivotPointData::AddNewBasePivotPoint(const string source,const int pivot_prop,const int pivot_num)
    {
        //--- Get the array size 
        int pivot_index=this.GetBasePivotsNum();
        //--- if failed to increase the array size, inform of that and return 'false'
        if(::ArrayResize(this.m_property,pivot_index+1)!=pivot_index+1)
            {
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
            return false;
            }
        //--- Return the result of changing the values of a newly added new array dimension
        return this.ChangeBasePivotPoint(source,pivot_index,pivot_prop,pivot_num);
    }
  //--- Change the specified pivot point of the base object for calculating the coordinate of a dependent one
   bool CPivotPointData:: ChangeBasePivotPoint(const string source,const int pivot_index,const int pivot_prop,const int pivot_num)
    {
     //--- Get the array size. If it is zero, inform of that and return 'false'
     int n=this.GetBasePivotsNum();
     if(n==0)
       {
        CMessage::ToLog(source,(this.IsAxisX() ? MSG_GRAPH_OBJ_EXT_NOT_ANY_PIVOTS_X : MSG_GRAPH_OBJ_EXT_NOT_ANY_PIVOTS_Y));
        return false;
        }
     //--- If the specified index goes beyond the array range, inform of that and return 'false'
     if(pivot_index<0 || pivot_index>n-1)
       {
        CMessage::ToLog(source,MSG_LIB_SYS_REQUEST_OUTSIDE_ARRAY);
        return false;
        }
     //--- Set the values, passed to the method, in the specified array cells by index
      this.m_property[pivot_index][0]=pivot_prop;
      this.m_property[pivot_index][1]=pivot_num;
      return true;
    }
  //--- Return(1) a property and (2) a modifier of the property from the array
   int CPivotPointData::GetProperty(const string source,const int index)     const
    {
      if(index<0 || index>this.GetBasePivotsNum()-1)
        {
         CMessage::ToLog(source,MSG_LIB_SYS_REQUEST_OUTSIDE_ARRAY);
         return WRONG_VALUE;
        }
      return this.m_property[index][0];   
    }
   int CPivotPointData::GetPropertyModifier(const string source,const int index)  const
    {
      if(index<0 || index>this.GetBasePivotsNum()-1)
        {
         CMessage::ToLog(source,MSG_LIB_SYS_REQUEST_OUTSIDE_ARRAY);
         return WRONG_VALUE;
        }
      return this.m_property[index][1];   
    }
   //--- Return the description of the number of pivot points for setting the coordinate
   string CPivotPointData::GetBasePivotsNumDescription(void) const
    {
      return CMessage::Text(IsAxisX() ? MSG_GRAPH_OBJ_EXT_NUM_BASE_PP_TO_SET_X : MSG_GRAPH_OBJ_EXT_NUM_BASE_PP_TO_SET_Y)+
             (string)this.GetBasePivotsNum();
    }
#endif // CPIVOTPOINTDATA_MQH_IMPLEMENTATION
#endif // CPIVOTPOINTDATA_MQH



