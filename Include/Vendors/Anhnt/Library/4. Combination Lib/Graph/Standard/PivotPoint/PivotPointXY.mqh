//+------------------------------------------------------------------+
//|                                               PivotPointXY.mqh   |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|  Extracted from Artyom Trishkin's DoEasy GStdGraphObj.mqh        |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef CPIVOTPOINTXY_MQH
#define CPIVOTPOINTXY_MQH
 #include <Object.mqh>
 #include "PivotPointData.mqh"
 #include "..\..\..\Defines\CommonDefines.mqh"
 
 #ifndef CPIVOTPOINTXY_MQH_DECLARATION
 #define CPIVOTPOINTXY_MQH_DECLARATION
 //+------------------------------------------------------------------+
//| Class of data on X and Y pivot points of a composite object      |
//+------------------------------------------------------------------+
class CPivotPointXY : public CObject
  {
   private:
     CPivotPointData   m_pivot_point_x;            // X coordinate pivot point
     CPivotPointData   m_pivot_point_y;            // Y coordinate pivot point
   public:
    //--- Return the pointer to the (1) X and (2) Y coordinate pivot point data object
     CPivotPointData  *GetPivotPointDataX(void)      { return &this.m_pivot_point_x;                    }
     CPivotPointData  *GetPivotPointDataY(void)      { return &this.m_pivot_point_y;                    }
    //--- Return the number of base object pivot points for calculating the (1) X and (2) Y coordinate
     int               GetBasePivotsNumX(void) const { return this.m_pivot_point_x.GetBasePivotsNum();  }
     int               GetBasePivotsNumY(void) const { return this.m_pivot_point_y.GetBasePivotsNum();  }
    //--- Add the new pivot point of the base object for calculating the X coordinate of a dependent one
     bool              AddNewBasePivotPointX(const int pivot_prop,const int pivot_num){ return this.m_pivot_point_x.AddNewBasePivotPoint(DFUN,pivot_prop,pivot_num); }
    //--- Add the new pivot point of the base object for calculating the Y coordinate of a dependent one
     bool              AddNewBasePivotPointY(const int pivot_prop,const int pivot_num) { return this.m_pivot_point_y.AddNewBasePivotPoint(DFUN,pivot_prop,pivot_num); }
    //--- Add new pivot points of the base object for calculating the X and Y coordinates of a dependent one
     bool              AddNewBasePivotPointXY(const int pivot_prop_x,const int pivot_num_x,
                                            const int pivot_prop_y,const int pivot_num_y)
                       {
                        bool res=true;
                        res &=this.m_pivot_point_x.AddNewBasePivotPoint(DFUN,pivot_prop_x,pivot_num_x);
                        res &=this.m_pivot_point_y.AddNewBasePivotPoint(DFUN,pivot_prop_y,pivot_num_y);
                        return res;
                       }
    //--- Change the specified pivot point of the base object for calculating the X coordinate of a dependent one
     bool              ChangeBasePivotPointX(const int pivot_index,const int pivot_prop,const int pivot_num) { return this.m_pivot_point_x.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop,pivot_num);}
    //--- Change the specified pivot point of the base object for calculating the Y coordinate of a dependent one
     bool              ChangeBasePivotPointY(const int pivot_index,const int pivot_prop,const int pivot_num) { return this.m_pivot_point_y.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop,pivot_num);}
    //--- Change specified pivot points of the base object for calculating the X and Y coordinates
     bool              ChangeBasePivotPointXY(const int pivot_index,
                                            const int pivot_prop_x,const int pivot_num_x,
                                            const int pivot_prop_y,const int pivot_num_y)
                       {
                        bool res=true;
                        res &=this.m_pivot_point_x.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop_x,pivot_num_x);
                        res &=this.m_pivot_point_y.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop_y,pivot_num_y);
                        return res;
                       }
    //--- Return (1) the property for calculating the X coordinate and (2) the X coordinate property modifier
     int               GetPropertyX(const string source,const int index) const { return this.m_pivot_point_x.GetProperty(source,index);}
     int               GetPropertyModifierX(const string source,const int index) const { return this.m_pivot_point_x.GetPropertyModifier(source,index);}
    //--- Return (1) the property for calculating the Y coordinate and (2) the Y coordinate property modifier
     int               GetPropertyY(const string source,const int index) const { return this.m_pivot_point_y.GetProperty(source,index);}
     int               GetPropertyModifierY(const string source,const int index) const{ return this.m_pivot_point_y.GetPropertyModifier(source,index);}
    //--- Return the description of the number of pivot points for setting the (1) X and (2) Y coordinates
     string            GetBasePivotsNumXDescription(void) const{ return this.m_pivot_point_x.GetBasePivotsNumDescription();}
     string            GetBasePivotsNumYDescription(void) const{ return this.m_pivot_point_y.GetBasePivotsNumDescription();}
    //--- Constructor/destructor
                     CPivotPointXY(void){ this.m_pivot_point_x.SetAxisX(true); this.m_pivot_point_y.SetAxisX(false); }
                    ~CPivotPointXY(void){;}
  };  
 #endif // CPIVOTPOINTXY_MQH_DECLARATION
 #ifndef CPIVOTPOINTXY_MQH_IMPLEMENTATION
 #define CPIVOTPOINTXY_MQH_IMPLEMENTATION

 #endif // CPIVOTPOINTXY_MQH_IMPLEMENTATION
#endif // CPIVOTPOINTXY_MQH




