//+------------------------------------------------------------------+
//|                                                 JSONConfig.mqh   |
//+------------------------------------------------------------------+

#ifndef JSONCONFIG_MQH
#define JSONCONFIG_MQH
 //--- reads MQL5\Files\<filename> as plain text, "" if missing - shared by every writer that
 //--- needs to read the file back before rewriting it (to preserve sections it doesn't own).
 string JSONConfig_ReadWholeFile(const string &filename)
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
 
#endif // JSONCONFIG_MQH

