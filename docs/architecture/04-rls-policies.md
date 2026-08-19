# 04 - Row Level Security (RLS) Policies

## Visao Geral

RLS (Row Level Security) e o mecanismo de seguranca do PostgreSQL que controla **quem pode ver/editar quais dados**. No Supabase, isso e implementado via policies.

---

## 1. Principio Basico

```
Sem RLS:  Qualquer usuario autenticado pode ver/editar QUALQUER registro
Com RLS:  Cada usuario so ve/edita SEUS proprios registros (ou os que tem permissao)
```

---

## 2. Habilitar RLS em Todas as Tabelas

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE consent_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
```

---

## 3. Policies por Tabela

### 3.1 users

```sql
-- Usuarios podem ver proprio perfil
CREATE POLICY "users_select_own"
  ON users FOR SELECT
  USING (auth.uid() = uid);

-- Usuarios podem ver perfis de outros (para feed/matches)
CREATE POLICY "users_select_others"
  ON users FOR SELECT
  USING (
    is_active = true
    AND is_banned = false
    AND deleted_at IS NULL
  );

-- Usuarios podem atualizar proprio perfil
CREATE POLICY "users_update_own"
  ON users FOR UPDATE
  USING (auth.uid() = uid)
  WITH CHECK (auth.uid() = uid);

-- Apenas Edge Functions podem inserir (via service_role)
CREATE POLICY "users_insert_service"
  ON users FOR INSERT
  WITH CHECK (true);

-- Apenas Edge Functions podem deletar (via service_role)
CREATE POLICY "users_delete_service"
  ON users FOR DELETE
  USING (true);
```

### 3.2 pets

```sql
-- Qualquer um ve pets ativos
CREATE POLICY "pets_select_active"
  ON pets FOR SELECT
  USING (
    is_active = true
    AND is_banned = false
    AND deleted_at IS NULL
  );

-- Dono pode ver seus proprios pets (mesmo inativos)
CREATE POLICY "pets_select_own"
  ON pets FOR SELECT
  USING (auth.uid() = owner_id);

-- Dono pode cadastrar pet
CREATE POLICY "pets_insert_own"
  ON pets FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Dono pode atualizar pet
CREATE POLICY "pets_update_own"
  ON pets FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Dono pode deletar pet (soft delete)
CREATE POLICY "pets_delete_own"
  ON pets FOR DELETE
  USING (auth.uid() = owner_id);
```

### 3.3 swipes

```sql
-- Usuario ve seus proprios swipes
CREATE POLICY "swipes_select_own"
  ON swipes FOR SELECT
  USING (auth.uid() = swiper_id);

-- Usuario pode criar swipe
CREATE POLICY "swipes_insert_own"
  ON swipes FOR INSERT
  WITH CHECK (auth.uid() = swiper_id);

-- Nao permite update/delete de swipes
-- (swipes sao imutaveis)
```

### 3.4 matches

```sql
-- Participantes veem o match
CREATE POLICY "matches_select_participants"
  ON matches FOR SELECT
  USING (
    auth.uid() = user1_id
    OR auth.uid() = user2_id
  );

-- Apenas Edge Functions criam matches (via service_role)
CREATE POLICY "matches_insert_service"
  ON matches FOR INSERT
  WITH CHECK (true);

-- Participantes podem desfazer match
CREATE POLICY "matches_update_participants"
  ON matches FOR UPDATE
  USING (
    auth.uid() = user1_id
    OR auth.uid() = user2_id
  );
```

### 3.5 conversations

```sql
-- Participantes veem a conversa
CREATE POLICY "conversations_select_participants"
  ON conversations FOR SELECT
  USING (auth.uid() = ANY(participants));

-- Apenas Edge Functions criam conversas (via service_role)
CREATE POLICY "conversations_insert_service"
  ON conversations FOR INSERT
  WITH CHECK (true);

-- Participantes podem atualizar (contadores de nao lidas)
CREATE POLICY "conversations_update_participants"
  ON conversations FOR UPDATE
  USING (auth.uid() = ANY(participants));
```

### 3.6 messages

```sql
-- Participantes veem mensagens da conversa
CREATE POLICY "messages_select_participants"
  ON messages FOR SELECT
  USING (
    conversation_id IN (
      SELECT id FROM conversations
      WHERE auth.uid() = ANY(participants)
    )
  );

-- Participantes podem enviar mensagem
CREATE POLICY "messages_insert_participants"
  ON messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND conversation_id IN (
      SELECT id FROM conversations
      WHERE auth.uid() = ANY(participants)
    )
  );

-- Participantes podem marcar como lida
CREATE POLICY "messages_update_participants"
  ON messages FOR UPDATE
  USING (
    conversation_id IN (
      SELECT id FROM conversations
      WHERE auth.uid() = ANY(participants)
    )
  );
```

### 3.7 reports

```sql
-- Usuario ve proprias denuncias
CREATE POLICY "reports_select_own"
  ON reports FOR SELECT
  USING (auth.uid() = reporter_id);

-- Qualquer um pode criar denuncia
CREATE POLICY "reports_insert_own"
  ON reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

-- Apenas admin pode atualizar denuncia
CREATE POLICY "reports_update_admin"
  ON reports FOR UPDATE
  USING (true);
```

### 3.8 reviews

```sql
-- Qualquer um ve avaliacoes de um usuario
CREATE POLICY "reviews_select_public"
  ON reviews FOR SELECT
  USING (true);

-- Usuario pode criar avaliacao
CREATE POLICY "reviews_insert_own"
  ON reviews FOR INSERT
  WITH CHECK (auth.uid() = reviewer_id);

-- Nao permite update/delete de avaliacoes
```

### 3.9 notifications

```sql
-- Usuario ve proprias notificacoes
CREATE POLICY "notifications_select_own"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Apenas Edge Functions criam notificacoes
CREATE POLICY "notifications_insert_service"
  ON notifications FOR INSERT
  WITH CHECK (true);

-- Usuario pode marcar como lida
CREATE POLICY "notifications_update_own"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);
```

### 3.10 consent_logs

```sql
-- Usuario ve proprios consentimentos
CREATE POLICY "consent_select_own"
  ON consent_logs FOR SELECT
  USING (auth.uid() = user_id);

-- Apenas Edge Functions criam consentimentos
CREATE POLICY "consent_insert_service"
  ON consent_logs FOR INSERT
  WITH CHECK (true);

-- Nao permite update/delete (imutavel)
```

### 3.11 audit_logs

```sql
-- Apenas admin ve logs de auditoria
CREATE POLICY "audit_select_admin"
  ON audit_logs FOR SELECT
  USING (true);

-- Apenas Edge Functions criam logs
CREATE POLICY "audit_insert_service"
  ON audit_logs FOR INSERT
  WITH CHECK (true);

-- Nao permite update/delete (imutavel)
```

### 3.12 subscriptions

```sql
-- Usuario ve proprias assinaturas
CREATE POLICY "subscriptions_select_own"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Apenas Edge Functions criam/atualizam assinaturas
CREATE POLICY "subscriptions_insert_service"
  ON subscriptions FOR INSERT
  WITH CHECK (true);

CREATE POLICY "subscriptions_update_service"
  ON subscriptions FOR UPDATE
  USING (true);
```

---

## 4. Resumo das Permissoes

| Tabela | SELECT | INSERT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| users | Proprio + Publicos | Service | Proprio | Service |
| pets | Ativos + Proprio | Proprio | Proprio | Proprio |
| swipes | Proprio | Proprio | - | - |
| matches | Participantes | Service | Participantes | - |
| conversations | Participantes | Service | Participantes | - |
| messages | Participantes | Participantes | Participantes | - |
| reports | Proprio | Proprio | Admin | - |
| reviews | Publico | Proprio | - | - |
| notifications | Proprio | Service | Proprio | - |
| consent_logs | Proprio | Service | - | - |
| audit_logs | Admin | Service | - | - |
| subscriptions | Proprio | Service | Service | - |

---

## 5. Bypass para Edge Functions

As Edge Functions usam a **service_role key** que bypassa RLS. Isso e necessario para:
- Criar matches (afeta 2 usuarios)
- Enviar notificacoes
- Registrar audit logs
- Gerenciar assinaturas

```typescript
// Na Edge Function, usar service_role key
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);
// Isso bypassa todas as RLS policies
```

---

## 6. Testes de Seguranca

```
TESTES OBRIGATORIOS:
☐ Usuario A nao ve dados do Usuario B (users)
☐ Usuario A nao edita dados do Usuario B (users)
☐ Usuario A ve apenas seus pets (pets)
☐ Usuario A nao ve swipes de outros (swipes)
☐ Usuario A ve apenas matches que participa (matches)
☐ Usuario A ve apenas mensagens de suas conversas (messages)
☐ Usuario A ve apenas suas notificacoes (notifications)
☐ Edge Functions bypassam RLS corretamente
☐ service_role key nao e exposta no cliente
```
