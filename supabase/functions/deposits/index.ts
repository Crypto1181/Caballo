// Supabase Edge Function: Create Stripe PaymentIntent for USDC deposits
// 
// This function:
// 1. Validates user authentication
// 2. Gets user's Alpaca account ID from Supabase
// 3. Creates Stripe PaymentIntent for USDC deposit
// 4. Saves deposit record to database
// 5. Returns client_secret for Flutter app

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') || '';
const STRIPE_API_URL = 'https://api.stripe.com/v1';

interface RequestBody {
    amount: number; // Amount in USD (e.g., 100.00)
    userId: string;
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
        const { amount, userId } = body;

        // Validate input
        if (!amount || amount <= 0) {
            return new Response(
                JSON.stringify({ error: 'Invalid amount' }),
                { status: 400, headers: { 'Content-Type': 'application/json' } }
            );
        }

        // Verify userId matches authenticated user
        if (userId !== user.id) {
            return new Response(
                JSON.stringify({ error: 'User ID mismatch' }),
                { status: 403, headers: { 'Content-Type': 'application/json' } }
            );
        }

        // Get user's Alpaca account ID from profiles
        const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('alpaca_account_id, privy_wallet_address')
            .eq('id', userId)
            .single();

        if (profileError || !profile) {
            return new Response(
                JSON.stringify({ error: 'User profile not found' }),
                { status: 404, headers: { 'Content-Type': 'application/json' } }
            );
        }

        const alpacaAccountId = profile.alpaca_account_id;
        if (!alpacaAccountId) {
            return new Response(
                JSON.stringify({ error: 'Alpaca account not found. Please complete onboarding.' }),
                { status: 400, headers: { 'Content-Type': 'application/json' } }
            );
        }

        // Create Stripe PaymentIntent for USDC deposit
        // Convert amount to cents
        const amountInCents = Math.round(amount * 100);

        const stripeResponse = await fetch(`${STRIPE_API_URL}/payment_intents`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                amount: amountInCents.toString(),
                currency: 'usd',
                'payment_method_types[]': 'crypto', // For USDC deposits
                'metadata[user_id]': userId,
                'metadata[alpaca_account_id]': alpacaAccountId,
                'metadata[wallet_address]': profile.privy_wallet_address || '',
                'metadata[deposit_type]': 'usdc',
            }).toString(),
        });

        if (!stripeResponse.ok) {
            const error = await stripeResponse.text();
            console.error('Stripe error:', error);
            return new Response(
                JSON.stringify({ error: 'Failed to create payment intent', details: error }),
                { status: 500, headers: { 'Content-Type': 'application/json' } }
            );
        }

        const paymentIntent = await stripeResponse.json();

        // Save deposit record to Supabase
        const { error: depositError } = await supabase
            .from('deposits')
            .insert({
                user_id: userId,
                alpaca_account_id: alpacaAccountId,
                stripe_payment_intent: paymentIntent.id,
                amount: amount,
                status: 'pending',
            });

        if (depositError) {
            console.error('Error saving deposit:', depositError);
            // Continue anyway - we can update it later via webhook
        }

        // Return client_secret for Flutter app
        return new Response(
            JSON.stringify({
                client_secret: paymentIntent.client_secret,
                payment_intent_id: paymentIntent.id,
                amount: amount,
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

