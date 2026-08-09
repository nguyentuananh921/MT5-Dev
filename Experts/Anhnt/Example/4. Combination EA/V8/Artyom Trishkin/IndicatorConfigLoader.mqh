//+------------------------------------------------------------------+
//|                                      IndicatorConfigLoader.mqh   |
//| Minimal parser for this EA's indicator startup config file.      |
//| Supports only the one shape this EA needs:                       |
//|   {                                                               |
//|     "symbols_tf": [ { "symbol": "<sym>", "tf": "<M1|...>",        |
//|                       "buy": <true|false>, "sell": <true|false> }, ], |
//|     "templates":  [ { "type": "<catalog name>",                  |
//|                        "buy": <true|false>, "sell": <true|false>,|
//|                        "sound": <true|false>, "message": <true|false>, |
//|                        "params": [ <number> | "<choice text>", ] }, ]|
//|   }                                                               |
//| A "params" element is either a bare number (plain param, e.g.     |
//| Period/Shift/Deviation) or a quoted string (enum-like param, e.g. |
//| Method/Applied Price - matched against the catalog schema's      |
//| choices text at load time, see LoadConfigurationFromJSON).            |
//| "//" starts a line comment - non-standard JSON, but this file    |
//| is our own format (used only by LoadConfigurationFromJSON), not      |
//| meant to be read by other JSON tools.                            |
//+------------------------------------------------------------------+
#ifndef __INDICATORCONFIGLOADER_MQH__
#define __INDICATORCONFIGLOADER_MQH__
  struct SJsonIndicatorEntry
    {
     string type;
     bool   buy;
     bool   sell;
     bool   sound;         // per-template alert sound opt-in (2026-07-17, m_table_indicator col 5)
     bool   message;       // per-template Journal message opt-in (col 6)
     string params[];      // raw token text - unquoted content for strings, digits as-is for numbers
    };
  struct SJsonSymbolTF
    {
     string symbol;
     string tf;            // "M1", "H1", ... (TimestampByDescription() format)
     bool   buy;
     bool   sell;
    };
  //--- strip "//" line comments before scanning
  string IndicatorConfig_StripComments(const string &raw)
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
  int IndicatorConfig_SkipSpace(const string &s, int pos)
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
  //--- read a "quoted string" starting at the opening quote, return pos after closing quote
  int IndicatorConfig_ReadString(const string &s, int pos, string &out)
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
  //--- read a bare number (as raw text) starting at pos, return pos after the number
  int IndicatorConfig_ReadRawNumber(const string &s, int pos, string &out)
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
  //--- skips ANY JSON value (object/array/string/number/true/false/null) starting at pos,
  //--- returning pos right after it - used for top-level keys this loader doesn't itself
  //--- understand (e.g. "markers", written by CGUIPannel::SaveMarkerSettings into the same
  //--- Config_Setting.json file) so an unrecognized key doesn't desync the whole parse.
  int IndicatorConfig_SkipValue(const string &s, int pos)
    {
     int len = StringLen(s);
     pos = IndicatorConfig_SkipSpace(s, pos);
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
        return IndicatorConfig_ReadString(s, pos, dummy);
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
  //--- read a "params" array whose elements are EITHER a bare number OR a "quoted
  //--- string" (enum choice text) - both stored as raw text in out[], the caller
  //--- (LoadConfigurationFromJSON) decides how to interpret each element via the schema.
  int IndicatorConfig_ReadParamsArray(const string &s, int pos, string &out[])
    {
     ArrayResize(out, 0);
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[')
       return pos;
     pos++; // skip '['
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
       {
        string value;
        if(StringGetCharacter(s, pos) == '"')
           pos = IndicatorConfig_ReadString(s, pos, value);
        else
           pos = IndicatorConfig_ReadRawNumber(s, pos, value);
        int sz = ArraySize(out);
        ArrayResize(out, sz + 1);
        out[sz] = value;
        pos = IndicatorConfig_SkipSpace(s, pos);
       }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']')
       pos++; // skip ']'
     return pos;
    }
  //--- read one { "type": "...", "buy": true|false, "sell": true|false, "params": [...] } object -
  //--- type/params keep their own readers, buy/sell are bare true/false literals (see
  //--- IndicatorConfig_ReadSymbolTFEntry for why a blind ReadString() on those would hang).
  int IndicatorConfig_ReadEntry(const string &s, int pos, SJsonIndicatorEntry &entry)
    {
     entry.type    = "";
     entry.buy     = false;
     entry.sell    = false;
     entry.sound   = false;
     entry.message = false;
     ArrayResize(entry.params, 0);
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{')
       return pos;
     pos++; // skip '{'
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
       {
        string key;
        pos = IndicatorConfig_ReadString(s, pos, key);
        pos = IndicatorConfig_SkipSpace(s, pos);
        if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':')
           pos++; // skip ':'
        pos = IndicatorConfig_SkipSpace(s, pos);
        if(key == "type")
          {
            string value;
            pos = IndicatorConfig_ReadString(s, pos, value);
            entry.type = value;
          }
        else if(key == "params")
          {
            pos = IndicatorConfig_ReadParamsArray(s, pos, entry.params);
          }
        else if(key == "buy")
           pos = IndicatorConfig_ReadBool(s, pos, entry.buy);
        else if(key == "sell")
           pos = IndicatorConfig_ReadBool(s, pos, entry.sell);
        else if(key == "sound")
           pos = IndicatorConfig_ReadBool(s, pos, entry.sound);
        else if(key == "message")
           pos = IndicatorConfig_ReadBool(s, pos, entry.message);
        pos = IndicatorConfig_SkipSpace(s, pos);
       }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}')
       pos++; // skip '}'
     return pos;
    }
  //--- read one { "symbol": "...", "tf": "...", "buy": true|false, "sell": true|false } object -
  //--- symbol/tf are quoted strings, buy/sell are bare true/false literals, so each key needs
  //--- its own reader (a blind ReadString() on a bare "true" token never advances pos - infinite loop).
  int IndicatorConfig_ReadSymbolTFEntry(const string &s, int pos, SJsonSymbolTF &entry)
    {
     entry.symbol = "";
     entry.tf     = "";
     entry.buy    = false;
     entry.sell   = false;
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{')
       return pos;
     pos++; // skip '{'
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
       {
        string key;
        pos = IndicatorConfig_ReadString(s, pos, key);
        pos = IndicatorConfig_SkipSpace(s, pos);
        if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':')
           pos++; // skip ':'
        pos = IndicatorConfig_SkipSpace(s, pos);
        if(key == "symbol")
          {
           string value;
           pos = IndicatorConfig_ReadString(s, pos, value);
           entry.symbol = value;
          }
        else if(key == "tf")
          {
           string value;
           pos = IndicatorConfig_ReadString(s, pos, value);
           entry.tf = value;
          }
        else if(key == "buy")
           pos = IndicatorConfig_ReadBool(s, pos, entry.buy);
        else if(key == "sell")
           pos = IndicatorConfig_ReadBool(s, pos, entry.sell);
        pos = IndicatorConfig_SkipSpace(s, pos);
       }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}')
       pos++; // skip '}'
     return pos;
    }
  //--- read a top-level array of SJsonIndicatorEntry objects starting at '['
  int IndicatorConfig_ReadEntryArray(const string &s, int pos, SJsonIndicatorEntry &out[])
    {
     ArrayResize(out, 0);
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[')
       return pos;
     pos++; // skip '['
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
       {
        SJsonIndicatorEntry entry;
        pos = IndicatorConfig_ReadEntry(s, pos, entry);
        int sz = ArraySize(out);
        ArrayResize(out, sz + 1);
        out[sz] = entry;
        pos = IndicatorConfig_SkipSpace(s, pos);
       }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']')
       pos++; // skip ']'
     return pos;
    }
  //--- read a top-level array of SJsonSymbolTF objects starting at '['
  int IndicatorConfig_ReadSymbolTFArray(const string &s, int pos, SJsonSymbolTF &out[])
    {
     ArrayResize(out, 0);
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[')
       return pos;
     pos++; // skip '['
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
       {
        SJsonSymbolTF entry;
        pos = IndicatorConfig_ReadSymbolTFEntry(s, pos, entry);
        int sz = ArraySize(out);
        ArrayResize(out, sz + 1);
        out[sz] = entry;
        pos = IndicatorConfig_SkipSpace(s, pos);
       }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']')
       pos++; // skip ']'
     return pos;
    }
  //--- parse the top-level { "symbols_tf": [...], "templates": [...] } object
  bool IndicatorConfig_ParseText(const string &text, SJsonIndicatorEntry &out_templates[], SJsonSymbolTF &out_symbols_tf[])
    {
      ArrayResize(out_templates, 0);
      ArrayResize(out_symbols_tf, 0);
      string clean = IndicatorConfig_StripComments(text);
      int pos = IndicatorConfig_SkipSpace(clean, 0);
      if(pos >= StringLen(clean) || StringGetCharacter(clean, pos) != '{')
        {
         Print("IndicatorConfig_ParseText > top-level JSON must be an object { \"symbols_tf\":[...], \"templates\":[...] }");
         return false;
        }
      pos++; // skip '{'
      pos = IndicatorConfig_SkipSpace(clean, pos);
      while(pos < StringLen(clean) && StringGetCharacter(clean, pos) != '}')
        {
         string key;
         pos = IndicatorConfig_ReadString(clean, pos, key);
         pos = IndicatorConfig_SkipSpace(clean, pos);
         if(pos < StringLen(clean) && StringGetCharacter(clean, pos) == ':')
            pos++; // skip ':'
         pos = IndicatorConfig_SkipSpace(clean, pos);
         if(key == "templates")
            pos = IndicatorConfig_ReadEntryArray(clean, pos, out_templates);
         else if(key == "symbols_tf")
            pos = IndicatorConfig_ReadSymbolTFArray(clean, pos, out_symbols_tf);
         else
            pos = IndicatorConfig_SkipValue(clean, pos); // e.g. "markers" - not this loader's concern
         pos = IndicatorConfig_SkipSpace(clean, pos);
        }
      return true;
    }
  //--- read MQL5\Files\<filename> and parse it
  bool ParseIndicatorConfigFile(const string &filename, SJsonIndicatorEntry &out_templates[], SJsonSymbolTF &out_symbols_tf[])
  {
   int handle = FileOpen(filename, FILE_READ | FILE_TXT | FILE_ANSI);
   if(handle == INVALID_HANDLE)
     {
      Print("ParseIndicatorConfigFile > cannot open file: ", filename, " err=", GetLastError());
      return false;
     }
   string text = "";
   while(!FileIsEnding(handle))
      text += FileReadString(handle) + "\n";
   FileClose(handle);
   return IndicatorConfig_ParseText(text, out_templates, out_symbols_tf);
  }
  //--- reads MQL5\Files\<filename> as plain text, "" if missing - shared by every writer that
  //--- needs to read the file back before rewriting it (to preserve sections it doesn't own).
  string IndicatorConfig_ReadWholeFile(const string &filename)
   {
    int fh = FileOpen(filename, FILE_READ | FILE_TXT | FILE_ANSI);
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
  string IndicatorConfig_ExtractRawSection(const string &content, const string key)
   {
    int pos = StringFind(content, "\"" + key + "\"");
    if(pos < 0) return "";
    int colon = StringFind(content, ":", pos);
    if(colon < 0) return "";
    int start = IndicatorConfig_SkipSpace(content, colon + 1);
    int end   = IndicatorConfig_SkipValue(content, start);
    return StringSubstr(content, start, end - start);
   }
  //--- Extract int value from JSON key - minimal parser for machine-written JSON only
  bool JsonIntValue(const string content, const string key, int &value)
   {
    int pos = StringFind(content, "\"" + key + "\"");
    if(pos < 0) return false;
    int colon = StringFind(content, ":", pos);
    if(colon < 0) return false;
    int len = StringLen(content);
    int i = colon + 1;
    while(i < len && StringGetCharacter(content, i) == ' ') i++;
    int start = i;
    while(i < len)
     {
      ushort ch = StringGetCharacter(content, i);
      if((ch < '0' || ch > '9') && ch != '-') break;
      i++;
     }
    string num = StringSubstr(content, start, i - start);
    if(num == "") return false;
    value = (int)StringToInteger(num);
    return true;
   }
  //--- Extract quoted string value from JSON key - unescapes backslashes
  bool JsonStringValue(const string content, const string key, string &value)
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
  //--- Extract bool value (true/false literal) from JSON key
  bool JsonBoolValue(const string content, const string key, bool &value)
   {
    int pos = StringFind(content, "\"" + key + "\"");
    if(pos < 0) return false;
    int colon = StringFind(content, ":", pos);
    if(colon < 0) return false;
    int len = StringLen(content);
    int i = colon + 1;
    while(i < len && StringGetCharacter(content, i) == ' ') i++;
    if(StringSubstr(content, i, 4) == "true")
     {
      value = true;
      return true;
     }
    if(StringSubstr(content, i, 5) == "false")
     {
      value = false;
      return true;
     }
    return false;
   }

#endif // __INDICATORCONFIGLOADER_MQH__
