-- Chart Cache Table Setup for Supabase
-- Run this SQL in your Supabase SQL Editor to enable chart caching

-- Create the chart_cache table
CREATE TABLE IF NOT EXISTS chart_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cache_key TEXT UNIQUE NOT NULL,
  symbol TEXT NOT NULL,
  timeframe TEXT NOT NULL,
  data TEXT NOT NULL,
  cached_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_chart_cache_key ON chart_cache(cache_key);
CREATE INDEX IF NOT EXISTS idx_chart_cache_symbol ON chart_cache(symbol);
CREATE INDEX IF NOT EXISTS idx_chart_cache_cached_at ON chart_cache(cached_at);
CREATE INDEX IF NOT EXISTS idx_chart_cache_symbol_timeframe ON chart_cache(symbol, timeframe);

-- Enable Row Level Security (RLS) - allow public read/write for caching
ALTER TABLE chart_cache ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (since this is public cache data)
CREATE POLICY "Allow public access to chart cache"
  ON chart_cache
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Optional: Create a function to automatically clean old cache entries
CREATE OR REPLACE FUNCTION clean_old_chart_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM chart_cache
  WHERE cached_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- Optional: Schedule automatic cleanup (requires pg_cron extension)
-- SELECT cron.schedule('clean-chart-cache', '0 2 * * *', 'SELECT clean_old_chart_cache()');

