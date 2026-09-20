import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'content-type': 'application/json',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const anon = Deno.env.get('SUPABASE_ANON_KEY')!;
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const auth = req.headers.get('authorization') ?? '';
    const userClient = createClient(url, anon, { global: { headers: { Authorization: auth } } });
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) return response({ error: 'AUTH_REQUIRED' }, 401);

    const admin = createClient(url, service);
    await admin.from('account_deletion_audit').upsert({
      user_id: user.id,
      requested_at: new Date().toISOString(),
    });
    const { error } = await admin.auth.admin.deleteUser(user.id);
    if (error) return response({ error: error.message }, 500);
    return response({ ok: true }, 200);
  } catch (e) {
    return response({ error: String(e) }, 500);
  }
});

function response(body: unknown, status: number) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}
