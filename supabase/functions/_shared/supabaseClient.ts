import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

// Nova chave secret (nao e JWT) - leitura do objeto JSON
function getSecretKey(): string {
  const secretKeys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (secretKeys) {
    return JSON.parse(secretKeys)["default"];
  }
  // Fallback para legado (descontinuado em 2026)
  return Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
}

export function getSupabaseClient() {
  return createClient(supabaseUrl, getSecretKey(), {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
