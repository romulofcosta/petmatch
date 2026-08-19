import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { User } from "./types.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

// Chave publishable (nao e JWT) - leitura do objeto JSON
function getPublishableKey(): string {
  const publishableKeys = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
  if (publishableKeys) {
    return JSON.parse(publishableKeys)["default"];
  }
  // Fallback para legado (descontinuado em 2026)
  return Deno.env.get("SUPABASE_ANON_KEY")!;
}

export async function authenticateRequest(
  req: Request
): Promise<{ user: User; token: string } | null> {
  const authHeader = req.headers.get("Authorization");
  const apiKey = req.headers.get("apikey");

  // Chave publishable enviada via header "apikey"
  const token = apiKey || authHeader?.replace("Bearer ", "");
  if (!token) return null;

  const supabase = createClient(supabaseUrl, getPublishableKey(), {
    global: { headers: { apikey: token } },
  });

  const { data: { user: authUser }, error } = await supabase.auth.getUser();
  if (error || !authUser) return null;

  const { data: userProfile } = await supabase
    .from("users").select("*").eq("uid", authUser.id).single();

  if (!userProfile) return null;
  return { user: userProfile as User, token };
}
