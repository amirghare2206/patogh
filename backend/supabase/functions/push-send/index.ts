import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const body = await req.json();

  const pushApiUrl = Deno.env.get("PUSH_API_URL");
  const pushApiToken = Deno.env.get("PUSH_API_TOKEN");

  if (!pushApiUrl || !pushApiToken) {
    return new Response(
      JSON.stringify({ error: "PUSH_PROVIDER_NOT_CONFIGURED" }),
      { status: 503, headers: { "content-type": "application/json" } },
    );
  }

  const response = await fetch(pushApiUrl, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "authorization": `Bearer ${pushApiToken}`,
    },
    body: JSON.stringify(body),
  });

  return new Response(
    await response.text(),
    {
      status: response.status,
      headers: { "content-type": "application/json" },
    },
  );
});
