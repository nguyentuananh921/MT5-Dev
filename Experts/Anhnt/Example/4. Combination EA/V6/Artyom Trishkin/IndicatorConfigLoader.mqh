//+------------------------------------------------------------------+
//|                                       IndicatorConfigLoader.mqh   |
//| Minimal parser for this EA's indicator startup config file.      |
//| Supports only the one shape this EA needs:                       |
//|   [ { "type": "<catalog name>", "params": [ <number>, ... ] }, ]|
//| "//" starts a line comment - non-standard JSON, but this file    |
//| is our own format (used only by LoadIndicatorsFromJson), not     |
//| meant to be read by other JSON tools.                            |
//+------------------------------------------------------------------+
#ifndef __INDICATORCONFIGLOADER_MQH__
#define __INDICATORCONFIGLOADER_MQH__ 
  struct SJsonIndicatorEntry
    {
     string type;
     double params[];
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
  //--- skip whitespace/commas starting at pos
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
  //--- read a number starting at pos, return pos after the number
  int IndicatorConfig_ReadNumber(const string &s, int pos, double &out)
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
     out = StringToDouble(StringSubstr(s, start, pos - start));
     return pos;
    }
  //--- read a "params" array of numbers: [ 1, 2.5, -3 ]
  int IndicatorConfig_ReadParamsArray(const string &s, int pos, double &out[])
    {
     ArrayResize(out, 0);
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[')
       return pos;
     pos++; // skip '['
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
       {
        double value;
        pos = IndicatorConfig_ReadNumber(s, pos, value);
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
  //--- parse the top-level [ {...}, {...} ] array
  bool IndicatorConfig_ParseText(const string &text, SJsonIndicatorEntry &out[])
    {
      ArrayResize(out, 0);
      string clean = IndicatorConfig_StripComments(text);
      int pos = IndicatorConfig_SkipSpace(clean, 0);
      if(pos >= StringLen(clean) || StringGetCharacter(clean, pos) != '[')
        {
         Print("IndicatorConfig_ParseText > top-level JSON must be an array");
         return false;
        }
      pos++; // skip '['
      pos = IndicatorConfig_SkipSpace(clean, pos);
      while(pos < StringLen(clean) && StringGetCharacter(clean, pos) != ']')
        {
         SJsonIndicatorEntry entry;
         pos = IndicatorConfig_ReadEntry(clean, pos, entry);
         int sz = ArraySize(out);
         ArrayResize(out, sz + 1);
         out[sz] = entry;
         pos = IndicatorConfig_SkipSpace(clean, pos);
        }
      return true;
    }
  //--- read MQL5\Files\<filename> and parse it
  bool ParseIndicatorConfigFile(const string &filename, SJsonIndicatorEntry &out[])
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
   return IndicatorConfig_ParseText(text, out);
  }

#endif // __INDICATORCONFIGLOADER_MQH__
