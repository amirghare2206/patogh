import { Webhook } from 'https://esm.sh/standardwebhooks@1.0.0';

Deno.serve(async (req) => {
  try {
    const raw = await req.text();
    const hookSecret = Deno.env.get('SEND_SMS_HOOK_SECRET')?.replace('v1,whsec_', '');
    if (!hookSecret) return new Response('HOOK_SECRET_MISSING', { status: 500 });
    const wh = new Webhook(hookSecret);
    const payload = wh.verify(raw, Object.fromEntries(req.headers)) as any;
    const phone = payload?.user?.phone;
    const otp = payload?.sms?.otp;
    if (!phone || !otp) return new Response('INVALID_PAYLOAD', { status: 400 });

    const providerUrl = Deno.env.get('SMS_PROVIDER_URL');
    const apiKey = Deno.env.get('SMS_PROVIDER_API_KEY');
    if (!providerUrl || !apiKey) return new Response('SMS_PROVIDER_NOT_CONFIGURED', { status: 503 });

    // Adapter template: adjust field names/headers for Kavenegar, Melipayamak,
    // FarazSMS, or your chosen Iranian provider. Supabase remains responsible
    // for OTP generation and verification; this hook only delivers the code.
    const provider = await fetch(providerUrl, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        receptor: phone,
        message: `کد ورود پاتوق: ${otp}`,
        code: otp,
      }),
    });
    if (!provider.ok) return new Response(`SMS_PROVIDER_FAILED:${await provider.text()}`, { status: 502 });
    return new Response('', { status: 200 });
  } catch (e) {
    return new Response(String(e), { status: 401 });
  }
});
