//+------------------------------------------------------------------+
//|                                                 JSONConfig.mqh   |
//+------------------------------------------------------------------+

#ifndef JSONCONFIG_MQH
#define JSONCONFIG_MQH
 #define CONFIG_SETTING_FILE  "/Configuration/Config_Setting.json"   // under MQL5\Files\<program name>: every manager reads and writes its own key of this file
 //--- reads MQL5\Files\<filename> as plain text, "" if missing - shared by every writer that
 //--- needs to read the file back before rewriting it (to preserve sections it doesn't own).
 string JSONConfig_ReadWholeFile(const string &filename)
  {
   int fh = FileOpen(filename, FILE_READ | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);   // another EA may have it open: wait for nobody, read it
   if(fh == INVALID_HANDLE) return "";
   string text = "";
    while(!FileIsEnding(fh))
       text += FileReadString(fh) + "\n";
    FileClose(fh);
    return text;
  }
 //--- extracts the raw (unparsed) text of a top-level key's value from previously-read JSON
 //--- content, "" if the key isn't present - lets a writer that only understands SOME of the
 //--- top-level keys (e.g. CTimeSeriesEngine only knows "symbols_tf"/"templates", GUIPannel's
 //--- marker settings only know "markers") carry the OTHER keys through unchanged when it
 //--- rewrites the shared Config_Setting.json file, instead of clobbering them.
 string JSONConfig_ExtractRawSection(const string &content, const string key)
  {
   int pos = StringFind(content, "\"" + key + "\"");
   if(pos < 0) return "";
   int colon = StringFind(content, ":", pos);
   if(colon < 0) return "";
   int start = JSONConfig_SkipSpace(content, colon + 1);
   int end   = JSONConfig_SkipValue(content, start);
   return StringSubstr(content, start, end - start);
  }
 //--- Extract quoted string value from JSON key - unescapes backslashes
 bool JSONConfig_StringValue(const string content, const string key, string &value)
  {
   int pos = StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = StringFind(content, ":", pos);
    if(colon < 0) return false;
    int q1 = StringFind(content, "\"", colon + 1);
    if(q1 < 0) return false;
    int q2 = StringFind(content, "\"", q1 + 1);
    if(q2 < 0) return false;
    value = StringSubstr(content, q1 + 1, q2 - q1 - 1);
    StringReplace(value, "\\\\", "\\");
    return true;
  } 
 //--- Extract a bare true/false value from JSON key, false (unchanged `value`) if the key is absent
 bool JSONConfig_BoolValue(const string &content, const string key, bool &value)
  {
   int pos = StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = StringFind(content, ":", pos);
   if(colon < 0) return false;
   int start = JSONConfig_SkipSpace(content, colon + 1);
   if(StringSubstr(content, start, 4) == "true")  { value = true;  return true; }
   if(StringSubstr(content, start, 5) == "false") { value = false; return true; }
   return false;
  }
 //--- Extract a bare integer value from JSON key
 bool JSONConfig_IntValue(const string &content, const string key, int &value)
  {
   int pos = StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = StringFind(content, ":", pos);
   if(colon < 0) return false;
   int start = JSONConfig_SkipSpace(content, colon + 1);
   string raw;
   if(JSONConfig_ReadRawNumber(content, start, raw) == start) return false;
   value = (int)StringToInteger(raw);
   return true;
  }
 //--- Extract a bare number value from JSON key
 bool JSONConfig_DoubleValue(const string &content, const string key, double &value)
  {
   int pos = StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = StringFind(content, ":", pos);
   if(colon < 0) return false;
   int start = JSONConfig_SkipSpace(content, colon + 1);
   string raw;
   if(JSONConfig_ReadRawNumber(content, start, raw) == start) return false;
   value = StringToDouble(raw);
   return true;
  }
 //--- strip "//" line comments before scanning
 string JSONConfig_StripComments(const string &raw)
  {
     string lines[];
     int n = StringSplit(raw, '\n', lines);
     string result = "";
     for(int i = 0; i < n; i++)
       {
        string line = lines[i];
        int pos = StringFind(line, "//");
        if(pos >= 0)
           line = StringSubstr(line, 0, pos);
        result += line + "\n";
       }
     return result;
  }
 //--- skip whitespace/commas/colons starting at pos
 int JSONConfig_SkipSpace(const string &s, int pos)
   {
     int len = StringLen(s);
     while(pos < len)
       {
        ushort c = StringGetCharacter(s, pos);
        if(c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == ',')
           pos++;
        else
           break;
       }
     return pos;
    }
 //--- skips ANY JSON value (object/array/string/number/true/false/null) starting at pos,
 //--- returning pos right after it - used for top-level keys this loader doesn't itself
 //--- understand (e.g. "markers", written by CGUIPannel::SaveMarkerSettings into the same
 //--- Config_Setting.json file) so an unrecognized key doesn't desync the whole parse.
 int JSONConfig_SkipValue(const string &s, int pos)
  {
   int len = StringLen(s);
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= len) return pos;
   ushort ch = StringGetCharacter(s, pos);
   if(ch == '{' || ch == '[')
     {
      ushort open_ch  = ch;
      ushort close_ch = (ch == '{') ? '}' : ']';
      int depth = 0;
      bool in_string = false;
      for(; pos < len; pos++)
       {
        ushort c = StringGetCharacter(s, pos);
        if(in_string)
         {
          if(c == '\\') { pos++; continue; } // skip escaped char, whatever it is
          if(c == '"') in_string = false;
          continue;
         }
        if(c == '"') { in_string = true; continue; }
        if(c == open_ch) depth++;
        else if(c == close_ch)
        {
         depth--;
         if(depth == 0) { pos++; break; }
        }
       }
      return pos;
     }
   if(ch == '"')
    {
     string dummy;
     return JSONConfig_ReadString(s, pos, dummy);
    }
   // --- bare literal (number/true/false/null) - scan to the next delimiter
    while(pos < len)
     {
      ushort c = StringGetCharacter(s, pos);
      if(c == ',' || c == '}' || c == ']') break;
      pos++;
     }
    return pos;
   }
 //--- read a "quoted string" starting at the opening quote, return pos after closing quote
 int JSONConfig_ReadString(const string &s, int pos, string &out)
  {
     out = "";
     int len = StringLen(s);
     if(pos >= len || StringGetCharacter(s, pos) != '"')
       return pos;
     pos++; // skip opening quote
     while(pos < len)
       {
        ushort c = StringGetCharacter(s, pos);
        if(c == '"')
          {
           pos++;
           break;
          }
        if(c == '\\' && pos + 1 < len)
          {
           pos++;
           c = StringGetCharacter(s, pos);
          }
        out += ShortToString(c);
        pos++;
       }
     return pos;
   }
 //--- read a bare number (as raw text) starting at pos, return pos after the number - shared by
 //--- IndicatorTemplateManager.mqh and RiskManagementSettingManager.mqh, both need it.
 int JSONConfig_ReadRawNumber(const string &s, int pos, string &out)
  {
   int len = StringLen(s);
   int start = pos;
   while(pos < len)
    {
     ushort c = StringGetCharacter(s, pos);
     if((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E')
        pos++;
     else
        break;
    }
   out = StringSubstr(s, start, pos - start);
   return pos;
  }
 //--- read a bare true/false literal starting at pos, return pos after it
 int IndicatorConfig_ReadBool(const string &s, int pos, bool &out)
  {
     out = false;
     if(StringSubstr(s, pos, 4) == "true")
       {
        out = true;
        return pos + 4;
       }
     if(StringSubstr(s, pos, 5) == "false")
       return pos + 5;
     return pos;
   }
 //--- Makes the folders of a path (MQL5\Files\<path>), one level after the other, so that a file can be written there; nothing happens to the ones that exist
 void JSONConfig_MakeFolders(const string path)
  {
   for(int i = 0; i < StringLen(path); i++)
     {
      ushort c = StringGetCharacter(path, i);
      if(i > 0 && (c == '/' || c == '\\'))
         FolderCreate(StringSubstr(path, 0, i));
     }
  }
 //--- Writes the value of one top-level key into the shared file and leaves every other key as it is: the key is replaced
 //--- in place when the file has it, added at the end otherwise (the file is created when it is missing)
 bool JSONConfig_SaveSection(const string full_path, const string key, const string value)
  {
   string content = JSONConfig_ReadWholeFile(full_path);
   //--- The file is there but could not be read (another program has it): nothing is written, or every other key would be lost
   if(content == "" && FileIsExist(full_path))
     {
      Print(__FUNCTION__, " > ", full_path, " exists but cannot be read now, \"", key, "\" is not saved");
      return false;
     }
   string result;
   int pos = StringFind(content, "\"" + key + "\"");
   int colon = (pos >= 0 ? StringFind(content, ":", pos) : -1);
   if(colon >= 0)
     {
      int start = JSONConfig_SkipSpace(content, colon + 1);
      int end   = JSONConfig_SkipValue(content, start);
      result = StringSubstr(content, 0, start) + value + StringSubstr(content, end);
     }
   else
     {
      int last = -1;
      for(int i = StringLen(content) - 1; i >= 0 && last < 0; i--)
         if(StringGetCharacter(content, i) == '}')
            last = i;
      if(last < 0)
         result = "{\n \"" + key + "\": " + value + "\n}\n";
      else
        {
         string head = StringSubstr(content, 0, last);
         StringTrimRight(head);
         bool empty = (StringGetCharacter(head, StringLen(head) - 1) == '{');
         result = head + (empty ? "\n" : ",\n") + " \"" + key + "\": " + value + "\n}\n";
        }
     }
   if(content != "")
      FileCopy(full_path, 0, full_path + ".bak", FILE_REWRITE);   // the file as it was, one step back
   JSONConfig_MakeFolders(full_path);   // the folder of an account is made the first time it is written
   int fh = FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI | FILE_SHARE_READ);
   if(fh == INVALID_HANDLE)
      return false;
   FileWriteString(fh, result);
   FileClose(fh);
   return true;
  }
 //--- What depends on the account (the symbols are not the same from an account to another) is kept in a folder of that account, made the first time
 //--- the account writes: MQL5\Files\<program name>\Configuration\<server>_<login>\Config_Setting.json. A manager of such data reads and writes this file
 //--- (JSONConfig_AccountFile) and the other managers keep the shared one (CONFIG_SETTING_FILE). The key is the one of the trade database of the account too
 string JSONConfig_AccountKey(void)
  {
   string server = AccountInfoString(ACCOUNT_SERVER);
   string safe = "";
   bool gap = false;
   for(int i = 0; i < StringLen(server); i++)
     {
      ushort c = StringGetCharacter(server, i);
      bool keep = ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '.' || c == '-');
      if(keep)
        {
         safe += ShortToString(c);
         gap = false;
        }
      else if(!gap)
        {
         safe += "_";
         gap = true;
        }
     }
   while(StringLen(safe) > 0 && StringGetCharacter(safe, 0) == '_')
      safe = StringSubstr(safe, 1);
   while(StringLen(safe) > 0 && StringGetCharacter(safe, StringLen(safe) - 1) == '_')
      safe = StringSubstr(safe, 0, StringLen(safe) - 1);
   if(safe == "")
      safe = "account";
   return safe + "_" + (string)AccountInfoInteger(ACCOUNT_LOGIN);
  }
 string JSONConfig_AccountFile(void)
  {
   return "/Configuration/" + JSONConfig_AccountKey() + "/Config_Setting.json";
  }
 //--- The first time an account is used its file is not there: a key that was saved before in the shared file is copied to it (the shared file keeps it)
 bool JSONConfig_CopySection(const string from_path, const string to_path, const string key)
  {
   string content = JSONConfig_ReadWholeFile(from_path);
   string raw = JSONConfig_ExtractRawSection(content, key);
   if(raw == "")
      return false;
   Print(__FUNCTION__, " > \"", key, "\" of ", from_path, " is the start of ", to_path);
   return JSONConfig_SaveSection(to_path, key, raw);
  }
#endif // JSONCONFIG_MQH

