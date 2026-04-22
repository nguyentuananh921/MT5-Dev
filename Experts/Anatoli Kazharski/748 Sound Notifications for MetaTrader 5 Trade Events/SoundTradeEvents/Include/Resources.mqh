//--- Connection with the main file of the Expert Advisor
#include "..\SoundTradeEvents.mq5"
//--- Sound files
#resource "\\Files\\SoundsLib\\AHOOGA.WAV"   // Error
#resource "\\Files\\SoundsLib\\CASHREG.WAV"  // Position opening/position volume increase/pending order triggering
#resource "\\Files\\SoundsLib\\WHOOSH.WAV"   // Pending order/Stop Loss/Take Profit setting/modification
#resource "\\Files\\SoundsLib\\VERYGOOD.WAV" // Position closing at profit
#resource "\\Files\\SoundsLib\\DRIVEBY.WAV"  // Position closing at loss
//--- Sound file location
string SoundError          = "::Files\\SoundsLib\\AHOOGA.WAV";
string SoundOpenPosition   = "::Files\\SoundsLib\\CASHREG.WAV";
string SoundAdjustOrder    = "::Files\\SoundsLib\\WHOOSH.WAV";
string SoundCloseWithProfit= "::Files\\SoundsLib\\VERYGOOD.WAV";
string SoundCloseWithLoss  = "::Files\\SoundsLib\\DRIVEBY.WAV";
//+------------------------------------------------------------------+
