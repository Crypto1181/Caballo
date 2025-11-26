// Supabase Edge Function: Place Order via Alpaca
// 
// This function:
// 1. Validates user authentication
// 2. Gets user's Alpaca account ID
// 3. Validates order parameters
// 4. Places order via Alpaca Broker API
// 5. Saves order record to database

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const ALPACA_CLIENT_ID = Deno.env.get('ALPACA_CLIENT_ID') || '';
const ALPACA_CLIENT_SECRET = Deno.env.get('ALPACA_CLIENT_SECRET') || '';
const ALPACA_BROKER_API_URL = Deno.env.get('ALPACA_BROKER_API_URL') || 
  'https://broker-api.sandbox.alpaca.markets';

interface RequestBody {
  userId: string;
  symbol: string;
  qty: number;
  side: 'buy' | 'sell';
  type: 'market' | 'limit' | 'stop' | 'stop_limit';
  timeInForce: 'day' | 'gtc' | 'opg' | 'cls' | 'ioc' | 'fok';
  limitPrice?: number;
  stopPrice?: number;
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    // Get authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Verify user token
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Parse request body
    const body: RequestBody = await req.json();

    // Verify userId matches authenticated user
    if (body.userId !== user.id) {
      return new Response(
        JSON.stringify({ error: 'User ID mismatch' }),
        { status: 403, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Validate order parameters
    if (!body.symbol || !body.qty || body.qty <= 0) {
      return new Response(
        JSON.stringify({ error: 'Invalid order parameters' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Get user's Alpaca account ID
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('alpaca_account_id')
      .eq('id', user.id)
      .single();

    if (profileError || !profile?.alpaca_account_id) {
      return new Response(
        JSON.stringify({ error: 'Alpaca account not found. Please complete onboarding.' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const alpacaAccountId = profile.alpaca_account_id;

    // Place order via Alpaca Broker API
    const credentials = btoa(`${ALPACA_CLIENT_ID}:${ALPACA_CLIENT_SECRET}`);
    const clientOrderId = `caballo-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const orderBody: any = {
      symbol: body.symbol.toUpperCase(),
      qty: body.qty,
      side: body.side,
      type: body.type,
      time_in_force: body.timeInForce,
      client_order_id: clientOrderId,
    };

    if (body.limitPrice) {
      orderBody.limit_price = body.limitPrice;
    }
    if (body.stopPrice) {
      orderBody.stop_price = body.stopPrice;
    }

    const alpacaResponse = await fetch(
      `${ALPACA_BROKER_API_URL}/v1/trading/accounts/${alpacaAccountId}/orders`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${credentials}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(orderBody),
      }
    );

    if (!alpacaResponse.ok) {
      const error = await alpacaResponse.text();
      console.error('Alpaca order error:', error);
      return new Response(
        JSON.stringify({ error: 'Failed to place order', details: error }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const order = await alpacaResponse.json();

    // Save order to database
    const { error: orderError } = await supabase
      .from('orders')
      .insert({
        user_id: user.id,
        client_order_id: clientOrderId,
        broker_order_id: order.id,
        alpaca_account_id: alpacaAccountId,
        symbol: body.symbol.toUpperCase(),
        side: body.side,
        qty: body.qty,
        notional: body.qty * (body.limitPrice || 0), // Approximate
        status: order.status || 'pending',
        filled_qty: order.filled_qty || 0,
        fees: 0, // Will be updated when order fills
      });

    if (orderError) {
      console.error('Error saving order:', orderError);
      // Continue anyway - order was placed successfully
    }

    return new Response(
      JSON.stringify({
        success: true,
        order: order,
        client_order_id: clientOrderId,
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error', message: error.message }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  }
});

