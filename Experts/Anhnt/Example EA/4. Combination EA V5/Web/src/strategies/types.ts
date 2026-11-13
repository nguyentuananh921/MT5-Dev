//--- The rows server.py gives on GET /strategies (libdb.strategies): the columns of the tables, as the EA (CStrategyManager: SStrategyRow,
//--- SStrategyIndicatorRow, SStrategyConditionRow) and Python name them
export interface StrategyIndicatorRow {
  slot: string;
  collection: number;
  source_id: number;
  tf_enum: number | null;   // null: the TF of the strategy
  type_name: string | null; // the row of indicators (null: not an indicator slot)
  params: string | null;    // the strategy's (Setting_StrategyIndicator.params), else the standard of indicators
  level_high: number | null;
  level_low: number | null;
  param_keys: string[];     // the names of params, in its order (indicators.py PARAM_KEYS, added by server.py)
}

export interface StrategyConditionRow {
  role: 'entry' | 'exit' | 'stoploss' | 'takeprofit';
  signal_direction: 'BUY' | 'SELL' | 'NONE';
  slot: string;
  rule: string;   // 'signal' | 'last_signal' (the standard signal) or a rule of the strategy (conditions.ts STRATEGY_RULES)
}

export interface StrategyRow {
  strategy_id: number;
  name: string;
  reference: string;
  tf_enum: number | null;   // the TF it trades on (ENUM_TIMEFRAMES); null: the TF of the chart
  slots: StrategyIndicatorRow[];
  conditions: StrategyConditionRow[];
}
