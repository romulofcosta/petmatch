# 03 - Edge Functions - Logica de Negocio

## Visao Geral

As Edge Functions rodam no servidor da Supabase (Deno Runtime) e implementam toda a logica de negocio do PetMatch.

---

## 1. Estrutura de Pastas

```
supabase/functions/
├── _shared/
│   ├── supabaseClient.ts
│   ├── authMiddleware.ts
│   ├── cors.ts
│   ├── validators.ts
│   ├── geolocation.ts
│   ├── notifications.ts
│   └── types.ts
│
├── create-profile/
│   └── index.ts
├── process-swipe/
│   └── index.ts
├── send-message/
│   └── index.ts
├── send-push/
│   └── index.ts
├── nearby-pets/
│   └── index.ts
├── create-report/
│   └── index.ts
├── export-user-data/
│   └── index.ts
├── delete-account/
│   └── index.ts
└── moderate-message/
    └── index.ts
```

---

## 2. Codigo Compartilhado (_shared/)

### 2.1 types.ts

```typescript
export interface User {
  uid: string;
  email: string;
  display_name: string;
  photo_url?: string;
  phone?: string;
  birth_date: string;
  location: { type: "Point"; coordinates: [number, number] };
  geohash: string;
  city: string;
  state: string;
  country: string;
  preferences: UserPreferences;
  subscription: UserSubscription;
  stats: UserStats;
  is_active: boolean;
  is_verified: boolean;
  is_banned: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserPreferences {
  notifications: { push: boolean; email: boolean };
  distance_radius: number;
  interest_filter: string[];
}

export interface UserSubscription {
  plan: "free" | "premium_monthly" | "premium_yearly";
  status: "active" | "cancelled" | "expired";
  expires_at?: string;
}

export interface UserStats {
  total_matches: number;
  total_messages: number;
  profile_views: number;
}

export interface Pet {
  id: string;
  owner_id: string;
  name: string;
  type: "dog" | "cat";
  sex: "male" | "female";
  breed: string;
  breed_group: string;
  birth_date: string;
  age_months: number;
  weight_kg?: number;
  description?: string;
  personality_tags: string[];
  interests: ("socialization" | "breeding" | "adoption")[];
  main_photo_url: string;
  photos: string[];
  location: { type: "Point"; coordinates: [number, number] };
  geohash: string;
  veterinary?: VeterinaryData;
  is_active: boolean;
  is_banned: boolean;
  created_at: string;
}

export interface VeterinaryData {
  is_neutered?: boolean;
  is_vaccinated?: boolean;
  has_pedigree?: boolean;
  vet_name?: string;
  vet_phone?: string;
  health_notes?: string;
}

export interface Swipe {
  id: string;
  swiper_id: string;
  swiped_pet_id: string;
  swiped_owner_id: string;
  action: "like" | "superlike" | "pass";
  created_at: string;
}

export interface Match {
  id: string;
  user1_id: string;
  user1_pet_id: string;
  user2_id: string;
  user2_pet_id: string;
  matched_via: "like" | "superlike";
  status: "active" | "unmatched" | "blocked";
  created_at: string;
}

export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  type: "text" | "photo" | "location" | "audio" | "video";
  content: string;
  metadata?: Record<string, unknown>;
  is_read: boolean;
  created_at: string;
}

export interface Conversation {
  id: string;
  match_id: string;
  participants: string[];
  status: "active" | "archived";
  last_message?: {
    text: string;
    sender_id: string;
    timestamp: string;
  };
  unread_count_user1: number;
  unread_count_user2: number;
  created_at: string;
}

export interface Report {
  id: string;
  reporter_id: string;
  type: "user" | "pet" | "message";
  target_id: string;
  category: string;
  description?: string;
  evidence_urls: string[];
  status: "pending" | "reviewed" | "resolved" | "dismissed";
  created_at: string;
}

export interface AuditLog {
  id: string;
  user_id: string;
  action: string;
  resource: string;
  resource_id?: string;
  details?: Record<string, unknown>;
  ip_address: string;
  user_agent?: string;
  created_at: string;
}

export interface ConsentLog {
  id: string;
  user_id: string;
  consent_type: string;
  purpose: string;
  granted: boolean;
  ip_address: string;
  version: string;
  created_at: string;
}

export type AppError = {
  message: string;
  code: string;
  status: number;
};
```

### 2.2 supabaseClient.ts

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

export function getSupabaseClient() {
  return createClient(supabaseUrl, supabaseServiceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
```

### 2.3 authMiddleware.ts

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { User } from "./types.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

export async function authenticateRequest(
  req: Request
): Promise<{ user: User; token: string } | null> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) return null;

  const token = authHeader.replace("Bearer ", "");
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });

  const { data: { user: authUser }, error } = await supabase.auth.getUser();
  if (error || !authUser) return null;

  const { data: userProfile } = await supabase
    .from("users").select("*").eq("uid", authUser.id).single();

  if (!userProfile) return null;
  return { user: userProfile as User, token };
}
```

### 2.4 cors.ts

```typescript
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
};

export function handleCors(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  return null;
}
```

### 2.5 validators.ts

```typescript
import type { AppError } from "./types.ts";

export function validatePetAge(birthDate: string): {
  valid: boolean; ageMonths: number; error?: string;
} {
  const birth = new Date(birthDate);
  const now = new Date();
  const ageMonths = (now.getFullYear() - birth.getFullYear()) * 12 +
    (now.getMonth() - birth.getMonth());
  if (ageMonths < 4) {
    return { valid: false, ageMonths, error: "Pet deve ter pelo menos 4 meses" };
  }
  return { valid: true, ageMonths };
}

export function validateUserAge(birthDate: string): {
  valid: boolean; age: number; error?: string;
} {
  const birth = new Date(birthDate);
  const now = new Date();
  let age = now.getFullYear() - birth.getFullYear();
  const m = now.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age--;
  if (age < 18) return { valid: false, age, error: "Tutor deve ter pelo menos 18 anos" };
  return { valid: true, age };
}

export function validateGeoPoint(lat: number, lng: number): { valid: boolean; error?: string } {
  if (lat < -90 || lat > 90) return { valid: false, error: "Latitude invalida" };
  if (lng < -180 || lng > 180) return { valid: false, error: "Longitude invalida" };
  return { valid: true };
}

export function createError(message: string, code: string, status: number): AppError {
  return { message, code, status };
}
```

### 2.6 geolocation.ts

```typescript
const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";

export function encodeGeohash(lat: number, lng: number, precision: number = 9): string {
  let minLat = -90, maxLat = 90, minLng = -180, maxLng = 180;
  let geohash = "", bit = 0, ch = 0, isLng = true;
  while (geohash.length < precision) {
    if (isLng) {
      const mid = (minLng + maxLng) / 2;
      if (lng >= mid) { ch |= 1 << (4 - bit); minLng = mid; } else { maxLng = mid; }
    } else {
      const mid = (minLat + maxLat) / 2;
      if (lat >= mid) { ch |= 1 << (4 - bit); minLat = mid; } else { maxLat = mid; }
    }
    isLng = !isLng;
    if (bit < 4) { bit++; } else { geohash += BASE32[ch]; bit = 0; ch = 0; }
  }
  return geohash;
}
```

### 2.7 notifications.ts

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const fcmServerKey = Deno.env.get("FCM_SERVER_KEY")!;

export async function sendPushNotification(payload: {
  token: string; title: string; body: string;
  data?: Record<string, string>; imageUrl?: string;
}): Promise<boolean> {
  if (!fcmServerKey) return false;
  try {
    const message = {
      to: payload.token,
      notification: { title: payload.title, body: payload.body,
        ...(payload.imageUrl && { image: payload.imageUrl }) },
      data: payload.data || {}, priority: "high",
    };
    const res = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: { Authorization: `key=${fcmServerKey}`, "Content-Type": "application/json" },
      body: JSON.stringify(message),
    });
    return res.ok;
  } catch { return false; }
}

export async function notifyNewMatch(userId: string, matchedUserName: string,
  matchedPetName: string, matchedPetPhoto: string): Promise<void> {
  const supabase = createClient(supabaseUrl, supabaseServiceKey);
  const { data } = await supabase.from("users").select("fcm_token").eq("uid", userId).single();
  if (data?.fcm_token) {
    await sendPushNotification({ token: data.fcm_token, title: "Novo Match!",
      body: `Voce e ${matchedPetName} deram match!`, imageUrl: matchedPetPhoto,
      data: { type: "match", screen: "matches" } });
  }
  await supabase.from("notifications").insert({
    user_id: userId, type: "match", title: "Novo Match!",
    body: `Voce e ${matchedPetName} deram match!`, data: { screen: "matches" } });
}
```

---

## 3. Edge Functions Principais

### 3.1 create-profile/

Cria perfil apos signup com validacao de idade e consentimento LGPD.

**Endpoint:** `POST /functions/v1/create-profile`

**Request:**
```json
{
  "uid": "uuid",
  "email": "user@email.com",
  "display_name": "Joao Silva",
  "birth_date": "1990-01-15",
  "latitude": -23.5505,
  "longitude": -46.6333,
  "city": "Sao Paulo",
  "state": "SP"
}
```

**Logica:**
1. Valida campos obrigatorios
2. Valida idade do usuario (18+)
3. Valida localizacao
4. Verifica se perfil ja existe
5. Calcula geohash
6. Insere na tabela users
7. Registra consentimentos LGPD
8. Registra audit log

### 3.2 process-swipe/

Processa swipe com verificacao de limites, match e notificacoes.

**Endpoint:** `POST /functions/v1/process-swipe`

**Request:**
```json
{
  "pet_id": "uuid",
  "action": "like|superlike|pass"
}
```

**Logica:**
1. Autentica usuario
2. Verifica se pet existe e esta ativo
3. Verifica se nao e proprio pet
4. Verifica se ja existe swipe
5. Verifica limites diarios (free: 20 likes, 1 super like)
6. Registra swipe
7. Verifica reciprocidade (match)
8. Se match: cria registro + conversa + notifica ambos
9. Se superlike sem match: notifica destinatario
10. Registra audit log

### 3.3 send-message/

Envia mensagem com moderacao e limites.

**Endpoint:** `POST /functions/v1/send-message`

**Request:**
```json
{
  "conversation_id": "uuid",
  "type": "text|photo|location|audio|video",
  "content": "Mensagem",
  "metadata": {}
}
```

**Logica:**
1. Autentica usuario
2. Verifica se e participante da conversa
3. Verifica limites de mensagens (free: 50/dia)
4. Verifica tipo de midia permitido
5. Moderacao de conteudo (links, telefones, ofensas)
6. Insere mensagem
7. Envia notificacao push (se app fechado)
8. Registra audit log

### 3.4 nearby-pets/

Busca pets por proximidade com filtros.

**Endpoint:** `POST /functions/v1/nearby-pets`

**Request:**
```json
{
  "latitude": -23.5505,
  "longitude": -46.6333,
  "radius_km": 30,
  "type": "dog",
  "breed": "Labrador",
  "sex": "female",
  "interest": "breeding",
  "limit": 50,
  "offset": 0
}
```

**Logica:**
1. Autentica usuario
2. Executa query PostGIS com filtros
3. Exclui pets ja visualizados
4. Exclui proprio pet
5. Ordena por distancia
6. Retorna lista com distancia calculada

---

## 4. Seguranca

### 4.1 Autenticacao
- Todas as Edge Functions exigem JWT valido
- Service role key usada apenas no servidor

### 4.2 Rate Limiting
- Max 100 requisicoes/minuto por usuario
- Max 1000 requisicoes/minuto total

### 4.3 Validacao de Input
- Todos os campos validados antes de processar
- SQL injection prevenido via parameterized queries

---

## 5. Monitoramento

| Metrica | Descricao |
|---------|-----------|
| Tempo medio de resposta | < 200ms |
| Taxa de erros | < 1% |
| Disponibilidade | 99.9% |
