//+------------------------------------------------------------------+
//|                                           LinkedPivotPoint.mqh   |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|  Extracted from Artyom Trishkin's DoEasy GStdGraphObj.mqh        |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef CLINKEDPIVOTPOINT_MQH
#define CLINKEDPIVOTPOINT_MQH
 #include <Arrays\ArrayObj.mqh>
 #include "PivotPointXY.mqh"
 #ifndef CLINKEDPIVOTPOINT_MQH_DECLARATION
 #define CLINKEDPIVOTPOINT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Class of connected data on composite object pivot points         |
//+------------------------------------------------------------------+
class CLinkedPivotPoint
  {
   private:
    CArrayObj         m_list;                       // List of pivot points of the bound object X and Y coordinates
    int               m_base_obj_index;             // Base object index
   public:
    //--- (1) Set and (2) return the base object index
     void              SetBaseObjIndex(const int index)       { this.m_base_obj_index=index;                  }
     int               GetBaseObjIndex(void)            const { return this.m_base_obj_index;                 }
    //--- Create a new object of the class of data on X and Y pivot points of a composite object and add it to the object list
     bool              CreateNewLinkedCoord(const int pivot_prop_x,const int pivot_num_x,const int pivot_prop_y,const int pivot_num_y)
                       {
                        //--- Create an object of data on X and Y pivot points
                        CPivotPointXY *obj=new CPivotPointXY();
                        if(obj==NULL)
                           return false;
                        //--- Add a single dimension with data on pivot points of the base object by X and Y to each object
                        if(!obj.AddNewBasePivotPointXY(pivot_prop_x,pivot_num_x,pivot_prop_y,pivot_num_y))
                           return false;
                        //--- If failed to add the newly created object to the list, inform of that, remove the object and return 'false'
                        if(!this.m_list.Add(obj))
                          {
                           CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_OBJ_ADD_TO_LIST);
                           delete obj;
                           return false;
                          }
                        //--- All is successful - return 'true'
                        return true;
                       }
   
    //--- Return the amount of data on pivot points of X and Y coordinates
     int               GetNumLinkedCoords(void)               const {  return this.m_list.Total();                  }
    //--- Return the pointer to the (1) first and (2) the last object of data on X and Y pivot points (3) by index
     CPivotPointXY    *GetLinkedCoordFirst(void)              const { return this.m_list.At(0);                     }
     CPivotPointXY    *GetLinkedCoordLast(void)               const { return this.m_list.At(this.m_list.Total()-1); }
     CPivotPointXY    *GetLinkedCoord(const int index)        const { return this.m_list.At(index);                 }
    //--- Return the pointer to the X coordinate pivot point data object by index
     CPivotPointData  *GetBasePivotPointDataX(const int index_coord_point) const
                       {
                        CPivotPointXY *obj=this.GetLinkedCoord(index_coord_point);
                        return(obj!=NULL ? obj.GetPivotPointDataX() : NULL);
                       }
    //--- Return the pointer to the Y coordinate pivot point data object by index
     CPivotPointData  *GetBasePivotPointDataY(const int index_coord_point) const
                       {
                        CPivotPointXY *obj=this.GetLinkedCoord(index_coord_point);
                        return(obj!=NULL ? obj.GetPivotPointDataY() : NULL);
                       }
    //--- Return the number of base object pivot points for calculating the X coordinate by index
     int               GetBasePivotsNumX(const int index_coord_point) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataX(index_coord_point);
                        return(obj!=NULL ? obj.GetBasePivotsNum() : 0);
                       }
    //--- Return the number of base object pivot points for calculating the Y coordinate by index
     int               GetBasePivotsNumY(const int index_coord_point) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataY(index_coord_point);
                        return(obj!=NULL ? obj.GetBasePivotsNum() : 0);
                       }
   
    //--- Add the new pivot point of the base object for calculating the X coordinate for a specified anchor point of the dependent one
     bool              AddNewBasePivotPointX(const int index_coord_point,const int pivot_prop,const int pivot_num)
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataX(index_coord_point);
                        return(obj!=NULL ? obj.AddNewBasePivotPoint(DFUN,pivot_prop,pivot_num) : false);
                       }
    //--- Add the new pivot point of the base object for calculating the Y coordinate for a specified anchor point of the dependent one
     bool              AddNewBasePivotPointY(const int index_coord_point,const int pivot_prop,const int pivot_num)
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataY(index_coord_point);
                        return(obj!=NULL ? obj.AddNewBasePivotPoint(DFUN,pivot_prop,pivot_num) : false);
                       }
    //--- Add the new pivot points of the base object for calculating the X and Y coordinates for a specified anchor point of the dependent one
     bool              AddNewBasePivotPointXY(const int index_coord_point,
                                            const int pivot_prop_x,const int pivot_num_x,
                                            const int pivot_prop_y,const int pivot_num_y)
                       {
                        CPivotPointData *objx=this.GetBasePivotPointDataX(index_coord_point);
                        if(objx==NULL)
                           return false;
                        CPivotPointData *objy=this.GetBasePivotPointDataY(index_coord_point);
                        if(objy==NULL)
                           return false;
                        bool res=true;
                        res &=objx.AddNewBasePivotPoint(DFUN,pivot_prop_x,pivot_num_x);
                        res &=objy.AddNewBasePivotPoint(DFUN,pivot_prop_y,pivot_num_y);
                        return res;
                       }
    //--- Change the specified pivot point of the base object for calculating the X coordinate for a specified anchor point of the dependent one
     bool              ChangeBasePivotPointX(const int index_coord_point,const int pivot_index,const int pivot_prop,const int pivot_num)
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataX(index_coord_point);
                        return(obj!=NULL ? obj.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop,pivot_num) : false);
                       }
    //--- Change the specified pivot point of the base object for calculating the Y coordinate for a specified anchor point of the dependent one
     bool              ChangeBasePivotPointY(const int index_coord_point,const int pivot_index,const int pivot_prop,const int pivot_num)
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataY(index_coord_point);
                        return(obj!=NULL ? obj.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop,pivot_num) : false);
                       }
    //--- Change the specified pivot points of the base object for calculating the X and Y coordinates for a specified anchor point
     bool              ChangeBasePivotPointXY(const int index_coord_point,
                                            const int pivot_index,
                                            const int pivot_prop_x,const int pivot_num_x,
                                            const int pivot_prop_y,const int pivot_num_y)
                       {
                        CPivotPointData *objx=this.GetBasePivotPointDataX(index_coord_point);
                        if(objx==NULL)
                           return false;
                        CPivotPointData *objy=this.GetBasePivotPointDataY(index_coord_point);
                        if(objy==NULL)
                           return false;
                        bool res=true;
                        res &=objx.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop_x,pivot_num_x);
                        res &=objy.ChangeBasePivotPoint(DFUN,pivot_index,pivot_prop_y,pivot_num_y);
                        return res;
                       }

    //--- Return the property for calculating the X coordinate for a specified anchor point
     int               GetPropertyX(const int index_coord_point,const int index) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataX(index_coord_point);
                        return(obj!=NULL ? obj.GetProperty(DFUN,index) : WRONG_VALUE);
                       }
    //--- Return the modifier of the X coordinate property for a specified anchor point
     int               GetPropertyModifierX(const int index_coord_point,const int index) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataX(index_coord_point);
                        return(obj!=NULL ? obj.GetPropertyModifier(DFUN,index) : WRONG_VALUE);
                       }

    //--- Return the property for calculating the Y coordinate for a specified anchor point
     int               GetPropertyY(const int index_coord_point,const int index) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataY(index_coord_point);
                        return(obj!=NULL ? obj.GetProperty(DFUN,index) : WRONG_VALUE);
                       }
    //--- Return the modifier of the Y coordinate property for a specified anchor point
     int               GetPropertyModifierY(const int index_coord_point,const int index) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataY(index_coord_point);
                       return(obj!=NULL ? obj.GetPropertyModifier(DFUN,index) : WRONG_VALUE);
                       }

    //--- Return the description of the number of base object pivot points for calculating the X coordinate by index
     string            GetBasePivotsNumXDescription(const int index_coord_point) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataX(index_coord_point);
                        return(obj!=NULL ? obj.GetBasePivotsNumDescription() : "WRONG_VALUE");
                       }
    //--- Return the description of the number of base object pivot points for calculating the Y coordinate by index
     string            GetBasePivotsNumYDescription(const int index_coord_point) const
                       {
                        CPivotPointData *obj=this.GetBasePivotPointDataY(index_coord_point);
                        return(obj!=NULL ? obj.GetBasePivotsNumDescription() : "WRONG_VALUE");
                       }

    //--- Constructor/destructor
                     CLinkedPivotPoint(void){;}
                    ~CLinkedPivotPoint(void){;}
  };  
 #endif // CLINKEDPIVOTPOINT_MQH_DECLARATION
 #ifndef CLINKEDPIVOTPOINT_MQH_IMPLEMENTATION
 #define CLINKEDPIVOTPOINT_MQH_IMPLEMENTATION
 #endif // CLINKEDPIVOTPOINT_MQH_IMPLEMENTATION
#endif // CLINKEDPIVOTPOINT_MQH



