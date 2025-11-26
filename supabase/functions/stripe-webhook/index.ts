// Supabase Edge Function: Handle Stripe Webhooks
// 
// This function:
// 1. Verifies Stripe webhook signature
// 2. Handles payment_intent.succeeded events
// 3. Updates deposit status in database
// 4. Updates virtual balance (optional - can be done via Alpaca funding API)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const STRIPE_WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET') || '';

/**
 * Verify Stripe webhook signature
 * Based on Stripe's signature verification algorithm
 */
async function verifyStripeSignature(
  payload: string,
  signature: string,
  secret: string
): Promise<boolean> {
  if (!signature || !secret) {
    return false;
  }

  try {
    // Parse signature header (format: t=timestamp,v1=signature)
    const elements = signature.split(',');
    const sigHeader: Record<string, string> = {};

    for (const element of elements) {
      const [key, value] = element.split('=');
      sigHeader[key] = value;
    }

    const timestamp = sigHeader.t;
    const signatureHash = sigHeader.v1;

    if (!timestamp || !signatureHash) {
      return false;
    }

    // Create signed payload
    const signedPayload = `${timestamp}.${payload}`;

    // Create HMAC signature
    const key = await crypto.subtle.importKey(
      'raw',
      new TextEncoder().encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    );

    const signatureBuffer = await crypto.subtle.sign(
      'HMAC',
      key,
      new TextEncoder().encode(signedPayload)
    );

    // Convert to hex
    const signatureHex = Array.from(new Uint8Array(signatureBuffer))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');

    // Compare signatures using constant-time comparison
    if (signatureHex.length !== signatureHash.length) {
      return false;
    }

    let match = true;
    for (let i = 0; i < signatureHex.length; i++) {
      if (signatureHex[i] !== signatureHash[i]) {
        match = false;
      }
    }

    // Optional: Check timestamp to prevent replay attacks (within 5 minutes)
    const currentTime = Math.floor(Date.now() / 1000);
    const eventTime = parseInt(timestamp);
    if (Math.abs(currentTime - eventTime) > 300) {
      console.warn('Webhook timestamp too old or too far in future');
      // Don't reject, but log warning
    }

    return match;
  } catch (error) {
    console.error('Signature verification error:', error);
    return false;
  }
}

serve(async (req) => {
  try {
    // Get raw body for signature verification
    const body = await req.text();
    const signature = req.headers.get('stripe-signature');

    if (!signature) {
      return new Response(
        JSON.stringify({ error: 'Missing stripe-signature header' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Verify webhook signature
    let event;
    try {
      // Verify signature if webhook secret is set
      if (STRIPE_WEBHOOK_SECRET) {
        const isValid = await verifyStripeSignature(body, signature, STRIPE_WEBHOOK_SECRET);
        if (!isValid) {
          console.error('Invalid webhook signature');
          return new Response(
            JSON.stringify({ error: 'Invalid signature' }),
            { status: 400, headers: { 'Content-Type': 'application/json' } }
          );
        }
      } else {
        console.warn('⚠️ STRIPE_WEBHOOK_SECRET not set - skipping signature verification');
      }

      // Parse event
      event = JSON.parse(body);
    } catch (err) {
      console.error('Webhook signature verification failed:', err);
      return new Response(
        JSON.stringify({ error: 'Invalid signature or payload' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Handle different event types
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event, supabase);
        break;

      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event, supabase);
        break;

      case 'charge.dispute.created':
        await handleDisputeCreated(event, supabase);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return new Response(
      JSON.stringify({ received: true }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Webhook error:', error);
    return new Response(
      JSON.stringify({ error: 'Webhook handler failed', message: error.message }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
});

async function handlePaymentIntentSucceeded(event: any, supabase: any) {
  const paymentIntent = event.data.object;
  const userId = paymentIntent.metadata?.user_id;
  const alpacaAccountId = paymentIntent.metadata?.alpaca_account_id;
  const amount = paymentIntent.amount / 100; // Convert from cents

  if (!userId || !alpacaAccountId) {
    console.error('Missing metadata in payment intent:', paymentIntent.id);
    return;
  }

  // Update deposit status to 'succeeded'
  const { error: updateError } = await supabase
    .from('deposits')
    .update({
      status: 'succeeded',
    })
    .eq('stripe_payment_intent', paymentIntent.id);

  if (updateError) {
    console.error('Error updating deposit:', updateError);
  }

  // Update virtual balance
  // Get current balance or create new record
  const { data: balance } = await supabase
    .from('virtual_balances')
    .select('available')
    .eq('user_id', userId)
    .single();

  if (balance) {
    // Update existing balance
    await supabase
      .from('virtual_balances')
      .update({
        available: (balance.available || 0) + amount,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', userId);
  } else {
    // Create new balance record
    await supabase
      .from('virtual_balances')
      .insert({
        user_id: userId,
        currency: 'USD',
        available: amount,
        pending: 0,
      });
  }

  // TODO: Call Alpaca funding API to transfer funds to Alpaca account
  // This would be done via Alpaca's funding endpoints
  // For now, we just update the virtual ledger

  console.log(`✅ Deposit succeeded: $${amount} for user ${userId}`);
}

async function handlePaymentIntentFailed(event: any, supabase: any) {
  const paymentIntent = event.data.object;

  // Update deposit status to 'failed'
  await supabase
    .from('deposits')
    .update({
      status: 'failed',
    })
    .eq('stripe_payment_intent', paymentIntent.id);

  console.log(`❌ Deposit failed: ${paymentIntent.id}`);
}

async function handleDisputeCreated(event: any, supabase: any) {
  const dispute = event.data.object;
  const paymentIntentId = dispute.payment_intent;

  // Mark deposit as disputed
  await supabase
    .from('deposits')
    .update({
      status: 'disputed',
    })
    .eq('stripe_payment_intent', paymentIntentId);

  console.log(`⚠️ Dispute created for payment: ${paymentIntentId}`);
}

