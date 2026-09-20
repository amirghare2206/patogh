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
    const userClient = createClient(url, anon, {
      global: { headers: { Authorization: auth } },
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) return response({ error: 'AUTH_REQUIRED' }, 401);

    const { asset_id } = await req.json();
    if (!asset_id) return response({ error: 'ASSET_ID_REQUIRED' }, 400);

    const admin = createClient(url, service);
    const { data: asset, error: assetError } = await admin
      .from('media_assets')
      .select('*')
      .eq('id', asset_id)
      .eq('status', 'approved')
      .maybeSingle();
    if (assetError || !asset) return response({ error: 'NOT_FOUND' }, 404);

    let allowed = asset.owner_id === user.id;

    if (!allowed && asset.scope === 'post') {
      const { data } = await admin
        .from('timeline_post_media')
        .select('post_id,timeline_posts!inner(user_id)')
        .eq('media_id', asset.id)
        .limit(1);
      const owner = (data?.[0] as any)?.timeline_posts?.user_id;
      allowed = !!owner && !(await isBlocked(admin, user.id, owner));
    }

    if (!allowed && asset.scope === 'story') {
      const { data } = await admin
        .from('story_media')
        .select('story_id,stories!inner(user_id,expires_at)')
        .eq('media_id', asset.id)
        .limit(1);
      const story = (data?.[0] as any)?.stories;
      allowed = !!story &&
        new Date(story.expires_at).getTime() > Date.now() &&
        !(await isBlocked(admin, user.id, story.user_id));
    }

    if (!allowed && asset.scope === 'community') {
      const { data } = await admin
        .from('chat_message_media')
        .select('message_id,chat_messages!inner(room_id,user_id)')
        .eq('media_id', asset.id)
        .limit(1);
      const message = (data?.[0] as any)?.chat_messages;
      if (message?.room_id) {
        allowed = await canAccessRoom(admin, user.id, message.room_id);
        if (allowed && message.user_id) {
          allowed = !(await isBlocked(admin, user.id, message.user_id));
        }
      }
    }

    // Memory media is private by default in v12. Until the memory ACL module is
    // fully remote, only the owner receives a signed URL.

    if (!allowed) return response({ error: 'FORBIDDEN' }, 403);

    const { data, error } = await admin.storage
      .from('social-media')
      .createSignedUrl(asset.storage_path, 3600);
    if (error || !data) return response({ error: 'SIGN_FAILED' }, 500);
    return response({ signed_url: data.signedUrl }, 200);
  } catch (e) {
    return response({ error: String(e) }, 500);
  }
});

async function canAccessRoom(admin: any, userId: string, roomId: string) {
  if (roomId === `support:${userId}`) return true;

  const { data: adminRole } = await admin
    .from('user_roles')
    .select('role')
    .eq('user_id', userId)
    .eq('role', 'admin')
    .eq('status', 'active')
    .maybeSingle();
  if (adminRole) return true;

  const { data: reservation } = await admin
    .from('reservations')
    .select('id')
    .eq('user_id', userId)
    .eq('event_id', roomId)
    .in('status', ['reserved', 'confirmed'])
    .maybeSingle();
  if (reservation) return true;

  const { data: event } = await admin
    .from('patogh_events')
    .select('host_id,organizer_id,coordinator_id,venue_id')
    .eq('id', roomId)
    .maybeSingle();
  if (event) {
    if (event.host_id === userId) return true;
    if (event.organizer_id) {
      const { data: organizer } = await admin.from('organizers').select('owner_id').eq('id', event.organizer_id).maybeSingle();
      if (organizer?.owner_id === userId) return true;
    }
    if (event.coordinator_id) {
      const { data: coordinator } = await admin.from('coordinators').select('user_id').eq('id', event.coordinator_id).maybeSingle();
      if (coordinator?.user_id === userId) return true;
    }
    if (event.venue_id) {
      const { data: venue } = await admin.from('venues').select('owner_id').eq('id', event.venue_id).maybeSingle();
      if (venue?.owner_id === userId) return true;
    }
  }

  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(roomId)) {
    return false;
  }
  const { data: membership } = await admin
    .from('community_members')
    .select('user_id')
    .eq('community_id', roomId)
    .eq('user_id', userId)
    .maybeSingle();
  return !!membership;
}

async function isBlocked(admin: any, a: string, b: string) {
  const { data } = await admin
    .from('user_blocks')
    .select('blocker_id')
    .or(`and(blocker_id.eq.${a},blocked_id.eq.${b}),and(blocker_id.eq.${b},blocked_id.eq.${a})`)
    .limit(1);
  return !!data?.length;
}

function response(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: corsHeaders,
  });
}
