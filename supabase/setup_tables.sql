-- Virtual balances table
create table if not exists virtual_balances (
  user_id uuid primary key references auth.users(id) on delete cascade,
  currency text default 'USD',
  available numeric default 0,
  pending numeric default 0,
  updated_at timestamptz default now()
);

-- Orders table
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  client_order_id text unique,
  broker_order_id text,
  alpaca_account_id text not null,
  symbol text not null,
  side text not null, -- 'buy' or 'sell'
  qty numeric not null,
  notional numeric,
  status text not null default 'pending', -- 'pending', 'filled', 'cancelled', etc.
  filled_qty numeric default 0,
  fees numeric default 0,
  created_at timestamptz default now()
);

-- Audit logs table
create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  event_time timestamptz default now(),
  source text, -- 'stripe', 'alpaca', 'privy'
  event_type text,
  user_id uuid references auth.users(id) on delete cascade,
  raw_payload jsonb
);

-- Create indexes for better performance
create index if not exists idx_orders_user_id on orders(user_id);
create index if not exists idx_orders_status on orders(status);
create index if not exists idx_orders_created_at on orders(created_at);
create index if not exists idx_deposits_user_id on deposits(user_id);
create index if not exists idx_deposits_status on deposits(status);
create index if not exists idx_deposits_created_at on deposits(created_at);
create index if not exists idx_audit_logs_user_id on audit_logs(user_id);
create index if not exists idx_audit_logs_source on audit_logs(source);

