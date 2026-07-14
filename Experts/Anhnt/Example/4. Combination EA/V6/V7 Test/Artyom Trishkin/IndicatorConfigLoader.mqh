//+------------------------------------------------------------------+
//|                                       IndicatorConfigLoader.mqh   |
//| Minimal parser for this EA's indicator startup config file.      |
//| Supports only the one shape this EA needs:                       |
//|   {                                                               |
//|     "symbols_tf": [ { "symbol": "<sym>", "tf": "<M1|...>" }, ], |
//|     "templates":  [ { "type": "<catalog name>",                  |
//|                        "params": [ <number> | "<choice text>", ] }, ]|
//|   }                                                               |
//| A "params" element is either a bare number (plain param, e.g.     |
//| Period/Shift/Deviation) or a quoted string (enum-like param, e.g. |
//| Method/Applied Price - matched against the catalog schema's      |
//| choices text at load time, see LoadIndicatorFromJSON).            |
//| "//" starts a line comment - non-standard JSON, but this file    |
//| is our own format (used only by LoadIndicatorFromJSON), not      |
//| meant to be read by other JSON tools.                            |
//+------------------------------------------------------------------+
#ifndef __INDICATORCONFIGLOADER_MQH__
#define __INDICATORCONFIGLOADER_MQH__
  struct SJsonIndicatorEntry
    {
     string type;
     string params[];      // raw token text - unquoted content for strings, digits as-is for numbers
    };
  struct SJsonSymbolTF
    {
     string symbol;
     string tf;            // "M1", "H1", ... (TimestampByDescription() format)
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
  //--- read a "params" array whose elements are EITHER a bare number OR a "quoted
  //--- string" (enum choice text) - both stored as raw text in out[], the caller
  //--- (LoadIndicatorFromJSON) decides how to interpret each element via the schema.
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
  //--- read one { "type": "...", "params": [...] } object
  int IndicatorConfig_ReadEntry(const string &s, int pos, SJsonIndicatorEntry &entry)
    {
     entry.type = "";
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
        pos = IndicatorConfig_SkipSpace(s, pos);
       }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}')
       pos++; // skip '}'
     return pos;
    }
  //--- read one { "symbol": "...", "tf": "..." } object
  int IndicatorConfig_ReadSymbolTFEntry(const string &s, int pos, SJsonSymbolTF &entry)
    {
     entry.symbol = "";
     entry.tf     = "";
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
        string value;
        pos = IndicatorConfig_ReadString(s, pos, value);
        if(key == "symbol") entry.symbol = value;
        else if(key == "tf") entry.tf = value;
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

#endif // __INDICATORCONFIGLOADER_MQH__
