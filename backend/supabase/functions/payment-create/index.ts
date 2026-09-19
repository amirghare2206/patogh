import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  try {
    const body = await req.json();
    const providerUrl = Deno.env.get("PAYMENT_PROVIDER_CREATE_URL");
    const merchantId = Deno.env.get("PAYMENT_MERCHANT_ID");

    if (!providerUrl || !merchantId) {
      return new Response(
        JSON.stringify({
          error: "PAYMENT_PROVIDER_NOT_CONFIGURED"
        }),
        { status: 503, headers: { "content-type": "application/json" } },
      );
    }

    const providerResponse = await fetch(providerUrl, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        merchant_id: merchantId,
        amount: body.amount,
        callback_url: body.callback_url,
        description: `Patogh event ${body.event_id}`,
      }),
    });

    const providerBody = await providerResponse.json();

    // Map these fields to the payment gateway you choose.
    const paymentUrl =
      providerBody.payment_url ??
      providerBody.url ??
      providerBody.redirect_url;

    const reference =
      providerBody.reference ??
      providerBody.authority ??
      providerBody.id;

    if (!providerResponse.ok || !paymentUrl) {
      return new Response(
        JSON.stringify({
          error: "PAYMENT_CREATE_FAILED",
          provider: providerBody,
        }),
        { status: 502, headers: { "content-type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({
        payment_url: paymentUrl,
        reference,
      }),
      { headers: { "content-type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { "content-type": "application/json" } },
    );
  }
});
