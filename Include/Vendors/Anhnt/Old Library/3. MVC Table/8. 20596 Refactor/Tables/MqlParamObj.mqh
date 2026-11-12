//+------------------------------------------------------------------+
//|                                                MqlParamObj.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Structure parameter object class |
//+------------------------------------------------------------------+	
#ifndef __MQLPARAMOBJ_MQH__
#define __MQLPARAMOBJ_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Object.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+   
class CMqlParamObj : public CObject
 {
   protected:
   public:
      MqlParam          m_param;
   // --- Setting parameters
      void              Set(const MqlParam &param)
                        {
                           this.m_param.type=param.type;
                           this.m_param.double_value=param.double_value;
                           this.m_param.integer_value=param.integer_value;
                           this.m_param.string_value=param.string_value;
                        }
   // --- Return parameters
      MqlParam          Param(void)       const { return this.m_param;              }
      ENUM_DATATYPE     Datatype(void)    const { return this.m_param.type;         }
      double            ValueD(void)      const { return this.m_param.double_value; }
      long              ValueL(void)      const { return this.m_param.integer_value;}
      string            ValueS(void)      const { return this.m_param.string_value; }
   // ---Object description
      virtual string    Description(void)
                        {
                           string t=::StringSubstr(::EnumToString(this.m_param.type),5);
                           t.Lower();
                           string v="";
                           switch(this.m_param.type)
                           {
                              case TYPE_STRING  :  v=this.ValueS();                                                     break;
                              case TYPE_FLOAT   :  case TYPE_DOUBLE : v=::DoubleToString(this.ValueD());                break;
                              case TYPE_DATETIME:  v=::TimeToString(this.ValueL(),TIME_DATE|TIME_MINUTES|TIME_SECONDS); break;
                              default           :  v=(string)this.ValueL();                                             break;
                           }
                           return(::StringFormat("<%s>%s",t,v));
                        }
      
   // --- Constructors/destructor
                        CMqlParamObj(void){}
                        CMqlParamObj(const MqlParam &param) { this.Set(param);  }
                        ~CMqlParamObj(void){}
 };
//+------------------------------------------------------------------+
#endif // __MQLPARAMOBJ_MQH__


