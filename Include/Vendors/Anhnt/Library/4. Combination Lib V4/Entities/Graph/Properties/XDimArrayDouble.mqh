//+------------------------------------------------------------------+
//|                                XDimArrayDouble.mqh              |
//+------------------------------------------------------------------+
#ifndef __XDIMARRAYDOUBLE_MQH__
#define __XDIMARRAYDOUBLE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\..\Services\Message\Message.mqh"
 #include "DimDouble.mqh"
#ifndef CXDIMARRAYDOUBLE_MQH_DECLARATION
#define CXDIMARRAYDOUBLE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Dynamic multidimensional double array class                        |
  //+------------------------------------------------------------------+
  class CXDimArrayDouble : public CArrayObj
   {
      private:
      //--- Return the data array from the first dimensionality
      CDimDouble       *GetDim(const string source,const int index) const;
      //--- Add a new dimension to the first dimensionality
      bool              AddNewDim(const string source,const int size,const double initial_value=0);
      protected:

      public:
      //--- Increase the number of data cells by the specified 'total' value in the first dimensionality,
      //--- return the number of added elements to the dimensionality. Added cells' size is 'size'
      int               IncreaseRangeFirst(const int total,const int size,const double initial_value=0);
      //--- Increase the number of data cells by the specified 'total' value in the specified 'range' dimensionality,
      //--- return the number of added elements to the changed dimensionality
      int               IncreaseRange(const int range,const int total,const double initial_value=0);
      //--- Decrease the number of cells with data in the first dimensionality by the specified value,
      //--- return the number of removed elements. The very first element always remains
      int               DecreaseRangeFirst(const int total);
      //--- Decrease the number of data cells by the specified value in the specified dimensionality,
      //--- return the number of removed elements. The very first element always remains
      int               DecreaseRange(const int range,const int total);
      //--- Set the new array size in the specified dimensionality
      bool              SetSizeRange(const int range,const int size,const double initial_value=0);
      //--- Set the value to the specified array cell of the specified dimension
      bool              Set(const int index,const int range,const double value);
      //--- Return the value at the specified index of the specified dimension
      double            Get(const int index,const int range) const;
      bool              Get(const int index,const int range,double &value) const;
      //--- Return the amount of data (size of the specified dimension array)
      int               Size(const int range) const;
      //--- Return the total amount of data (the total size of all dimensions)
      int               Size(void) const;

      //--- Constructor
      CXDimArrayDouble();
      CXDimArrayDouble(int first_dim_size,const int dim_size,const double initial_value=0);
      //--- Destructor
      ~CXDimArrayDouble();
   };
#endif // CXDIMARRAYDOUBLE_MQH_DECLARATION
#ifndef CXDIMARRAYDOUBLE_MQH_IMPLEMENTATION
#define CXDIMARRAYDOUBLE_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Return the data array from the first dimensionality              |
   //+------------------------------------------------------------------+
   CDimDouble *CXDimArrayDouble::GetDim(const string source,const int index) const
   {
      CDimDouble *dim=this.At(index<0 ? 0 : index);
      if(dim==NULL)
      {
         if(index>this.Total()-1)
            ::Print(source,CMessage::Text(MSG_LIB_SYS_REQUEST_OUTSIDE_DOUBLE_ARRAY)," (",index,"/",this.Total(),")");
         else
            CMessage::ToLog(source,MSG_LIB_SYS_FAILED_GET_DOUBLE_DATA_OBJ);
      }
      return dim;
   }
   //+------------------------------------------------------------------+
   //| Add a new dimension to the first dimensionality                  |
   //+------------------------------------------------------------------+
   bool CXDimArrayDouble::AddNewDim(const string source,const int size,const double initial_value)
   {
      CDimDouble *dim=new CDimDouble(size,initial_value);
      if(dim==NULL)
      {
         CMessage::ToLog(source,MSG_LIB_SYS_FAILED_CREATE_DOUBLE_DATA_OBJ);
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
   int CXDimArrayDouble::IncreaseRangeFirst(const int total,const int size,const double initial_value)
   {
      int total_prev=this.Total();
      for(int i=0;i<total;i++)
         this.AddNewDim(DFUN,size,initial_value);
      return(this.Total()-total_prev);
   }
   //+------------------------------------------------------------------+
   //| Increase the number of data cells in the specified dimensionality|
   //+------------------------------------------------------------------+
   int CXDimArrayDouble::IncreaseRange(const int range,const int total,const double initial_value)
   {
      CDimDouble *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.Increase(total,initial_value) : 0);
   }
   //+------------------------------------------------------------------+
   //| Decrease the number of cells in the first dimensionality         |
   //+------------------------------------------------------------------+
   int CXDimArrayDouble::DecreaseRangeFirst(const int total)
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
   //| Decrease the number of data cells in the specified dimensionality|
   //+------------------------------------------------------------------+
   int CXDimArrayDouble::DecreaseRange(const int range,const int total)
   {
      CDimDouble *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.Decrease(total) : 0);
   }
   //+------------------------------------------------------------------+
   //| Set the new array size in the specified dimensionality           |
   //+------------------------------------------------------------------+
   bool CXDimArrayDouble::SetSizeRange(const int range,const int size,const double initial_value)
   {
      CDimDouble *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.SetSize(size,initial_value) : false);
   }
   //+------------------------------------------------------------------+
   //| Set the value to the specified array cell of the dimension       |
   //+------------------------------------------------------------------+
   bool CXDimArrayDouble::Set(const int index,const int range,const double value)
   {
      CDimDouble *dim=this.GetDim(DFUN,index);
      return(dim!=NULL ? dim.Set(range,value) : false);
   }
   //+------------------------------------------------------------------+
   //| Return the value at the specified index of the dimension         |
   //+------------------------------------------------------------------+
   double CXDimArrayDouble::Get(const int index,const int range) const
   {
      CDimDouble *dim=this.GetDim(DFUN,index);
      return(dim!=NULL ? dim.Get(range) : 0);
   }
   //+------------------------------------------------------------------+
   //| Return the value at the specified index of the dimension by ref  |
   //+------------------------------------------------------------------+
   bool CXDimArrayDouble::Get(const int index,const int range,double &value) const
   {
      CDimDouble *dim=this.GetDim(DFUN,index);
      return(dim!=NULL ? dim.Get(range,value) : false);
   }
   //+------------------------------------------------------------------+
   //| Return the amount of data (size of the specified dimension array)|
   //+------------------------------------------------------------------+
   int CXDimArrayDouble::Size(const int range) const
   {
      CDimDouble *dim=this.GetDim(DFUN,range);
      return(dim!=NULL ? dim.Size() : 0);
   }
   //+------------------------------------------------------------------+
   //| Return the total amount of data (the total size of all dimensions|
   //+------------------------------------------------------------------+
   int CXDimArrayDouble::Size(void) const
   {
      int size=0;
      for(int i=0;i<this.Total();i++)
      {
         CDimDouble *dim=this.GetDim(DFUN,i);
         if(dim==NULL)
            continue;
         size+=dim.Size();
      }
      return size;
   }
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CXDimArrayDouble::CXDimArrayDouble()
   {
      this.Clear();
      this.Add(new CDimDouble(1));
   }
   CXDimArrayDouble::CXDimArrayDouble(int first_dim_size,const int dim_size,const double initial_value)
   {
      this.Clear();
      int total=(first_dim_size<1 ? 1 : first_dim_size);
      for(int i=0;i<total;i++)
         this.Add(new CDimDouble(dim_size,initial_value));
   }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CXDimArrayDouble::~CXDimArrayDouble()
   {
      this.Clear();
      this.Shutdown();
   }
#endif // CXDIMARRAYDOUBLE_MQH_IMPLEMENTATION
#endif // __XDIMARRAYDOUBLE_MQH__
