// Supabase Edge Function: Get Order History
// 
// This function:
// 1. Validates user authentication
// 2. Gets orders from database
// 3. Optionally fetches latest status from Alpaca

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const ALPACA_CLIENT_ID = Deno.env.get('ALPACA_CLIENT_ID') || '';
const ALPACA_CLIENT_SECRET = Deno.env.get('ALPACA_CLIENT_SECRET') || '';
const ALPACA_BROKER_API_URL = Deno.env.get('ALPACA_BROKER_API_URL') || 
  'https://broker-api.sandbox.alpaca.markets';

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
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

    // Get query parameters
    const url = new URL(req.url);
    const status = url.searchParams.get('status'); // 'all', 'open', 'closed'
    const limit = parseInt(url.searchParams.get('limit') || '50');

    // Get orders from database
    let query = supabase
      .from('orders')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (status && status !== 'all') {
      if (status === 'open') {
        query = query.in('status', ['pending', 'accepted', 'partially_filled']);
      } else if (status === 'closed') {
        query = query.in('status', ['filled', 'cancelled', 'expired', 'rejected']);
      }
    }

    const { data: orders, error: ordersError } = await query;

    if (ordersError) {
      console.error('Error fetching orders:', ordersError);
      return new Response(
        JSON.stringify({ error: 'Failed to fetch orders' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        orders: orders || [],
        count: orders?.length || 0,
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

