// Supabase Edge Function: "chat"
// Securely proxies the AI assistant so your Anthropic API key never reaches the browser.
//
// Deploy:   supabase functions deploy chat --no-verify-jwt
// Secret:   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
// (SUPABASE_URL and SUPABASE_ANON_KEY are provided automatically.)

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "content-type": "application/json" },
  });
}

function buildSystem(content: any): string {
  const list = (content?.assemblies || [])
    .map((x: any) => `- ${x.name} (est. ${x.est}, Presiding Elder: ${x.pe}, ~${x.adults} adults & ${x.children} children): ${x.hist}`)
    .join("\n");
  const pastor = content?.executives?.[0]?.name || "the District Pastor";
  return `You are the warm, friendly digital assistant for The Church of Pentecost, Anyaa District — part of the Anyaa Ablekuma Area in Accra, Ghana.
The district was founded on 23rd October 1994 and became a District seat on 4th September 2004. The current District Pastor is ${pastor}.
There are SIX local assemblies. Sunday Worship begins at 9:00 AM in every assembly. Midweek Service is Wednesday 6:00 PM, Prayer Meeting Friday 6:00 PM, Youth Service Saturday 4:00 PM.
The assemblies:
${list}
The Church of Pentecost is a worldwide non-denominational Pentecostal church founded on biblical principles, emphasising prayer, sound Bible teaching, holiness and evangelism.
Help visitors warmly: answer about service times, the assemblies and their history, leadership, how to join or sign up, salvation and faith, prayer, and church activities. You may share encouragement and relevant Bible verses. Keep answers warm, concise (2-4 sentences) and respectful. For details you don't have (phone numbers, exact addresses, specific names not listed), invite them to use the WhatsApp button, email ${content?.email || "the church"}, or visit an assembly. Never invent specific personal details.`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  try {
    const { messages } = await req.json();
    if (!Array.isArray(messages) || messages.length === 0) {
      return json({ error: "No message provided." }, 400);
    }

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) return json({ error: "The assistant is not configured yet (missing API key)." }, 503);

    // Load the latest site content (public-readable) for an accurate system prompt
    let content: any = {};
    try {
      const url = Deno.env.get("SUPABASE_URL");
      const anon = Deno.env.get("SUPABASE_ANON_KEY");
      const r = await fetch(`${url}/rest/v1/site_content?id=eq.1&select=data`, {
        headers: { apikey: anon!, Authorization: `Bearer ${anon}` },
      });
      const rows = await r.json();
      content = rows?.[0]?.data || {};
    } catch (_) { /* fall back to empty content */ }

    const resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: Deno.env.get("ANTHROPIC_MODEL") || "claude-sonnet-4-20250514",
        max_tokens: 1000,
        system: buildSystem(content),
        messages: messages.slice(-20).map((m: any) => ({
          role: m.role === "assistant" ? "assistant" : "user",
          content: String(m.content || ""),
        })),
      }),
    });

    const data = await resp.json();
    if (!resp.ok) return json({ error: data?.error?.message || "Assistant error." }, 502);
    const reply = (data.content || []).map((b: any) => (b.type === "text" ? b.text : "")).join("\n").trim();
    return json({ reply: reply || "I'm sorry, I couldn't respond just now." });
  } catch (_e) {
    return json({ error: "Could not reach the assistant." }, 502);
  }
});
