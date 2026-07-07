//+------------------------------------------------------------------+
//|                                               GraphSelect.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
//+------------------------------------------------------------------+
//| Class for selecting canvas graphic elements from a list          |
//+------------------------------------------------------------------+
#ifndef CGRAPHSELECT_MQH
#define CGRAPHSELECT_MQH
 #include "CommonSelect.mqh"
 #include "..\..\Graph\GCnvElement.mqh"
 #include "..\..\Graph\Standard\GStdGraphObj.mqh"
#ifndef CGRAPHSELECT_MQH_DECLARATION
#define CGRAPHSELECT_MQH_DECLARATION
 class CGraphSelect : public CCommonSelect
  {
   public:
   //+---------------------------------------------------------------------------+
   //| The methods of working with data of the graphical elements on the canvas  |
   //+---------------------------------------------------------------------------+
   //--- Return the list of objects with one of (1) integer, (2) real and (3) string properties meeting a specified criterion
    static CArrayObj *ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
    static CArrayObj *ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
    static CArrayObj *ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Return the graphical element index in the list with the maximum value of the (1) integer, (2) real and (3) string properties
    static int        FindGraphCanvElementMax(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property);
    static int        FindGraphCanvElementMax(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property);
    static int        FindGraphCanvElementMax(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property);
   //--- Return the graphical element index in the list with the minimum value of the (1) integer, (2) real and (3) string properties
    static int        FindGraphCanvElementMin(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property);
    static int        FindGraphCanvElementMin(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property);
    static int        FindGraphCanvElementMin(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property);
   //+------------------------------------------------------------------+
   //| Methods of working with standard graphical object data           |
   //+------------------------------------------------------------------+
   //--- Return the list of objects with one of (1) integer, (2) real and (3) string properties meeting a specified criterion
    static CArrayObj *ByGraphicStdObjectProperty(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_INTEGER property,int index,long value,ENUM_COMPARER_TYPE mode);
    static CArrayObj *ByGraphicStdObjectProperty(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index,double value,ENUM_COMPARER_TYPE mode);
    static CArrayObj *ByGraphicStdObjectProperty(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_STRING property,int index,string value,ENUM_COMPARER_TYPE mode);
   //--- Return the graphical object index in the list with the maximum value of the (1) integer, (2) real and (3) string properties
    static int        FindGraphicStdObjectMax(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_INTEGER property,int index);
    static int        FindGraphicStdObjectMax(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index);
    static int        FindGraphicStdObjectMax(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_STRING property,int index);
   //--- Return the graphical object index in the list with the minimum value of the (1) integer, (2) real and (3) string properties
    static int        FindGraphicStdObjectMin(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_INTEGER property,int index);
    static int        FindGraphicStdObjectMin(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index);
    static int        FindGraphicStdObjectMin(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_STRING property,int index);
  };
#endif // CGRAPHSELECT_MQH_DECLARATION
#ifndef CGRAPHSELECT_MQH_IMPLEMENTATION
#define CGRAPHSELECT_MQH_IMPLEMENTATION

//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
//| The methods of working with data of the graphical elements on the canvas  |
//+---------------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return the list of objects with one integer                      |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CGraphSelect::ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   int total=list_source.Total();
   for(int i=0; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      long obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of objects with one real                         |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CGraphSelect::ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CGCnvElement *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      double obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of objects with one string                       |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CGraphSelect::ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CGCnvElement *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      string obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the maximum integer property value                          |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphCanvElementMax(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CGCnvElement *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      long obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the maximum real property value                             |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphCanvElementMax(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CGCnvElement *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      double obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the maximum string property value                           |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphCanvElementMax(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CGCnvElement *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      string obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the minimum integer property value                          |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphCanvElementMin(CArrayObj* list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property)
  {
   int index=0;
   CGCnvElement *min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      long obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the minimum real property value                             |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphCanvElementMin(CArrayObj* list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property)
  {
   int index=0;
   CGCnvElement *min_obj=NULL;
   int total=list_source.Total();
   if(total== 0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      double obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the minimum string property value                           |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphCanvElementMin(CArrayObj* list_source,ENUM_CANV_ELEMENT_PROP_STRING property)
  {
   int index=0;
   CGCnvElement *min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      string obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
//| The methods of working with data of the graphical elements on the canvas  |
//+---------------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return the list of objects with one integer                      |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CGraphSelect::ByGraphicStdObjectProperty(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_INTEGER property,int index,long value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   int total=list_source.Total();
   for(int i=0; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      long obj_prop=obj.GetProperty(property,index);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of objects with one real                         |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CGraphSelect::ByGraphicStdObjectProperty(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index,double value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      double obj_prop=obj.GetProperty(property,index);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of objects with one string                       |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CGraphSelect::ByGraphicStdObjectProperty(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_STRING property,int index,string value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      string obj_prop=obj.GetProperty(property,index);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the maximum integer property value                          |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphicStdObjectMax(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_INTEGER property,int index)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int idx=0;
   CGStdGraphObj *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property,index);
      max_obj=list_source.At(idx);
      long obj2_prop=max_obj.GetProperty(property,index);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) idx=i;
     }
   return idx;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the maximum real property value                             |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphicStdObjectMax(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int idx=0;
   CGStdGraphObj *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property,index);
      max_obj=list_source.At(idx);
      double obj2_prop=max_obj.GetProperty(property,index);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) idx=i;
     }
   return idx;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the maximum string property value                           |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphicStdObjectMax(CArrayObj *list_source,ENUM_GRAPH_OBJ_PROP_STRING property,int index)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int idx=0;
   CGStdGraphObj *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property,index);
      max_obj=list_source.At(idx);
      string obj2_prop=max_obj.GetProperty(property,index);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) idx=i;
     }
   return idx;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the minimum integer property value                          |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphicStdObjectMin(CArrayObj* list_source,ENUM_GRAPH_OBJ_PROP_INTEGER property,int index)
  {
   int idx=0;
   CGStdGraphObj *min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property,index);
      min_obj=list_source.At(idx);
      long obj2_prop=min_obj.GetProperty(property,index);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) idx=i;
     }
   return idx;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the minimum real property value                             |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphicStdObjectMin(CArrayObj* list_source,ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index)
  {
   int idx=0;
   CGStdGraphObj *min_obj=NULL;
   int total=list_source.Total();
   if(total== 0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property,index);
      min_obj=list_source.At(idx);
      double obj2_prop=min_obj.GetProperty(property,index);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) idx=i;
     }
   return idx;
  }
//+------------------------------------------------------------------+
//| Return the object index in the list                              |
//| with the minimum string property value                           |
//+------------------------------------------------------------------+
int CGraphSelect::FindGraphicStdObjectMin(CArrayObj* list_source,ENUM_GRAPH_OBJ_PROP_STRING property,int index)
  {
   int idx=0;
   CGStdGraphObj *min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CGStdGraphObj *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property,index);
      min_obj=list_source.At(idx);
      string obj2_prop=min_obj.GetProperty(property,index);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) idx=i;
     }
   return idx;
  }
//+------------------------------------------------------------------+
#endif // CGRAPHSELECT_MQH_IMPLEMENTATION
#endif // CGRAPHSELECT_MQH
