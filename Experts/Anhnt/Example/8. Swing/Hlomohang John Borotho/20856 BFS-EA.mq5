//+------------------------------------------------------------------+
//|                                                       BFS-EA.mq5 |
//|                        GIT under Copyright 2025, MetaQuotes Ltd. |
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
//+------------------------------------------------------------------+
#property copyright "GIT under Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Arrays\List.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                |
//+------------------------------------------------------------------+
enum ENUM_HISTORY_MODE
 {
   MODE_PREVIOUS_BARS,     // Previous Bars
   MODE_PREVIOUS_DAYS,     // Previous Days
   MODE_YESTERDAY_ONLY     // Yesterday Only
 };

 input ENUM_HISTORY_MODE   HistoryMode = MODE_PREVIOUS_DAYS;  // History Mode
 input int                 BarsLookback = 300;                // Bars Lookback
 input int                 DaysLookback = 5;                  // Days Lookback
 input int                 SwingPeriod = 3;                   // Swing Period (lookback bars)
 input double              BiasThreshold = 0.3;               // Bias Threshold
 input bool                EnableTrading = true;              // Enable Trading
 input double              LotSize = 0.1;                     // Lot Size
 input int                 TakeProfit = 100;                  // Take Profit (points)
 input int                 StopLoss = 50;                     // Stop Loss (points)
 input bool                VisualizeStructure = true;         // Visualize Structure
 input color               BullishColor = clrGreen;           // Bullish Color
 input color               BearishColor = clrRed;             // Bearish Color

//+------------------------------------------------------------------+
//| Swing Node Structure                                            |
//+------------------------------------------------------------------+
 struct SwingNode
  {
   int               index;          // bar index
   double            price;          // high or low price
   bool              isHigh;         // true = swing high, false = swing low
   bool              bullish;        // inferred direction
   int               level;          // BFS level
   datetime          time;           // bar time
   
   // Default constructor
   SwingNode(): index(0), price(0.0), isHigh(false), bullish(false), level(-1), time(0) {}
   
   // Parameterized constructor
   SwingNode(int idx, double prc, bool high, bool bull, int lvl, datetime t):
      index(idx), price(prc), isHigh(high), bullish(bull), level(lvl), time(t) {}
  };

//+------------------------------------------------------------------+
//| BFS Queue Item                                                  |
//+------------------------------------------------------------------+
 struct BFSItem
  {
   int               nodeIndex;      // index in nodes array
   int               level;          // BFS level
  };

//+------------------------------------------------------------------+
//| Edge Structure for Graph                                        |
//+------------------------------------------------------------------+
 struct Edge
  {
   int from;      // Source node index
   int to;        // Destination node index
  };

//+------------------------------------------------------------------+
//| Global Variables                                                |
//+------------------------------------------------------------------+
 SwingNode           nodes[];         // Array of swing nodes
 Edge                edges[];         // Array of edges
 int                 edgeCount = 0;   // Number of edges
 int                 nodeCount = 0;        // Number of nodes
 double              currentBias = 0.0;    // Current market bias
 bool                allowBuy = false;     // Allow buy trades
 bool                allowSell = false;    // Allow sell trades
 datetime            lastRecalcTime = 0;   // Last recalculation time
 int                 lastBarCount = 0;     // Last bar count
 CTrade              trade;                // Trading object for position management

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
 int OnInit()
  {
   // Validate inputs
   if(BarsLookback <= 0)
    {
      Print("Error: BarsLookback must be positive");
      return INIT_PARAMETERS_INCORRECT;
    }
   
   if(DaysLookback <= 0)
    {
      Print("Error: DaysLookback must be positive");
      return INIT_PARAMETERS_INCORRECT;
    }
   
   if(SwingPeriod <= 0)
    {
      Print("Error: SwingPeriod must be positive");
      return INIT_PARAMETERS_INCORRECT;
    }
   
   // Set timer for periodic updates (every 5 minutes)
    EventSetTimer(300);
   
   // Set trading parameters
    trade.SetExpertMagicNumber(12345);
    trade.SetDeviationInPoints(10);
    trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Initial calculation
    CalculateBFSStructure();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Remove timer
   EventKillTimer();
   
   // Clean up visualization objects
   if(VisualizeStructure)
   {
      RemoveVisualization();
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check for new bar
   if(IsNewBar())
   {
      CalculateBFSStructure();
      
      // Check for trading signals if enabled
      if(EnableTrading)
      {
         CheckTradingSignals();
      }
   }
   
   // Update visualization if enabled
   if(VisualizeStructure)
   {
      UpdateVisualization();
   }
}

//+------------------------------------------------------------------+
//| Timer function                                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Periodic recalculation (fallback)
   CalculateBFSStructure();
}

//+------------------------------------------------------------------+
//| Calculate BFS Market Structure                                  |
//+------------------------------------------------------------------+
void CalculateBFSStructure()
{
   // Reset values
   currentBias = 0.0;
   allowBuy = false;
   allowSell = false;
   
   // Step 1: Detect swing points
   if(!DetectSwingNodes())
   {
      Print("Failed to detect swing nodes");
      return;
   }
   
   // Step 2: Build directed graph (edges)
   BuildDirectedGraph();
   
   // Step 3: Select BFS root based on mode
   int rootIndex = SelectBFSRoot();
   if(rootIndex < 0)
   {
      Print("No valid root found");
      return;
   }
   
   // Step 4: Perform BFS traversal
   PerformBFSTraversal(rootIndex);
   
   // Step 5: Calculate market bias
   CalculateMarketBias();
   
   // Step 6: Update trading permissions
   UpdateTradingPermissions();
   
   // Update last calculation time
   lastRecalcTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Detect Swing Nodes                                              |
//+------------------------------------------------------------------+
bool DetectSwingNodes()
{
   // Determine how many bars to analyze
   int barsToAnalyze = 0;
   datetime startTime = 0;
   
   switch(HistoryMode)
   {
      case MODE_PREVIOUS_BARS:
         barsToAnalyze = BarsLookback + SwingPeriod * 2;
         break;
         
      case MODE_PREVIOUS_DAYS:
         startTime = TimeCurrent() - (DaysLookback * 86400);
         barsToAnalyze = iBars(_Symbol, _Period);
         break;
         
      case MODE_YESTERDAY_ONLY:
         {MqlDateTime yesterday;
         TimeToStruct(TimeCurrent() - 86400, yesterday);
         yesterday.hour = 0;
         yesterday.min = 0;
         yesterday.sec = 0;
         startTime = StructToTime(yesterday);
         barsToAnalyze = iBars(_Symbol, _Period);
         break;}
   }
   
   // Get historical data
   int totalBars = MathMin(barsToAnalyze, iBars(_Symbol, _Period));
   if(totalBars < SwingPeriod * 2 + 10)
   {
      Print("Not enough bars for swing detection");
      return false;
   }
   
   // Prepare arrays for highs and lows
   double highs[], lows[];
   datetime times[];
   
   ArrayResize(highs, totalBars);
   ArrayResize(lows, totalBars);
   ArrayResize(times, totalBars);
   
   // Copy data
   if(CopyHigh(_Symbol, _Period, 0, totalBars, highs) != totalBars ||
      CopyLow(_Symbol, _Period, 0, totalBars, lows) != totalBars ||
      CopyTime(_Symbol, _Period, 0, totalBars, times) != totalBars)
   {
      Print("Failed to copy historical data");
      return false;
   }
   
   // Detect swing highs and lows
   ArrayResize(nodes, 0);
   nodeCount = 0;
   
   for(int i = SwingPeriod; i < totalBars - SwingPeriod; i++)
   {
      bool isSwingHigh = true;
      bool isSwingLow = true;
      
      // Check for swing high
      for(int j = 1; j <= SwingPeriod; j++)
      {
         if(highs[i] <= highs[i-j] || highs[i] <= highs[i+j])
         {
            isSwingHigh = false;
            break;
         }
      }
      
      // Check for swing low
      for(int j = 1; j <= SwingPeriod; j++)
      {
         if(lows[i] >= lows[i-j] || lows[i] >= lows[i+j])
         {
            isSwingLow = false;
            break;
         }
      }
      
      // Add swing node if found
      if(isSwingHigh || isSwingLow)
      {
         SwingNode node;
         node.index = i;
         node.time = times[i];
         node.isHigh = isSwingHigh;
         
         if(isSwingHigh)
            node.price = highs[i];
         else
            node.price = lows[i];
            
         node.bullish = false;  // Will be determined during BFS
         node.level = -1;        // Not assigned yet
         
         ArrayResize(nodes, nodeCount + 1);
         nodes[nodeCount] = node;
         nodeCount++;
      }
   }
   
   Print("Detected ", nodeCount, " swing nodes");
   return nodeCount > 0;
}

//+------------------------------------------------------------------+
//| Build Directed Graph                                            |
//+------------------------------------------------------------------+
void BuildDirectedGraph()
{
   // Clear existing edges
   ArrayResize(edges, 0);
   edgeCount = 0;
   
   // Create edges from older to newer nodes (time progression)
   for(int i = 0; i < nodeCount; i++)
   {
      // Find the next valid swing to connect to
      int nextIndex = -1;
      
      // Look for the next swing of alternating type
      for(int j = i + 1; j < nodeCount; j++)
      {
         // Check if swing types alternate (high-low-high-low pattern)
         if(nodes[j].isHigh != nodes[i].isHigh)
         {
            // Check if there are no other valid swings between i and j
            bool validConnection = true;
            
            // Skip checking intermediate nodes for simplicity
            // In a more sophisticated version, we could check for 
            // price action patterns between swings
            
            if(validConnection)
            {
               nextIndex = j;
               break;
            }
         }
      }
      
      // Add edge if found
      if(nextIndex > i)
      {
         Edge edge;
         edge.from = i;
         edge.to = nextIndex;
         
         ArrayResize(edges, edgeCount + 1);
         edges[edgeCount] = edge;
         edgeCount++;
      }
   }
   
   Print("Created ", edgeCount, " edges in the graph");
}

//+------------------------------------------------------------------+
//| Select BFS Root Based on Mode                                   |
//+------------------------------------------------------------------+
int SelectBFSRoot()
{
   int rootIndex = -1;
   datetime currentTime = TimeCurrent();
   
   switch(HistoryMode)
   {
      case MODE_PREVIOUS_BARS:
         // Find the oldest swing within BarsLookback
         for(int i = 0; i < nodeCount; i++)
         {
            if(nodes[i].index >= BarsLookback)
            {
               rootIndex = i;
               break;
            }
         }
         break;
         
      case MODE_PREVIOUS_DAYS:
      {
         datetime startTime = currentTime - (DaysLookback * 86400);
         // Find first swing after startTime
         for(int i = 0; i < nodeCount; i++)
         {
            if(nodes[i].time >= startTime)
            {
               rootIndex = i;
               break;
            }
         }
         break;
      }
         
      case MODE_YESTERDAY_ONLY:
      {
         MqlDateTime yesterday;
         TimeToStruct(currentTime - 86400, yesterday);
         yesterday.hour = 0;
         yesterday.min = 0;
         yesterday.sec = 0;
         datetime yesterdayStart = StructToTime(yesterday);
         
         datetime todayStart = yesterdayStart + 86400;
         
         // Find first swing of yesterday
         for(int i = 0; i < nodeCount; i++)
         {
            if(nodes[i].time >= yesterdayStart && nodes[i].time < todayStart)
            {
               rootIndex = i;
               break;
            }
         }
         break;
      }
   }
   
   // If no root found with mode criteria, use the oldest node
   if(rootIndex == -1 && nodeCount > 0)
   {
      rootIndex = 0;
   }
   
   return rootIndex;
}

//+------------------------------------------------------------------+
//| Perform BFS Traversal                                           |
//+------------------------------------------------------------------+
void PerformBFSTraversal(int rootIndex)
{
   if(rootIndex < 0 || rootIndex >= nodeCount)
      return;
   
   // Reset node levels
   for(int i = 0; i < nodeCount; i++)
   {
      nodes[i].level = -1;
      nodes[i].bullish = false;
   }
   
   // Initialize queue for BFS
   BFSItem queue[];
   int queueSize = nodeCount;
   ArrayResize(queue, queueSize);
   
   // Enqueue root
   queue[0].nodeIndex = rootIndex;
   queue[0].level = 0;
   nodes[rootIndex].level = 0;
   int queueStart = 0;
   int queueEnd = 1;
   
   // BFS traversal
   while(queueStart < queueEnd)
   {
      // Dequeue
      BFSItem current = queue[queueStart];
      queueStart++;
      
      int currentIdx = current.nodeIndex;
      int currentLevel = current.level;
      
      // Classify node direction
      ClassifyNodeDirection(currentIdx);
      
      // Find and enqueue children (nodes reachable from current node)
      for(int e = 0; e < edgeCount; e++)
      {
         if(edges[e].from == currentIdx)
         {
            int childIdx = edges[e].to;
            if(nodes[childIdx].level == -1)  // Not visited yet
            {
               nodes[childIdx].level = currentLevel + 1;
               
               // Enqueue child
               if(queueEnd < queueSize)
               {
                  queue[queueEnd].nodeIndex = childIdx;
                  queue[queueEnd].level = currentLevel + 1;
                  queueEnd++;
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Classify Node Direction                                         |
//+------------------------------------------------------------------+
void ClassifyNodeDirection(int nodeIndex)
{
   if(nodeIndex <= 0)
   {
      // First node, classify based on recent price action
      double currentPrice = iClose(_Symbol, _Period, 0);
      if(nodes[nodeIndex].isHigh)
      {
         nodes[nodeIndex].bullish = (currentPrice > nodes[nodeIndex].price);
      }
      else
      {
         nodes[nodeIndex].bullish = (currentPrice < nodes[nodeIndex].price);
      }
      return;
   }
   
   // Find previous node of the same type
   int prevSameType = -1;
   for(int i = nodeIndex - 1; i >= 0; i--)
   {
      if(nodes[i].isHigh == nodes[nodeIndex].isHigh)
      {
         prevSameType = i;
         break;
      }
   }
   
   if(prevSameType >= 0)
   {
      // Compare with previous node of same type
      if(nodes[nodeIndex].isHigh)
      {
         // Swing high: higher high = bullish, lower high = bearish
         nodes[nodeIndex].bullish = (nodes[nodeIndex].price > nodes[prevSameType].price);
      }
      else
      {
         // Swing low: higher low = bullish, lower low = bearish
         nodes[nodeIndex].bullish = (nodes[nodeIndex].price > nodes[prevSameType].price);
      }
   }
   else
   {
      // No previous node of same type, use simple logic
      double currentPrice = iClose(_Symbol, _Period, 0);
      if(nodes[nodeIndex].isHigh)
      {
         nodes[nodeIndex].bullish = (currentPrice > nodes[nodeIndex].price);
      }
      else
      {
         nodes[nodeIndex].bullish = (currentPrice < nodes[nodeIndex].price);
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate Market Bias                                           |
//+------------------------------------------------------------------+
void CalculateMarketBias()
{
   double totalWeight = 0.0;
   double weightedSum = 0.0;
   
   for(int i = 0; i < nodeCount; i++)
   {
      if(nodes[i].level >= 0)  // Only consider visited nodes
      {
         // Calculate weight based on level (higher weight for lower levels)
         double weight = 1.0 / (1.0 + nodes[i].level * 0.2);
         
         // Add to weighted sum
         if(nodes[i].bullish)
            weightedSum += weight;
         else
            weightedSum -= weight;
            
         totalWeight += weight;
      }
   }
   
   if(totalWeight > 0)
   {
      currentBias = weightedSum / totalWeight;
   }
   else
   {
      currentBias = 0.0;
   }
   
   Print("Market Bias: ", DoubleToString(currentBias, 3));
}

//+------------------------------------------------------------------+
//| Update Trading Permissions                                      |
//+------------------------------------------------------------------+
void UpdateTradingPermissions()
{
   allowBuy = (currentBias > BiasThreshold);
   allowSell = (currentBias < -BiasThreshold);
   
   Print("Trading Permissions - Buy: ", allowBuy, ", Sell: ", allowSell);
}

//+------------------------------------------------------------------+
//| Check Trading Signals                                           |
//+------------------------------------------------------------------+
void CheckTradingSignals()
{
   // Check for existing positions
   if(PositionsTotal() > 0)
   {
      // Manage existing positions
      ManagePositions();
      return;
   }
   
   // Check for new signals
   if(allowBuy)
   {
      // Buy signal logic
      double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl = askPrice - StopLoss * _Point;
      double tp = askPrice + TakeProfit * _Point;
      
      // Optional: Add confirmation from recent swing break
      if(CheckRecentSwingBreak(true))
      {
         ExecuteBuyOrder(askPrice, sl, tp);
      }
   }
   else if(allowSell)
   {
      // Sell signal logic
      double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl = bidPrice + StopLoss * _Point;
      double tp = bidPrice - TakeProfit * _Point;
      
      // Optional: Add confirmation from recent swing break
      if(CheckRecentSwingBreak(false))
      {
         ExecuteSellOrder(bidPrice, sl, tp);
      }
   }
}

//+------------------------------------------------------------------+
//| Check Recent Swing Break                                        |
//+------------------------------------------------------------------+
bool CheckRecentSwingBreak(bool forBuy)
{
   if(nodeCount < 2)
      return true;  // No recent swings, allow trade
   
   // Find the most recent swing
   int recentSwingIndex = -1;
   for(int i = nodeCount - 1; i >= 0; i--)
   {
      if(nodes[i].index < 50)  // Within recent 50 bars
      {
         recentSwingIndex = i;
         break;
      }
   }
   
   if(recentSwingIndex < 0)
      return true;
   
   double currentPrice = iClose(_Symbol, _Period, 0);
   
   if(forBuy)
   {
      // For buy: check if price has broken above a recent swing high
      if(nodes[recentSwingIndex].isHigh)
      {
         return (currentPrice > nodes[recentSwingIndex].price);
      }
   }
   else
   {
      // For sell: check if price has broken below a recent swing low
      if(!nodes[recentSwingIndex].isHigh)
      {
         return (currentPrice < nodes[recentSwingIndex].price);
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Execute Buy Order using CTrade                                  |
//+------------------------------------------------------------------+
void ExecuteBuyOrder(double price, double sl, double tp)
{
   // Check if we already have a buy position
   if(trade.Buy(LotSize, _Symbol, price, sl, tp, "BFS Buy Signal"))
   {
      Print("Buy order executed successfully");
   }
   else
   {
      Print("Buy order failed. Error: ", GetLastError(), " - ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Execute Sell Order using CTrade                                 |
//+------------------------------------------------------------------+
void ExecuteSellOrder(double price, double sl, double tp)
{
   // Check if we already have a sell position
   if(trade.Sell(LotSize, _Symbol, price, sl, tp, "BFS Sell Signal"))
   {
      Print("Sell order executed successfully");
   }
   else
   {
      Print("Sell order failed. Error: ", GetLastError(), " - ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Manage Positions using CTrade                                   |
//+------------------------------------------------------------------+
void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         string symbol = PositionGetString(POSITION_SYMBOL);
         long magic = PositionGetInteger(POSITION_MAGIC);
         
         if(symbol == _Symbol && magic == 12345)
         {
            // Check if we should close based on bias change
            if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && currentBias < -BiasThreshold) ||
               (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && currentBias > BiasThreshold))
            {
               // Close position due to bias reversal
               if(trade.PositionClose(ticket))
               {
                  Print("Position closed due to bias reversal. Ticket: ", ticket);
               }
               else
               {
                  Print("Failed to close position. Error: ", GetLastError(), " - ", trade.ResultRetcodeDescription());
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Update Visualization                                            |
//+------------------------------------------------------------------+
void UpdateVisualization()
{
   RemoveVisualization();
   
   // Draw swing nodes
   for(int i = 0; i < nodeCount; i++)
   {
      if(nodes[i].level >= 0 && nodes[i].index < 200)  // Only show recent 200 bars
      {
         string objName = "SwingNode_" + IntegerToString(i);
         
         // Create object based on swing type
         if(nodes[i].isHigh)
         {
            // Draw swing high as downward arrow
            ObjectCreate(0, objName, OBJ_ARROW_DOWN, 0, nodes[i].time, nodes[i].price);
            ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_TOP);
         }
         else
         {
            // Draw swing low as upward arrow
            ObjectCreate(0, objName, OBJ_ARROW_UP, 0, nodes[i].time, nodes[i].price);
            ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
         }
         
         // Set color based on bullish/bearish classification
         if(nodes[i].bullish)
            ObjectSetInteger(0, objName, OBJPROP_COLOR, BullishColor);
         else
            ObjectSetInteger(0, objName, OBJPROP_COLOR, BearishColor);
         
         // Set size
         ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
         
         // Add level annotation
         string labelName = "Label_" + IntegerToString(i);
         ObjectCreate(0, labelName, OBJ_TEXT, 0, nodes[i].time, nodes[i].price);
         ObjectSetString(0, labelName, OBJPROP_TEXT, "L" + IntegerToString(nodes[i].level));
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_UPPER);
         
         // Adjust label position based on swing type
         if(nodes[i].isHigh)
            ObjectSetDouble(0, labelName, OBJPROP_PRICE, nodes[i].price + 10 * _Point);
         else
            ObjectSetDouble(0, labelName, OBJPROP_PRICE, nodes[i].price - 10 * _Point);
      }
   }
   
   // Draw edges between nodes
   for(int e = 0; e < edgeCount; e++)
   {
      int fromIdx = edges[e].from;
      int toIdx = edges[e].to;
      
      // Only draw edges for visible nodes
      if(fromIdx < nodeCount && toIdx < nodeCount && 
         nodes[fromIdx].index < 200 && nodes[toIdx].index < 200)
      {
         string edgeName = "Edge_" + IntegerToString(e);
         ObjectCreate(0, edgeName, OBJ_TREND, 0, nodes[fromIdx].time, nodes[fromIdx].price, 
                     nodes[toIdx].time, nodes[toIdx].price);
         ObjectSetInteger(0, edgeName, OBJPROP_COLOR, clrGray);
         ObjectSetInteger(0, edgeName, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, edgeName, OBJPROP_STYLE, STYLE_DASH);
      }
   }
   
   // Draw bias indicator
   string biasObjName = "BiasIndicator";
   ObjectCreate(0, biasObjName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, biasObjName, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, biasObjName, OBJPROP_YDISTANCE, 10);
   ObjectSetInteger(0, biasObjName, OBJPROP_XSIZE, 150);
   ObjectSetInteger(0, biasObjName, OBJPROP_YSIZE, 60);
   ObjectSetInteger(0, biasObjName, OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, biasObjName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, biasObjName, OBJPROP_BORDER_COLOR, clrGray);
   
   // Bias value
   string biasValueName = "BiasValue";
   ObjectCreate(0, biasValueName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, biasValueName, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, biasValueName, OBJPROP_YDISTANCE, 20);
   ObjectSetString(0, biasValueName, OBJPROP_TEXT, "Bias: " + DoubleToString(currentBias, 3));
   ObjectSetInteger(0, biasValueName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, biasValueName, OBJPROP_FONTSIZE, 12);
   
   // Trading status
   string statusName = "TradingStatus";
   ObjectCreate(0, statusName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, statusName, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, statusName, OBJPROP_YDISTANCE, 40);
   
   string statusText = "Status: ";
   if(allowBuy)
      statusText += "BUY";
   else if(allowSell)
      statusText += "SELL";
   else
      statusText += "NEUTRAL";
   
   ObjectSetString(0, statusName, OBJPROP_TEXT, statusText);
   ObjectSetInteger(0, statusName, OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, statusName, OBJPROP_FONTSIZE, 10);
}

//+------------------------------------------------------------------+
//| Remove Visualization                                            |
//+------------------------------------------------------------------+
void RemoveVisualization()
{
   // Remove all objects created by this EA
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, "SwingNode_") == 0 ||
         StringFind(name, "Label_") == 0 ||
         StringFind(name, "Edge_") == 0 ||
         StringFind(name, "Bias") == 0 ||
         StringFind(name, "TradingStatus") == 0)
      {
         ObjectDelete(0, name);
      }
   }
}

//+------------------------------------------------------------------+
//| Check for New Bar                                               |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   
   if(lastBarTime != currentBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get Time String                                                 |
//+------------------------------------------------------------------+
string GetTimeString(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return StringFormat("%04d.%02d.%02d %02d:%02d", dt.year, dt.mon, dt.day, dt.hour, dt.min);
}

//+------------------------------------------------------------------+
//| Print Node Information                                          |
//+------------------------------------------------------------------+
void PrintNodeInfo(SwingNode &node)
{
   string type = node.isHigh ? "High" : "Low";
   string direction = node.bullish ? "Bullish" : "Bearish";
   Print(StringFormat("Node: Index=%d, Time=%s, Price=%.5f, Type=%s, Level=%d, Direction=%s",
         node.index, GetTimeString(node.time), node.price, type, node.level, direction));
}