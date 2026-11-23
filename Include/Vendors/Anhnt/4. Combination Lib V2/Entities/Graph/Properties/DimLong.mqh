//+------------------------------------------------------------------+
//|                                        DimLong.mqh              |
//+------------------------------------------------------------------+
#ifndef __DIMLONG_MQH__
#define __DIMLONG_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\..\Services\Message\Message.mqh"
 #include "DataUnitLong.mqh"
#ifndef CDIMLONG_MQH_DECLARATION
#define CDIMLONG_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Class of a single long array dimension                           |
  //+------------------------------------------------------------------+
  class CDimLong : public CArrayObj
   {
      private:
      //--- Create a new data object
      CDataUnitLong  *CreateData(const string source,const long value=0);
      //--- Get long data object from the array
      CDataUnitLong  *GetData(const string source,const int index) const;
      //--- Add the specified number of cells with data to the end of the array
      bool              AddQuantity(const string source,const int total,const long value=0);
      protected:

      public:
      //--- Initialize the array
      void              Initialize(const int total,const long value=0);
      //--- Increase the number of data cells by the specified value, return the number of added elements
      int               Increase(const int total,const long value=0);
      //--- Decrease the number of data cells by the specified value, return the number of removed elements. The very first element always remains
      int               Decrease(const int total);
      //--- Set a new array size
      bool              SetSize(const int size,const long initial_value=0);
      //--- Set the value to the specified array cell
      bool              Set(const int index,const long value);
      //--- Return the amount of data (array size)
      int               Size(void) const { return this.Total(); }
      //--- Returns the value at the specified index
      long            Get(const int index) const;
      bool              Get(const int index, long &value) const;
      //--- Constructors
                           CDimLong(void);
                           CDimLong(const int total,const long value=0);
      //--- Destructor
                     ~CDimLong(void);
   };
#endif // CDIMLONG_MQH_DECLARATION
#ifndef CDIMLONG_MQH_IMPLEMENTATION
#define CDIMLONG_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Create a new data object                                         |
  //+------------------------------------------------------------------+
  CDataUnitLong *CDimLong::CreateData(const string source,const long value)
   {
      CDataUnitLong *data=new CDataUnitLong();
      if(data==NULL)
         ::Print(source,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_LONG_DATA_OBJ));
      else
         data.Value=value;
      return data;
   }
  //+------------------------------------------------------------------+
  //| Get long data object from the array                           |
  //+------------------------------------------------------------------+
  CDataUnitLong *CDimLong::GetData(const string source,const int index) const
   {
      CDataUnitLong *data=this.At(index<0 ? 0 : index);
      if(data==NULL)
      {
         if(index>this.Total()-1)
            ::Print(source,CMessage::Text(MSG_LIB_SYS_REQUEST_OUTSIDE_LONG_ARRAY)," (",index,"/",this.Total(),")");
         else
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_GET_LONG_DATA_OBJ);
      }
      return data;
   }
  //+------------------------------------------------------------------+
  //| Add the specified number of cells with data to the end of array  |
  //+------------------------------------------------------------------+
  bool CDimLong::AddQuantity(const string source,const int total,const long value)
   {
      bool res=true;
      for(int i=0;i<total;i++)
      {
         CDataUnitLong *data=this.CreateData(DFUN,value);
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
  void CDimLong::Initialize(const int total,const long value)
   {
      this.Clear();
      this.Increase(total,value);
   }
  //+------------------------------------------------------------------+
  //| Increase the number of data cells by the specified value         |
  //+------------------------------------------------------------------+
  int CDimLong::Increase(const int total,const long value)
   {
      int size_prev=this.Total();
      this.AddQuantity(DFUN,total,value);
      return this.Total()-size_prev;
   }
  //+------------------------------------------------------------------+
  //| Decrease the number of data cells by the specified value         |
  //+------------------------------------------------------------------+
  int CDimLong::Decrease(const int total)
   {
      if(total>this.Total()-1)
         return 0;
      int total_prev=this.Total();
      int from=this.Total()-total;
      int to=this.Total()-1;
      if(!this.DeleteRange(from,to))
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_DECREASE_LONG_ARRAY);
      return total_prev-this.Total();
   }
  //+------------------------------------------------------------------+
  //| Set a new array size                                             |
  //+------------------------------------------------------------------+
  bool CDimLong::SetSize(const int size,const long initial_value)
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
  bool CDimLong::Set(const int index,const long value)
   {
      CDataUnitLong *data=this.GetData(DFUN,index);
      if(data==NULL)
         return false;
      data.Value=value;
      return true;
   }
  //+------------------------------------------------------------------+
  //| Returns the value at the specified index                         |
  //+------------------------------------------------------------------+
  long CDimLong::Get(const int index) const
   {
      CDataUnitLong *data=this.GetData(DFUN,index);
      return(data!=NULL ? data.Value : 0);
   }
  //+------------------------------------------------------------------+
  //| Returns the value at the specified index by reference            |
  //+------------------------------------------------------------------+
  bool CDimLong::Get(const int index, long &value) const
   {
      value=0;
      CDataUnitLong *data=this.GetData(DFUN,index);
      if(data==NULL)
         return false;
      value = data.Value;
      return true;
   }
  //+------------------------------------------------------------------+
  //| Constructors                                                     |
  //+------------------------------------------------------------------+
  CDimLong::CDimLong(void)
   {
      this.Initialize(1);
   }
  CDimLong::CDimLong(const int total,const long value)
   {
      this.Initialize(total,value);
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CDimLong::~CDimLong(void)
   {
      this.Clear();
      this.Shutdown();
   }
#endif // CDIMLONG_MQH_IMPLEMENTATION
#endif // __DIMLONG_MQH__
