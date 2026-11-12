//+------------------------------------------------------------------+
//|                                XDimArrayString.mqh              |
//+------------------------------------------------------------------+
#ifndef __XDIMARRAYSTRING_MQH__
#define __XDIMARRAYSTRING_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\..\Services\Message\Message.mqh"
 #include "DimString.mqh"
#ifndef CXDIMARRAYSTRING_MQH_DECLARATION
#define CXDIMARRAYSTRING_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Dynamic multidimensional string array class                        |
  //+------------------------------------------------------------------+
  class CXDimArrayString : public CArrayObj
   {
      private:
      //--- Return the data array from the first dimensionality
      CDimString       *GetDim(const string source,const int index) const;
      //--- Add a new dimension to the first dimensionality
      bool              AddNewDim(const string source,const int size,const string initial_value="");

      protected:

      public:
      //--- Increase the number of data cells by the specified 'total' value in the first dimensionality,
      //--- return the number of added elements to the dimensionality. Added cells' size is 'size'
      int               IncreaseRangeFirst(const int total,const int size,const string initial_value="");
      //--- Increase the number of data cells by the specified 'total' value in the specified 'range' dimensionality,
      //--- return the number of added elements to the changed dimensionality
      int               IncreaseRange(const int range,const int total,const string initial_value="");
      //--- Decrease the number of cells with data in the first dimensionality by the specified value,
      //--- return the number of removed elements. The very first element always remains
      int               DecreaseRangeFirst(const int total);
      //--- Decrease the number of data cells by the specified value in the specified dimensionality,
      //--- return the number of removed elements. The very first element always remains
      int               DecreaseRange(const int range,const int total);
      //--- Set the new array size in the specified dimensionality
      bool              SetSizeRange(const int range,const int size,const string initial_value="");
      //--- Set the value to the specified array cell of the specified dimension
      bool              Set(const int index,const int range,const string value);
      //--- Return the value at the specified index of the specified dimension
      string            Get(const int index,const int range) const;
      bool              Get(const int index,const int range,string &value) const;
      //--- Return the amount of data (size of the specified dimension array)
      int               Size(const int range) const;
      //--- Return the total amount of data (the total size of all dimensions)
      int               Size(void) const;

      //--- Constructor
      CXDimArrayString();
      CXDimArrayString(int first_dim_size,const int dim_size,const string initial_value="");
      //--- Destructor
      ~CXDimArrayString();
   };
#endif // CXDIMARRAYSTRING_MQH_DECLARATION
#ifndef CXDIMARRAYSTRING_MQH_IMPLEMENTATION
#define CXDIMARRAYSTRING_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Return the data array from the first dimensionality              |
   //+------------------------------------------------------------------+
   CDimString *CXDimArrayString::GetDim(const string source,const int index) const
   {
      CDimString *dim=this.At(index<0 ? 0 : index);
      if(dim==NULL)
      {
         if(index>this.Total()-1)
            ::Print(source,CMessage::Text(MSG_LIB_SYS_REQUEST_OUTSIDE_STRING_ARRAY)," (",index,"/",this.Total(),")");
         else
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_GET_STRING_DATA_OBJ);
      }
      return dim;
   }
   //+------------------------------------------------------------------+
   //| Add a new dimension to the first dimensionality                  |
   //+------------------------------------------------------------------+
   bool CXDimArrayString::AddNewDim(const string source,const int size,const string initial_value)
   {
      CDimString *dim=new CDimString(size,initial_value);
      if(dim==NULL)
      {
         CMessage::ToLog(source,MSG_LIB_SYS_FAILED_CREATE_STRING_DATA_OBJ);
         return false;
      }
      if(!this.Add(dim))
      {
         delete dim;
         CMessage::ToLog(source,MSG_LIB_SYS_FAILED_OBJ_ADD_TO_LIST);
         return false;
      }
      return true;
   }
   //+------------------------------------------------------------------+
   //| Increase the number of data cells in the first dimensionality    |
   //+------------------------------------------------------------------+
   int CXDimArrayString::IncreaseRangeFirst(const int total,const int size,const string initial_value)
   {
      int total_prev=this.Total();
      for(int i=0;i<total;i++)
         this.AddNewDim(DFUN,size,initial_value);
      return(this.Total()-total_prev);
   }
   //+------------------------------------------------------------------+
   //| Increase the number of data cells in the specified dimensionality|
   //+------------------------------------------------------------------+
   int CXDimArrayString::IncreaseRange(const int range,const int total,const string initial_value)
   {
      CDimString *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.Increase(total,initial_value) : 0);
   }
   //+------------------------------------------------------------------+
   //| Decrease the number of cells in the first dimensionality         |
   //+------------------------------------------------------------------+
   int CXDimArrayString::DecreaseRangeFirst(const int total)
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
   //| Decrease the number of data cells in the specified dimensionality|
   //+------------------------------------------------------------------+
   int CXDimArrayString::DecreaseRange(const int range,const int total)
   {
      CDimString *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.Decrease(total) : 0);
   }
   //+------------------------------------------------------------------+
   //| Set the new array size in the specified dimensionality           |
   //+------------------------------------------------------------------+
   bool CXDimArrayString::SetSizeRange(const int range,const int size,const string initial_value)
   {
      CDimString *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.SetSize(size,initial_value) : false);
   }
   //+------------------------------------------------------------------+
   //| Set the value to the specified array cell of the dimension       |
   //+------------------------------------------------------------------+
   bool CXDimArrayString::Set(const int index,const int range,const string value)
   {
      CDimString *dim=this.GetDim(DFUN,index);
      return(dim!=NULL ? dim.Set(range,value) : false);
   }
   //+------------------------------------------------------------------+
   //| Return the value at the specified index of the dimension         |
   //+------------------------------------------------------------------+
   string CXDimArrayString::Get(const int index,const int range) const
   {
      CDimString *dim=this.GetDim(DFUN,index);
      return(dim!=NULL ? dim.Get(range) : "");
   }
   //+------------------------------------------------------------------+
   //| Return the value at the specified index of the dimension by ref  |
   //+------------------------------------------------------------------+
   bool CXDimArrayString::Get(const int index,const int range,string &value) const
   {
      CDimString *dim=this.GetDim(DFUN,index);
      return(dim!=NULL ? dim.Get(range,value) : false);
   }
   //+------------------------------------------------------------------+
   //| Return the amount of data (size of the specified dimension array)|
   //+------------------------------------------------------------------+
   int CXDimArrayString::Size(const int range) const
   {
      CDimString *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.Size() : 0);
   }
   //+------------------------------------------------------------------+
   //| Return the total amount of data (the total size of all dimensions|
   //+------------------------------------------------------------------+
   int CXDimArrayString::Size(void) const
   {
      int size=0;
      for(int i=0;i<this.Total();i++)
      {
         CDimString *dim=this.GetDim(DFUN,i);
         if(dim==NULL)
            continue;
         size+=dim.Size();
      }
      return size;
   }
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CXDimArrayString::CXDimArrayString()
   {
      this.Clear();
      this.Add(new CDimString(1));
   }
   CXDimArrayString::CXDimArrayString(int first_dim_size,const int dim_size,const string initial_value)
   {
      this.Clear();
      int total=(first_dim_size<1 ? 1 : first_dim_size);
      for(int i=0;i<total;i++)
         this.Add(new CDimString(dim_size,initial_value));
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CXDimArrayString::~CXDimArrayString()
   {
      this.Clear();
      this.Shutdown();
   }
#endif // CXDIMARRAYSTRING_MQH_IMPLEMENTATION
#endif // __XDIMARRAYSTRING_MQH__
