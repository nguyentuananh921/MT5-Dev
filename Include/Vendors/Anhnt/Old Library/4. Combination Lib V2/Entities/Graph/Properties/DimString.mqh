//+------------------------------------------------------------------+
//|                                      DimString.mqh              |
//+------------------------------------------------------------------+
#ifndef __DIMSTRING_MQH__
#define __DIMSTRING_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\..\Services\Message\Message.mqh"
 #include "DataUnitString.mqh"
#ifndef CDIMSTRING_MQH_DECLARATION
#define CDIMSTRING_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Class of a single string array dimension                           |
  //+------------------------------------------------------------------+
  class CDimString : public CArrayObj
   {
      private:
      //--- Create a new data object
         CDataUnitString  *CreateData(const string source,const string value="");
      //--- Get string data object from the array
         CDataUnitString  *GetData(const string source,const int index) const;
      //--- Add the specified number of cells with data to the end of the array
         bool              AddQuantity(const string source,const int total,const string value="");

      protected:

      public:
      //--- Initialize the array
         void              Initialize(const int total,const string value="");
      //--- Increase the number of data cells by the specified value, return the number of added elements
         int               Increase(const int total,const string value="");
      //--- Decrease the number of data cells by the specified value, return the number of removed elements. The very first element always remains
         int               Decrease(const int total);
      //--- Set a new array size
         bool              SetSize(const int size,const string initial_value="");
      //--- Set the value to the specified array cell
         bool              Set(const int index,const string value);
      //--- Return the amount of data (array size)
         int               Size(void) const { return this.Total(); }
      //--- Returns the value at the specified index
         string            Get(const int index) const;
         bool              Get(const int index, string &value) const;

      //--- Constructors
         CDimString(void);
         CDimString(const int total,const string value="");
      //--- Destructor
         ~CDimString(void);
   };
#endif // CDIMSTRING_MQH_DECLARATION
#ifndef CDIMSTRING_MQH_IMPLEMENTATION
#define CDIMSTRING_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Create a new data object                                         |
   //+------------------------------------------------------------------+
   CDataUnitString *CDimString::CreateData(const string source,const string value)
   {
      CDataUnitString *data=new CDataUnitString();
      if(data==NULL)
         ::Print(source,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_STRING_DATA_OBJ));
      else
         data.Value=value;
      return data;
   }
   //+------------------------------------------------------------------+
   //| Get string data object from the array                           |
   //+------------------------------------------------------------------+
   CDataUnitString *CDimString::GetData(const string source,const int index) const
   {
      CDataUnitString *data=this.At(index<0 ? 0 : index);
      if(data==NULL)
      {
         if(index>this.Total()-1)
            ::Print(source,CMessage::Text(MSG_LIB_SYS_REQUEST_OUTSIDE_STRING_ARRAY)," (",index,"/",this.Total(),")");
         else
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_GET_STRING_DATA_OBJ);
      }
      return data;
   }
   //+------------------------------------------------------------------+
   //| Add the specified number of cells with data to the end of array  |
   //+------------------------------------------------------------------+
   bool CDimString::AddQuantity(const string source,const int total,const string value)
   {
      bool res=true;
      for(int i=0;i<total;i++)
      {
         CDataUnitString *data=this.CreateData(DFUN,value);
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
   void CDimString::Initialize(const int total,const string value)
   {
      this.Clear();
      this.Increase(total,value);
   }
   //+------------------------------------------------------------------+
   //| Increase the number of data cells by the specified value         |
   //+------------------------------------------------------------------+
   int CDimString::Increase(const int total,const string value)
   {
      int size_prev=this.Total();
      this.AddQuantity(DFUN,total,value);
      return this.Total()-size_prev;
   }
   //+------------------------------------------------------------------+
   //| Decrease the number of data cells by the specified value         |
   //+------------------------------------------------------------------+
   int CDimString::Decrease(const int total)
   {
      if(total>this.Total()-1)
         return 0;
      int total_prev=this.Total();
      int from=this.Total()-total;
      int to=this.Total()-1;
      if(!this.DeleteRange(from,to))
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_DECREASE_STRING_ARRAY);
      return total_prev-this.Total();
   }
   //+------------------------------------------------------------------+
   //| Set a new array size                                             |
   //+------------------------------------------------------------------+
   bool CDimString::SetSize(const int size,const string initial_value)
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
   bool CDimString::Set(const int index,const string value)
   {
      CDataUnitString *data=this.GetData(DFUN,index);
      if(data==NULL)
         return false;
      data.Value=value;
      return true;
   }
   //+------------------------------------------------------------------+
   //| Returns the value at the specified index                         |
   //+------------------------------------------------------------------+
   string CDimString::Get(const int index) const
   {
      CDataUnitString *data=this.GetData(DFUN,index);
      return(data!=NULL ? data.Value : "");
   }
   //+------------------------------------------------------------------+
   //| Returns the value at the specified index by reference            |
   //+------------------------------------------------------------------+
   bool CDimString::Get(const int index, string &value) const
   {
      value="";
      CDataUnitString *data=this.GetData(DFUN,index);
      if(data==NULL)
         return false;
      value = data.Value;
      return true;
   }
   //+------------------------------------------------------------------+
   //| Constructors                                                     |
   //+------------------------------------------------------------------+
   CDimString::CDimString(void)
   {
      this.Initialize(1);
   }
   CDimString::CDimString(const int total,const string value)
   {
      this.Initialize(total,value);
   }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CDimString::~CDimString(void)
   {
      this.Clear();
      this.Shutdown();
   }
#endif // CDIMSTRING_MQH_IMPLEMENTATION
#endif // __DIMSTRING_MQH__
