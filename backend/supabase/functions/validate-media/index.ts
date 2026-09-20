import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'content-type': 'application/json',
};
const MAX_TECHNICAL_BYTES = 100 * 1024 * 1024;
const COMMUNITY_VIDEO_BYTES = 10 * 1024 * 1024;
const POST_STORY_VIDEO_MS = 120_000;

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const anon = Deno.env.get('SUPABASE_ANON_KEY')!;
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const auth = req.headers.get('authorization') ?? '';
    const userClient = createClient(url, anon, { global: { headers: { Authorization: auth } } });
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) return json({ error: 'AUTH_REQUIRED' }, 401);

    const body = await req.json();
    const pendingPath = String(body.pending_path ?? '');
    const scope = String(body.scope ?? '');
    if (!['post','story','community','memory'].includes(scope)) return json({ error: 'INVALID_SCOPE' }, 400);
    if (!pendingPath.startsWith(`${user.id}/`)) return json({ error: 'INVALID_PATH' }, 403);

    const admin = createClient(url, service);
    const { data: blob, error: downloadError } = await admin.storage.from('pending-media').download(pendingPath);
    if (downloadError || !blob) return json({ error: 'PENDING_OBJECT_NOT_FOUND' }, 404);
    if (blob.size > MAX_TECHNICAL_BYTES) return reject(admin, pendingPath, 'FILE_TOO_LARGE_TECHNICAL');

    const mime = blob.type || mimeFromPath(pendingPath);
    const mediaType = mime.startsWith('video/') ? 'video' : mime.startsWith('audio/') ? 'audio' : mime.startsWith('image/') ? 'image' : null;
    if (!mediaType) return reject(admin, pendingPath, 'UNSUPPORTED_MEDIA_TYPE');

    let durationMs: number | null = null;
    if (mediaType === 'video') {
      if (scope === 'community' && blob.size > COMMUNITY_VIDEO_BYTES) return reject(admin, pendingPath, 'COMMUNITY_VIDEO_MAX_10_MIB');
      if (scope === 'post' || scope === 'story') {
        if (!(mime === 'video/mp4' || mime === 'video/quicktime')) return reject(admin, pendingPath, 'POST_STORY_VIDEO_MUST_BE_MP4_OR_MOV');
        const bytes = new Uint8Array(await blob.arrayBuffer());
        durationMs = parseMp4DurationMs(bytes);
        if (durationMs == null) return reject(admin, pendingPath, 'VIDEO_DURATION_UNREADABLE');
        if (durationMs > POST_STORY_VIDEO_MS) return reject(admin, pendingPath, 'POST_STORY_VIDEO_MAX_120_SECONDS');
      }
    }

    const extension = extensionFromPath(pendingPath) || extensionFromMime(mime);
    const finalPath = `${user.id}/${scope}/${crypto.randomUUID()}.${extension}`;
    const bytes = new Uint8Array(await blob.arrayBuffer());
    const { error: uploadError } = await admin.storage.from('social-media').upload(finalPath, bytes, { contentType: mime, upsert: false });
    if (uploadError) return json({ error: 'FINAL_UPLOAD_FAILED', detail: uploadError.message }, 500);
    await admin.storage.from('pending-media').remove([pendingPath]);

    const { data: asset, error: dbError } = await admin.from('media_assets').insert({
      owner_id: user.id,
      storage_path: finalPath,
      media_type: mediaType,
      mime_type: mime,
      size_bytes: blob.size,
      duration_ms: durationMs,
      scope,
      status: 'approved',
    }).select().single();
    if (dbError) {
      await admin.storage.from('social-media').remove([finalPath]);
      return json({ error: 'MEDIA_DB_FAILED', detail: dbError.message }, 500);
    }
    return json(asset, 200);
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

async function reject(admin: any, path: string, reason: string) {
  await admin.storage.from('pending-media').remove([path]);
  return json({ error: reason }, 400);
}
function json(body: unknown, status: number) { return new Response(JSON.stringify(body), { status, headers: cors }); }
function extensionFromPath(path: string) { const part = path.split('.').pop()?.toLowerCase(); return part && /^[a-z0-9]{1,5}$/.test(part) ? part : null; }
function extensionFromMime(mime: string) { if (mime === 'video/mp4') return 'mp4'; if (mime === 'video/quicktime') return 'mov'; if (mime === 'image/png') return 'png'; if (mime === 'image/webp') return 'webp'; if (mime === 'audio/mpeg') return 'mp3'; if (mime === 'audio/mp4') return 'm4a'; return 'jpg'; }
function mimeFromPath(path: string) { const ext = extensionFromPath(path); if (ext === 'mp4') return 'video/mp4'; if (ext === 'mov') return 'video/quicktime'; if (['jpg','jpeg'].includes(ext ?? '')) return 'image/jpeg'; if (ext === 'png') return 'image/png'; if (ext === 'webp') return 'image/webp'; if (ext === 'mp3') return 'audio/mpeg'; if (ext === 'm4a') return 'audio/mp4'; if (ext === 'wav') return 'audio/wav'; if (ext === 'ogg') return 'audio/ogg'; return 'application/octet-stream'; }

// Parses the movie header (mvhd) from ordinary MP4/MOV files. ImagePicker on
// Android/iOS normally produces this family. Unsupported containers are rejected.
function parseMp4DurationMs(bytes: Uint8Array): number | null {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const readType = (o: number) => String.fromCharCode(bytes[o], bytes[o+1], bytes[o+2], bytes[o+3]);
  const readU64 = (o: number) => Number((BigInt(view.getUint32(o)) << 32n) | BigInt(view.getUint32(o+4)));
  function scan(start: number, end: number): number | null {
    let offset = start;
    while (offset + 8 <= end) {
      let size = view.getUint32(offset);
      const type = readType(offset + 4);
      let header = 8;
      if (size === 1) { if (offset + 16 > end) return null; size = readU64(offset + 8); header = 16; }
      if (size === 0) size = end - offset;
      if (size < header || offset + size > end) return null;
      const content = offset + header;
      if (type === 'moov') { const r = scan(content, offset + size); if (r != null) return r; }
      if (type === 'mvhd' && content + 24 <= offset + size) {
        const version = bytes[content];
        if (version === 0) {
          const timescale = view.getUint32(content + 12); const duration = view.getUint32(content + 16);
          if (timescale > 0) return Math.round(duration * 1000 / timescale);
        } else if (version === 1 && content + 32 <= offset + size) {
          const timescale = view.getUint32(content + 20); const duration = readU64(content + 24);
          if (timescale > 0) return Math.round(duration * 1000 / timescale);
        }
      }
      offset += size;
    }
    return null;
  }
  return scan(0, bytes.byteLength);
}
