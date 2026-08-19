import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

// Chave publishable para operacoes publicas (leitura de dados com RLS)
function getPublishableKey(): string {
  const publishableKeys = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
  if (publishableKeys) {
    return JSON.parse(publishableKeys)["default"];
  }
  return Deno.env.get("SUPABASE_ANON_KEY")!;
}

export function getPublicClient() {
  return createClient(supabaseUrl, getPublishableKey());
}
