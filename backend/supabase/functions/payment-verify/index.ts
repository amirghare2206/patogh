import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const body = await req.json();

  const providerUrl = Deno.env.get("PAYMENT_PROVIDER_VERIFY_URL");
  const merchantId = Deno.env.get("PAYMENT_MERCHANT_ID");

  if (!providerUrl || !merchantId) {
    return new Response(
      JSON.stringify({ error: "PAYMENT_PROVIDER_NOT_CONFIGURED" }),
      { status: 503, headers: { "content-type": "application/json" } },
    );
  }

  const response = await fetch(providerUrl, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      merchant_id: merchantId,
      reference: body.reference,
      amount: body.amount,
    }),
  });

  const result = await response.json();

  return new Response(
    JSON.stringify({
      verified: response.ok,
      provider: result,
    }),
    {
      status: response.ok ? 200 : 400,
      headers: { "content-type": "application/json" },
    },
  );
});
