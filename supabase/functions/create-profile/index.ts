import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getSupabaseClient } from "../_shared/supabaseClient.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { validateUserAge, validateGeoPoint, createError } from "../_shared/validators.ts";
import { encodeGeohash } from "../_shared/geolocation.ts";

interface CreateProfileRequest {
  uid: string;
  display_name: string;
  birth_date: string;
  latitude: number;
  longitude: number;
  city: string;
  state: string;
  consents?: Record<string, boolean>;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const body: CreateProfileRequest = await req.json();
    const { uid, display_name, birth_date, latitude, longitude, city, state, consents } = body;

    if (!uid || !display_name || !birth_date || latitude == null || longitude == null || !city || !state) {
      return new Response(
        JSON.stringify(createError("Campos obrigatórios faltando", "MISSING_FIELDS", 400)),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const ageValidation = validateUserAge(birth_date);
    if (!ageValidation.valid) {
      return new Response(
        JSON.stringify(createError(ageValidation.error!, "INVALID_AGE", 400)),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const geoValidation = validateGeoPoint(latitude, longitude);
    if (!geoValidation.valid) {
      return new Response(
        JSON.stringify(createError(geoValidation.error!, "INVALID_GEO", 400)),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = getSupabaseClient();
    const geohash = encodeGeohash(latitude, longitude);
    const now = new Date().toISOString();

    const { data: existingUser } = await supabase
      .from("users")
      .select("uid")
      .eq("uid", uid)
      .maybeSingle();

    if (existingUser) {
      return new Response(
        JSON.stringify(createError("Perfil já existe", "PROFILE_EXISTS", 409)),
        { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const locationPoint = `POINT(${longitude} ${latitude})`;

    const { data: userProfile, error: insertError } = await supabase
      .from("users")
      .insert({
        uid,
        display_name,
        birth_date,
        city,
        state,
        country: "BR",
        location: locationPoint,
        geohash,
        preferences: {
          notifications: { push: true, email: false },
          distance_radius: 30,
          interest_filter: [],
        },
        subscription: { plan: "free", status: "active" },
        stats: { total_matches: 0, total_messages: 0, profile_views: 0 },
        is_active: true,
        is_verified: false,
        created_at: now,
        updated_at: now,
      })
      .select()
      .single();

    if (insertError) {
      console.error("Error creating user profile:", insertError);
      return new Response(
        JSON.stringify(createError("Erro ao criar perfil", "CREATE_FAILED", 500)),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (consents && Object.keys(consents).length > 0) {
      const consentRecords = Object.entries(consents).map(([type, granted]) => ({
        user_id: uid,
        consent_type: type,
        purpose: `Consentimento para ${type}`,
        granted,
        ip_address: req.headers.get("x-forwarded-for") || "0.0.0.0",
        user_agent: req.headers.get("user-agent") || "",
        version: "1.0",
        created_at: now,
      }));

      await supabase.from("consent_logs").insert(consentRecords);
    }

    return new Response(
      JSON.stringify({ user: userProfile }),
      {
        status: 201,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify(createError("Erro interno do servidor", "INTERNAL_ERROR", 500)),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
