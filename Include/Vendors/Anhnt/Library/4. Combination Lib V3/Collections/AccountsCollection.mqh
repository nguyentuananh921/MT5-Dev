//+------------------------------------------------------------------+
//|                                           AccountsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
#ifndef __ACCOUNTSCOLLECTION_MQH__
#define __ACCOUNTSCOLLECTION_MQH__
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "ListObj.mqh"
  #include "..\Entities\Trading\Account.mqh"
  #ifndef CACCOUNTSCOLLECTION_MQH_DECLARATION
  #define CACCOUNTSCOLLECTION_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Account collection                                               |
  //+------------------------------------------------------------------+
  class CAccountsCollection : public CBaseObjExt
   {
    private:   
       string            m_symbol;                                    // Current symbol
       CListObj          m_list_accounts;                             // Account object list
       int               m_index_current;                             // Index of an account object featuring the current account data
       int               m_last_event;                                // The last event
      //--- Check the account object presence in the collection list
       bool              IsPresent(CAccount* account);
      //--- Find and return the account object index with the current account data
       int               Index(void);
    public:
      //--- Return the full account collection list "as is"
       CArrayObj        *GetList(void)                                                                          { return &this.m_list_accounts;}
      //--- Return (1) the current account object index and (2) event ID by its number in the list
       int               IndexCurrentAccount(void)                                                        const { return this.m_index_current;}
       CAccount          *GetCurrentAccount(void)                                                        { int idx = this.IndexCurrentAccount(); return (idx == WRONG_VALUE) ? NULL : (CAccount*)this.GetList().At(idx); }
       int               GetEventID(const int shift=WRONG_VALUE,const bool check_out=true);
      //--- (1) Set and (2) return the current symbol
       void              SetSymbol(const string symbol)                                                         { this.m_symbol=symbol;}
       string            GetSymbol(void)                                                                  const { return this.m_symbol;}
      //--- (1) Update data, (2) working with events of the current account
       virtual void      Refresh(void);
       void              RefreshAndEventsControl(void);
      //--- Constructor, destructor
          CAccountsCollection();
          ~CAccountsCollection();
      //--- Add the account object to the list
       bool              AddToList(CAccount* account);
      //--- (1) Save account objects from the list to the files
      //--- (2) Save account objects from the files to the list
       bool              SaveObjects(void);
       bool              LoadObjects(void);

   };
  #endif // CACCOUNTSCOLLECTION_MQH_DECLARATION
  #ifndef CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
  #define CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CAccountsCollection::CAccountsCollection(void) : m_symbol(::Symbol())
    {
      this.m_type=COLLECTION_ACCOUNT_ID;
      this.m_list_accounts.Clear();
      this.m_list_accounts.Sort(SORT_BY_ACCOUNT_LOGIN);
      //https://www.mql5.com/en/articles/6211
      //--- Collection list IDs COLLECTION_ACCOUNT_ID in CommonDefines.mqh
       this.m_list_accounts.Type(COLLECTION_ACCOUNT_ID);
      ::ZeroMemory(this.m_tick);
      //--- Create the folder for storing account files
      this.SetSubFolderName("Accounts");
      ::ResetLastError();
      if(!::FolderCreate(this.m_folder_name,FILE_COMMON))
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_STORAGE_FOLDER),::GetLastError());
      //--- Create the current account object and add it to the list
      CAccount* account=new CAccount();
      if(account!=NULL)
       {
        if(!this.AddToList(account))
          {
           ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_ACC_OBJ_TO_LIST));
           delete account;
          }
        else
           account.PrintShort();
       }
      else
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_CURR_ACC_OBJ));

      //--- Download account objects from the files to the collection
      this.LoadObjects();
      //--- Save the current account index
      this.m_index_current=this.Index();
    }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CAccountsCollection::~CAccountsCollection(void)
    {
      //--- Save account objects from the list to the files
      this.SaveObjects();
    }
   //+------------------------------------------------------------------+
   //| Add the account object to the list                               |
   //+------------------------------------------------------------------+
   bool CAccountsCollection::AddToList(CAccount *account)
    {
     if(account==NULL)
      return false;
     if(!this.IsPresent(account))
      return this.m_list_accounts.Add(account);
     return false;
    }
   //+------------------------------------------------------------------+
   //| Check the account object presence in the collection list         |
   //+------------------------------------------------------------------+
   bool CAccountsCollection::IsPresent(CAccount *account)
    {
      int total=this.m_list_accounts.Total();
      if(total==0)
         return false;
      for(int i=0;i<total;i++)
        {
         CAccount* check=this.m_list_accounts.At(i);
         if(check==NULL)
            continue;
         if(check.IsEqual(account))
            return true;
        }
      return false;
    }
   //+------------------------------------------------------------------+
   //| Return the account object index with the current account data    |
   //+------------------------------------------------------------------+
   int CAccountsCollection::Index(void)
    {
      int total=this.m_list_accounts.Total();
      if(total==0)
         return WRONG_VALUE;
      for(int i=0;i<total;i++)
        {
         CAccount* account=this.m_list_accounts.At(i);
         if(account==NULL)
            continue;
         if(account.Login()==::AccountInfoInteger(ACCOUNT_LOGIN)    &&
            account.Company()==::AccountInfoString(ACCOUNT_COMPANY) &&
            account.Name()==::AccountInfoString(ACCOUNT_NAME)  
           ) return i;
        }
      return WRONG_VALUE;
    }
   //+------------------------------------------------------------------+
   //| Save account objects from the list to the files                  |
   //+------------------------------------------------------------------+
   bool CAccountsCollection::SaveObjects(void)
    {
      bool res=true;
      int total=this.m_list_accounts.Total();
      if(total==0)
         return false;
      for(int i=0;i<total;i++)
        {
         CAccount* account=this.m_list_accounts.At(i);
         if(account==NULL)
            continue;
         string file_name=this.m_folder_name+"\\"+account.Server()+" "+(string)account.Login()+".bin";
         if(::FileIsExist(file_name,FILE_COMMON))
            ::FileDelete(file_name,FILE_COMMON);
         ::ResetLastError();
         int handle=::FileOpen(file_name,FILE_WRITE|FILE_BIN|FILE_COMMON);
         if(handle==INVALID_HANDLE)
           {
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_OPEN_FILE_FOR_WRITE),file_name,". ",CMessage::Text(MSG_LIB_SYS_ERROR),(string)::GetLastError());
            return false;
           }
            res &=account.Save(handle);
         ::FileClose(handle);
        }
      return res;
    }
   //+------------------------------------------------------------------+
   //| Save account objects from the files to the list                  |
   //+------------------------------------------------------------------+
   bool CAccountsCollection::LoadObjects(void)
    {
     bool res=true;
     string name="";
     long handle_search=::FileFindFirst(this.m_folder_name+"\\*",name,FILE_COMMON);
     if(handle_search!=INVALID_HANDLE)
      {
        do
        {
         string file_name=this.m_folder_name+"\\"+name;
         ::ResetLastError();
         int handle_file=::FileOpen(m_folder_name+"\\"+name,FILE_BIN|FILE_READ|FILE_COMMON);
         if(handle_file!=INVALID_HANDLE)
           {
            CAccount* account=new CAccount();
            if(account!=NULL)
              {
               if(!account.Load(handle_file))
                 {
                  delete account;
                  ::FileClose(handle_file);
                  res &=false;
                  continue;
                 }
               if(this.IsPresent(account))
                 {
                  delete account;
                  ::FileClose(handle_file);
                  res &=false;
                  continue;
                 }
               if(!this.AddToList(account))
                 {
                  delete account;
                  res &=false;
                 }
              }
           }
         ::FileClose(handle_file);
        }
        while(::FileFindNext(handle_search,name));
        ::FileFindClose(handle_search);
      }
     return res;
    }
   //+------------------------------------------------------------------+
   //| Update the current account data                                  |
   //+------------------------------------------------------------------+
   void CAccountsCollection::Refresh(void)
    {
     ::ResetLastError();
     if(!::SymbolInfoTick(::Symbol(),this.m_tick))
      {
       this.m_global_error=::GetLastError();
       return;
      }
     if(this.m_index_current==WRONG_VALUE)
      return;
     CAccount* account=this.m_list_accounts.At(this.m_index_current);
     if(account==NULL)
      return;
     account.Refresh();
    }
   //+------------------------------------------------------------------+
   //| Working with the current account events                          |
   //+------------------------------------------------------------------+
   void CAccountsCollection::RefreshAndEventsControl(void)
    {
     ::ResetLastError();
     if(!::SymbolInfoTick(::Symbol(),this.m_tick))
      {
       this.m_global_error=::GetLastError();
       return;
      }
     if(this.m_index_current==WRONG_VALUE)
      return;
     this.m_is_event=false;
     this.m_list_events.Clear();
     this.m_list_events.Sort();
     CAccount* account=this.m_list_accounts.At(this.m_index_current);
     if(account==NULL)
      return;
     account.Refresh();
     if(!account.IsEvent())
      return;
     CArrayObj *list=account.GetListEvents();
     if(list==NULL)
      return;
     this.m_is_event=true;
     this.m_event_code=account.GetEventCode();
     int n=list.Total();
     for(int j=0; j<n; j++)
      {
       CEventBaseObj *event=list.At(j);
       if(event==NULL)
          continue;
       this.m_last_event=event.ID();
       if(this.EventAdd((ushort)event.ID(),event.LParam(),event.DParam(),event.SParam()))
         {
          ::EventChartCustom(::ChartID(),(ushort)event.ID(),event.LParam(),event.DParam(),event.SParam());
         }
      }
    }
   //+------------------------------------------------------------------+
   //| Return the account event by its number in the list               |
   //+------------------------------------------------------------------+
   int CAccountsCollection::GetEventID(const int shift=WRONG_VALUE,const bool check_out=true)
    {
     CEventBaseObj *event=this.GetEvent(shift,check_out);
     if(event==NULL)
      return WRONG_VALUE;
     return (int)event.ID();
    }
   //+------------------------------------------------------------------+
 #endif // CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
#endif // __ACCOUNTSCOLLECTION_MQH__
