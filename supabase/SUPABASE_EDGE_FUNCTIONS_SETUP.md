# Supabase Edge Functions Setup Guide

## Overview

This guide will help you deploy the Supabase Edge Functions needed for Caballo's backend API.

## Prerequisites

1. Supabase CLI installed: `npm install -g supabase`
2. Supabase account and project
3. Stripe account with API keys
4. Alpaca Broker API credentials

## Step 1: Install Supabase CLI

```bash
npm install -g supabase
```

## Step 2: Login to Supabase

```bash
supabase login
```

## Step 3: Link Your Project

```bash
cd /path/to/caballo
supabase link --project-ref YOUR_PROJECT_REF
```

## Step 4: Set Environment Variables

Set these secrets in Supabase Dashboard or via CLI:

```bash
# Stripe
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...

# Alpaca
supabase secrets set ALPACA_CLIENT_ID=CKA5SUPP5WL7AUVKD2NT5WRTHF
supabase secrets set ALPACA_CLIENT_SECRET=YOUR_ALPACA_SECRET
supabase secrets set ALPACA_BROKER_API_URL=https://broker-api.sandbox.alpaca.markets

# Supabase (auto-set, but verify)
supabase secrets set SUPABASE_URL=https://kjaazaxqxjvoyvzvyauj.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Step 5: Deploy Functions

Deploy each function:

```bash
# Deploy deposits function
supabase functions deploy deposits

# Deploy stripe webhook
supabase functions deploy stripe-webhook

# Deploy create-alpaca-account
supabase functions deploy create-alpaca-account

# Deploy place-order
supabase functions deploy place-order

# Deploy get-orders
supabase functions deploy get-orders
```

## Step 6: Set Up Stripe Webhook

1. Go to Stripe Dashboard > Developers > Webhooks
2. Add endpoint: `https://YOUR_PROJECT_REF.supabase.co/functions/v1/stripe-webhook`
3. Select events:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.dispute.created`
4. Copy the webhook signing secret
5. Set it as `STRIPE_WEBHOOK_SECRET` in Supabase secrets

## Step 7: Create Missing Database Tables

Run this SQL in Supabase SQL Editor:

```sql
-- Virtual balances table
create table if not exists virtual_balances (
  user_id uuid primary key references auth.users(id) on delete cascade,
  currency text default 'USD',
  available numeric default 0,
  pending numeric default 0,
  updated_at timestamptz default now()
);

-- Orders table (if not already created)
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
create index if not exists idx_deposits_user_id on deposits(user_id);
create index if not exists idx_deposits_status on deposits(status);
```

## Step 8: Test the Functions

You can test functions locally:

```bash
# Start local Supabase
supabase start

# Test deposits function
curl -X POST http://localhost:54321/functions/v1/deposits \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "userId": "user-id"}'
```

## Function Endpoints

Once deployed, your functions will be available at:

- `https://YOUR_PROJECT_REF.supabase.co/functions/v1/deposits`
- `https://YOUR_PROJECT_REF.supabase.co/functions/v1/stripe-webhook`
- `https://YOUR_PROJECT_REF.supabase.co/functions/v1/create-alpaca-account`
- `https://YOUR_PROJECT_REF.supabase.co/functions/v1/place-order`
- `https://YOUR_PROJECT_REF.supabase.co/functions/v1/get-orders`

## Security Notes

- All functions require authentication (Bearer token)
- Service role key is only used server-side
- Stripe webhook signature verification (implement in production)
- User ID is verified against auth token

## Troubleshooting

- Check function logs: `supabase functions logs FUNCTION_NAME`
- Verify environment variables: `supabase secrets list`
- Test locally before deploying: `supabase functions serve`

