// Supabase Edge Function: Create Alpaca Account
// 
// This function:
// 1. Validates user authentication
// 2. Collects KYC information
// 3. Creates Alpaca account via Broker API
// 4. Saves account ID to Supabase profiles

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const ALPACA_CLIENT_ID = Deno.env.get('ALPACA_CLIENT_ID') || '';
const ALPACA_CLIENT_SECRET = Deno.env.get('ALPACA_CLIENT_SECRET') || '';
const ALPACA_BROKER_API_URL = Deno.env.get('ALPACA_BROKER_API_URL') || 
  'https://broker-api.sandbox.alpaca.markets';

interface RequestBody {
  userId: string;
  contactEmail: string;
  contactPhoneNumber: string;
  contactAddress: string;
  contactCity: string;
  contactState: string;
  contactPostalCode: string;
  contactCountry: string;
  givenName?: string;
  familyName?: string;
  taxId?: string;
  dateOfBirth?: string;
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

    // Check if account already exists
    const { data: profile } = await supabase
      .from('profiles')
      .select('alpaca_account_id')
      .eq('id', user.id)
      .single();

    if (profile?.alpaca_account_id) {
      return new Response(
        JSON.stringify({ 
          error: 'Alpaca account already exists',
          account_id: profile.alpaca_account_id,
        }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Create Alpaca account via Broker API
    const credentials = btoa(`${ALPACA_CLIENT_ID}:${ALPACA_CLIENT_SECRET}`);
    
    const alpacaResponse = await fetch(`${ALPACA_BROKER_API_URL}/v1/accounts`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contact: {
          email_address: body.contactEmail,
          phone_number: body.contactPhoneNumber,
          street_address: [body.contactAddress],
          city: body.contactCity,
          state: body.contactState,
          postal_code: body.contactPostalCode,
          country: body.contactCountry,
        },
        ...(body.givenName && { given_name: body.givenName }),
        ...(body.familyName && { family_name: body.familyName }),
        ...(body.taxId && { tax_id: body.taxId }),
        ...(body.dateOfBirth && { date_of_birth: body.dateOfBirth }),
      }),
    });

    if (!alpacaResponse.ok) {
      const error = await alpacaResponse.text();
      console.error('Alpaca error:', error);
      return new Response(
        JSON.stringify({ error: 'Failed to create Alpaca account', details: error }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const alpacaAccount = await alpacaResponse.json();
    const alpacaAccountId = alpacaAccount.id;

    // Save Alpaca account ID to Supabase
    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        alpaca_account_id: alpacaAccountId,
        updated_at: new Date().toISOString(),
      })
      .eq('id', user.id);

    if (updateError) {
      console.error('Error updating profile:', updateError);
      return new Response(
        JSON.stringify({ error: 'Failed to save account ID' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        account_id: alpacaAccountId,
        account: alpacaAccount,
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

