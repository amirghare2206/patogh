import { Webhook } from 'npm:standardwebhooks@1.0.0';

function normalizeIranPhone(value: string): string {
  let digits = value.replace(/\D/g, '');

  if (digits.startsWith('0098')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('98')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  return `0${digits}`;
}

Deno.serve(async (req) => {
  try {
    const raw = await req.text();

    const hookSecret = Deno.env
      .get('SEND_SMS_HOOK_SECRET')
      ?.trim()
      .replace('v1,whsec_', '');

    if (!hookSecret) {
      console.error('SMS_HOOK: SEND_SMS_HOOK_SECRET missing');
      return new Response('HOOK_SECRET_MISSING', { status: 500 });
    }

    const wh = new Webhook(hookSecret);

    const payload = wh.verify(
      raw,
      Object.fromEntries(req.headers),
    ) as any;

    const phone = payload?.user?.phone;
    const otp = payload?.sms?.otp;

    if (!phone || !otp) {
      console.error('SMS_HOOK: invalid payload');
      return new Response('INVALID_PAYLOAD', { status: 400 });
    }

    const apiKey = Deno.env.get('KAVENEGAR_API_KEY')?.trim();
    const template =
      (Deno.env.get('KAVENEGAR_TEMPLATE') ?? 'patogh-login').trim();

    if (!apiKey) {
      console.error('SMS_HOOK: KAVENEGAR_API_KEY missing');
      return new Response('KAVENEGAR_API_KEY_MISSING', { status: 500 });
    }

    const receptor = normalizeIranPhone(phone);

    const maskedReceptor =
      receptor.length >= 5
        ? receptor.slice(0, 4) + '***' + receptor.slice(-2)
        : '***';

    console.log(
      `SMS_HOOK: sending receptor=${maskedReceptor} template=${template}`,
    );

    const url =
      `https://api.kavenegar.com/v1/${apiKey}/verify/lookup.json/`;

    const body = new URLSearchParams();
    body.set('receptor', receptor);
    body.set('token', String(otp));
    body.set('template', template);
    body.set('type', 'sms');

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    const responseText = await response.text();

    console.log(
      `SMS_HOOK: kavenegar_http_status=${response.status}`,
    );

    if (!response.ok) {
      console.error(
        `SMS_HOOK: KAVENEGAR_HTTP_ERROR status=${response.status} body=${responseText}`,
      );

      return new Response('KAVENEGAR_FAILED', { status: 502 });
    }

    const data = JSON.parse(responseText);
    const kavenegarStatus = data?.return?.status;
    const kavenegarMessage = data?.return?.message;

    console.log(
      `SMS_HOOK: kavenegar_status=${kavenegarStatus} message=${kavenegarMessage}`,
    );

    if (kavenegarStatus !== 200) {
      console.error(
        `SMS_HOOK: KAVENEGAR_API_ERROR status=${kavenegarStatus} message=${kavenegarMessage}`,
      );

      return new Response('KAVENEGAR_FAILED', { status: 502 });
    }

    console.log('SMS_HOOK: success');

    return new Response(JSON.stringify({}), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  } catch (e) {
    console.error(`SMS_HOOK_ERROR: ${String(e)}`);

    return new Response(
      `SMS_HOOK_ERROR:${String(e)}`,
      { status: 401 },
    );
  }
});
