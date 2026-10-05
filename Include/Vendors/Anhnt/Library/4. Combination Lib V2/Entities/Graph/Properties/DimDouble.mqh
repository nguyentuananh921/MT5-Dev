//+------------------------------------------------------------------+
//|                                      DimDouble.mqh              |
//+------------------------------------------------------------------+
#ifndef __DIMDOUBLE_MQH__
#define __DIMDOUBLE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\..\Services\Message\Message.mqh"
 #include "DataUnitDouble.mqh"
#ifndef CDIMDOUBLE_MQH_DECLARATION
#define CDIMDOUBLE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Class of a single double array dimension                           |
  //+------------------------------------------------------------------+
  class CDimDouble : public CArrayObj
   {
      private:
      //--- Create a new data object
      CDataUnitDouble  *CreateData(const string source,const double value=0);
      //--- Get double data object from the array
      CDataUnitDouble  *GetData(const string source,const int index) const;
      //--- Add the specified number of cells with data to the end of the array
      bool              AddQuantity(const string source,const int total,const double value=0);
      protected:

      public:
      //--- Initialize the array
      void              Initialize(const int total,const double value=0);
      //--- Increase the number of data cells by the specified value, return the number of added elements
      int               Increase(const int total,const double value=0);
      //--- Decrease the number of data cells by the specified value, return the number of removed elements. The very first element always remains
      int               Decrease(const int total);
      //--- Set a new array size
      bool              SetSize(const int size,const double initial_value=0);
      //--- Set the value to the specified array cell
      bool              Set(const int index,const double value);
      //--- Return the amount of data (array size)
      int               Size(void) const { return this.Total(); }
      //--- Returns the value at the specified index
      double            Get(const int index) const;
      bool              Get(const int index, double &value) const;
      //--- Constructors
         CDimDouble(void);
         CDimDouble(const int total,const double value=0);
      //--- Destructor
         ~CDimDouble(void);
   };
#endif // CDIMDOUBLE_MQH_DECLARATION
#ifndef CDIMDOUBLE_MQH_IMPLEMENTATION
#define CDIMDOUBLE_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Create a new data object                                         |
   //+------------------------------------------------------------------+
   CDataUnitDouble *CDimDouble::CreateData(const string source,const double value)
   {
      CDataUnitDouble *data=new CDataUnitDouble();
      if(data==NULL)
         ::Print(source,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_DOUBLE_DATA_OBJ));
      else
         data.Value=value;
      return data;
   }
   //+------------------------------------------------------------------+
   //| Get double data object from the array                           |
   //+------------------------------------------------------------------+
   CDataUnitDouble *CDimDouble::GetData(const string source,const int index) const
   {
      CDataUnitDouble *data=this.At(index<0 ? 0 : index);
      if(data==NULL)
      {
         if(index>this.Total()-1)
            ::Print(source,CMessage::Text(MSG_LIB_SYS_REQUEST_OUTSIDE_DOUBLE_ARRAY)," (",index,"/",this.Total(),")");
         else
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_GET_DOUBLE_DATA_OBJ);
      }
      return data;
   }
   //+------------------------------------------------------------------+
   //| Add the specified number of cells with data to the end of array  |
   //+------------------------------------------------------------------+
   bool CDimDouble::AddQuantity(const string source,const int total,const double value)
   {
      bool res=true;
      for(int i=0;i<total;i++)
      {
         CDataUnitDouble *data=this.CreateData(DFUN,value);
         if(data==NULL)
         {
            res &=false;
            continue;
         }
         data.Value=value;
         if(!this.Add(data))
         {
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_OBJ_ADD_TO_LIST);
            delete data;
            res &=false;
            continue;
         }
      }
      return res;
   }
   //+------------------------------------------------------------------+
   //| Initialize the array                                             |
   //+------------------------------------------------------------------+
   void CDimDouble::Initialize(const int total,const double value)
   {
      this.Clear();
      this.Increase(total,value);
   }
   //+------------------------------------------------------------------+
   //| Increase the number of data cells by the specified value         |
   //+------------------------------------------------------------------+
   int CDimDouble::Increase(const int total,const double value)
   {
      int size_prev=this.Total();
      this.AddQuantity(DFUN,total,value);
      return this.Total()-size_prev;
   }
   //+------------------------------------------------------------------+
   //| Decrease the number of data cells by the specified value         |
   //+------------------------------------------------------------------+
   int CDimDouble::Decrease(const int total)
   {
      if(total>this.Total()-1)
         return 0;
      int total_prev=this.Total();
      int from=this.Total()-total;
      int to=this.Total()-1;
      if(!this.DeleteRange(from,to))
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_DECREASE_DOUBLE_ARRAY);
      return total_prev-this.Total();
   }
   //+------------------------------------------------------------------+
   //| Set a new array size                                             |
   //+------------------------------------------------------------------+
   bool CDimDouble::SetSize(const int size,const double initial_value)
   {
      if(size==0)
         return false;
      int total=fabs(size-this.Total());
      if(size>this.Total())
         return(this.Increase(total,initial_value)==total);
      else if(size<this.Total())
         return(this.Decrease(total)==total);
      return true;
   }
   //+------------------------------------------------------------------+
   //| Set the value to the specified array cell                        |
   //+------------------------------------------------------------------+
   bool CDimDouble::Set(const int index,const double value)
   {
      CDataUnitDouble *data=this.GetData(DFUN,index);
      if(data==NULL)
         return false;
      data.Value=value;
      return true;
   }
   //+------------------------------------------------------------------+
   //| Returns the value at the specified index                         |
   //+------------------------------------------------------------------+
   double CDimDouble::Get(const int index) const
   {
      CDataUnitDouble *data=this.GetData(DFUN,index);
      return(data!=NULL ? data.Value : 0);
   }
   //+------------------------------------------------------------------+
   //| Returns the value at the specified index by reference            |
   //+------------------------------------------------------------------+
   bool CDimDouble::Get(const int index, double &value) const
   {
      value=0;
      CDataUnitDouble *data=this.GetData(DFUN,index);
      if(data==NULL)
         return false;
      value = data.Value;
      return true;
   }
   //+------------------------------------------------------------------+
   //| Constructors                                                     |
   //+------------------------------------------------------------------+
   CDimDouble::CDimDouble(void)
   {
      this.Initialize(1);
   }
   CDimDouble::CDimDouble(const int total,const double value)
   {
      this.Initialize(total,value);
   }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CDimDouble::~CDimDouble(void)
   {
      this.Clear();
      this.Shutdown();
   }
#endif // CDIMDOUBLE_MQH_IMPLEMENTATION
#endif // __DIMDOUBLE_MQH__
