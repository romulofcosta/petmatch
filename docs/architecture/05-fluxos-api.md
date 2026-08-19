# 05 - Fluxos de API

## Visao Geral

Todos os endpoints sao servidos por Edge Functions no Supabase. Base URL: `https://<project-ref>.supabase.co/functions/v1/`

**Headers obrigatorios em todas as requisicoes:**
```
Authorization: Bearer <jwt_token>
apikey: <supabase_anon_key>
Content-Type: application/json
```

---

## 1. Autenticacao

### POST /create-profile
Cria perfil apos cadastro no Supabase Auth.

**Request:**
```json
{
  "uid": "uuid-do-auth",
  "email": "joao@email.com",
  "display_name": "Joao Silva",
  "birth_date": "1990-01-15",
  "latitude": -23.5505,
  "longitude": -46.6333,
  "city": "Sao Paulo",
  "state": "SP",
  "consents": {
    "terms_of_use": true,
    "privacy_policy": true,
    "data_sharing": false
  }
}
```

**Response 201:**
```json
{
  "user": { "uid": "...", "display_name": "Joao Silva", "city": "Sao Paulo" },
  "message": "Perfil criado com sucesso"
}
```

**Errors:**
| Codigo | Mensagem |
|--------|----------|
| 400 | Campos obrigatorios faltando |
| 422 | Idade minima: 18 anos |
| 409 | Perfil ja existe |

---

## 2. Feed e Descoberta

### POST /nearby-pets
Busca pets por proximidade com filtros.

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
  "min_age_months": 6,
  "max_age_months": 48,
  "limit": 20,
  "offset": 0
}
```

**Response 200:**
```json
{
  "pets": [
    {
      "id": "pet-uuid",
      "name": "Luna",
      "type": "dog",
      "breed": "Labrador Retriever",
      "sex": "female",
      "age_months": 12,
      "main_photo_url": "https://...",
      "distance_km": 3.5,
      "interests": ["socialization", "breeding"]
    }
  ],
  "total": 45,
  "has_more": true
}
```

---

## 3. Matching

### POST /process-swipe
Registra like, super like ou pass.

**Request:**
```json
{
  "pet_id": "pet-uuid-daoutrapessoa",
  "action": "like"
}
```

**Response 200 (like sem match):**
```json
{ "matched": false, "action": "like" }
```

**Response 200 (match!):**
```json
{
  "matched": true,
  "match": {
    "id": "match-uuid",
    "matched_user": { "name": "Maria", "photo": "https://..." },
    "matched_pet": { "name": "Thor", "photo": "https://..." },
    "matched_via": "like"
  }
}
```

**Errors:**
| Codigo | Mensagem |
|--------|----------|
| 400 | Pet invalido |
| 403 | Ja existe swipe para este pet |
| 429 | Limite diario atingido (free: 20 likes) |
| 429 | Limite de super likes atingido (free: 1/dia) |

### GET /matches
Lista matches do usuario.

**Response 200:**
```json
{
  "matches": [
    {
      "id": "match-uuid",
      "matched_user": { "name": "Maria", "photo": "https://..." },
      "matched_pet": { "name": "Thor", "photo": "https://..." },
      "matched_via": "like",
      "created_at": "2025-01-15T10:30:00Z",
      "last_message": { "text": "Ola!", "timestamp": "..." }
    }
  ]
}
```

### DELETE /matches/:id
Desfaz match.

**Response 200:**
```json
{ "message": "Match desfeito" }
```

---

## 4. Chat

### GET /conversations
Lista conversas do usuario.

**Response 200:**
```json
{
  "conversations": [
    {
      "id": "conv-uuid",
      "other_user": { "name": "Maria", "photo": "https://..." },
      "other_pet": { "name": "Thor", "photo": "https://..." },
      "last_message": { "text": "Tudo bem?", "sender": "me", "timestamp": "..." },
      "unread_count": 2
    }
  ]
}
```

### GET /conversations/:id/messages
Lista mensagens de uma conversa.

**Query params:** `limit=50`, `before=<message_id>`

**Response 200:**
```json
{
  "messages": [
    {
      "id": "msg-uuid",
      "sender_id": "user-uuid",
      "type": "text",
      "content": "Oi, tudo bem?",
      "is_read": true,
      "created_at": "2025-01-15T10:30:00Z"
    }
  ],
  "has_more": true
}
```

### POST /send-message
Envia mensagem.

**Request:**
```json
{
  "conversation_id": "conv-uuid",
  "type": "text",
  "content": "Ola! Seu pet e muito fofo!"
}
```

**Response 201:**
```json
{
  "message": {
    "id": "msg-uuid",
    "type": "text",
    "content": "Ola! Seu pet e muito fofo!",
    "created_at": "2025-01-15T10:31:00Z"
  }
}
```

**Errors:**
| Codigo | Mensagem |
|--------|----------|
| 403 | Nao e participante desta conversa |
| 429 | Limite de mensagens atingido (free: 50/dia) |
| 422 | Conteudo inadequado detectado |

---

## 5. Notificacoes

### GET /notifications
Lista notificacoes do usuario.

**Response 200:**
```json
{
  "notifications": [
    {
      "id": "notif-uuid",
      "type": "match",
      "title": "Novo Match!",
      "body": "Voce e Luna deram match!",
      "is_read": false,
      "created_at": "2025-01-15T10:30:00Z"
    }
  ],
  "unread_count": 3
}
```

### PATCH /notifications/:id/read
Marca notificacao como lida.

**Response 200:**
```json
{ "message": "Notificacao marcada como lida" }
```

---

## 6. Denuncias

### POST /reports
Cria denuncia.

**Request:**
```json
{
  "type": "user",
  "target_id": "user-uuid",
  "category": "inappropriate_content",
  "description": "Perfil com conteudo ofensivo",
  "evidence_urls": ["https://..."]
}
```

**Response 201:**
```json
{ "report_id": "report-uuid", "message": "Denuncia registrada" }
```

**Categories:** `inappropriate_content`, `fake_profile`, `spam`, `harassment`, `animal_abuse`, `underage`, `other`

---

## 7. Perfil

### PATCH /users/me
Atualiza perfil do usuario.

**Request:**
```json
{
  "display_name": "Joao S.",
  "city": "Campinas",
  "state": "SP",
  "preferences": {
    "distance_radius": 50,
    "interest_filter": ["socialization"]
  }
}
```

### GET /users/me
Retorna perfil completo.

### DELETE /users/me
Deleta conta (LGPD). Soft delete + agendamento de remocao em 30 dias.

---

## 8. Privacidade (LGPD)

### POST /export-user-data
Solicita exportacao de dados pessoais.

**Response 202:**
```json
{ "message": "Exportacao solicitada. Voce recebera um email em ate 15 dias." }
```

---

## 9. Rate Limiting

| Endpoint | Limite | Periodo |
|----------|--------|---------|
| Todos | 100 req | 1 minuto |
| /process-swipe | 30 req | 1 minuto |
| /send-message | 60 req | 1 minuto |
| /nearby-pets | 20 req | 1 minuto |
| /create-report | 5 req | 1 minuto |
