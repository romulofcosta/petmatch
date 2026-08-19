# 02 - Banco de Dados - Schema Completo

## Visao Geral

O PetMatch utiliza PostgreSQL com extensao PostGIS para geolocalizacao. O schema abaixo esta em conformidade com todas as regras de negocio e compliance.

---

## 1. Tabelas Principais

### 1.1 users (Tutores)

```sql
CREATE TABLE users (
    uid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    photo_url TEXT,
    phone VARCHAR(20),
    birth_date DATE NOT NULL,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    geohash VARCHAR(12) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state CHAR(2) NOT NULL,
    country CHAR(2) DEFAULT 'BR',
    preferences JSONB DEFAULT '{}',
    subscription JSONB DEFAULT '{}',
    stats JSONB DEFAULT '{}',
    fcm_token TEXT,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    is_banned BOOLEAN DEFAULT false,
    ban_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_active_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_users_geohash ON users(geohash);
CREATE INDEX idx_users_location ON users USING GIST(location);
CREATE INDEX idx_users_active ON users(is_active, is_banned);
CREATE INDEX idx_users_city_state ON users(city, state);
```

### 1.2 pets (Animais)

```sql
CREATE TABLE pets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(uid),
    name VARCHAR(30) NOT NULL,
    type VARCHAR(10) NOT NULL CHECK (type IN ('dog', 'cat')),
    sex VARCHAR(10) NOT NULL CHECK (sex IN ('male', 'female')),
    breed VARCHAR(100) NOT NULL,
    breed_group VARCHAR(20) NOT NULL,
    birth_date DATE NOT NULL,
    age_months INT GENERATED ALWAYS AS (
        (EXTRACT(YEAR FROM age(birth_date)) * 12 + EXTRACT(MONTH FROM age(birth_date)))::INT
    ) STORED,
    weight_kg DECIMAL(5,2),
    description TEXT CHECK (length(description) <= 500),
    personality_tags TEXT[] DEFAULT '{}',
    interests TEXT[] NOT NULL CHECK (array_length(interests, 1) > 0),
    main_photo_url TEXT NOT NULL,
    photos TEXT[] DEFAULT '{}',
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    geohash VARCHAR(12) NOT NULL,
    veterinary JSONB DEFAULT '{}',
    microchip_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    is_banned BOOLEAN DEFAULT false,
    ban_reason TEXT,
    compliance JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_birth_date CHECK (birth_date <= CURRENT_DATE - INTERVAL '120 days'),
    CONSTRAINT chk_interests CHECK (
        interests <@ ARRAY['socialization', 'breeding', 'adoption']
    )
);

CREATE INDEX idx_pets_owner ON pets(owner_id);
CREATE INDEX idx_pets_type ON pets(type);
CREATE INDEX idx_pets_breed ON pets(breed);
CREATE INDEX idx_pets_sex ON pets(sex);
CREATE INDEX idx_pets_location ON pets USING GIST(location);
CREATE INDEX idx_pets_geohash ON pets(geohash);
CREATE INDEX idx_pets_active ON pets(is_active, is_banned);
CREATE INDEX idx_pets_interests ON pets USING GIN(interests);
```

### 1.3 swipes (Curtidas/Passadas)

```sql
CREATE TABLE swipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    swiper_id UUID NOT NULL REFERENCES users(uid),
    swiped_pet_id UUID NOT NULL REFERENCES pets(id),
    swiped_owner_id UUID NOT NULL REFERENCES users(uid),
    action VARCHAR(10) NOT NULL CHECK (action IN ('like', 'superlike', 'pass')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(swiper_id, swiped_pet_id)
);

CREATE INDEX idx_swipes_swiper ON swipes(swiper_id, created_at);
CREATE INDEX idx_swipes_swiped ON swipes(swiped_pet_id);
CREATE INDEX idx_swipes_owner ON swipes(swiped_owner_id);
```

### 1.4 matches

```sql
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID NOT NULL REFERENCES users(uid),
    user1_pet_id UUID NOT NULL REFERENCES pets(id),
    user2_id UUID NOT NULL REFERENCES users(uid),
    user2_pet_id UUID NOT NULL REFERENCES pets(id),
    matched_via VARCHAR(10) NOT NULL CHECK (matched_via IN ('like', 'superlike')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'unmatched', 'blocked')),
    unmatched_by UUID REFERENCES users(uid),
    unmatched_at TIMESTAMPTZ,
    chat_started BOOLEAN DEFAULT false,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (user1_id < user2_id),
    UNIQUE(user1_id, user2_id)
);

CREATE INDEX idx_matches_user1 ON matches(user1_id, status);
CREATE INDEX idx_matches_user2 ON matches(user2_id, status);
CREATE INDEX idx_matches_status ON matches(status, created_at);
```

### 1.5 conversations (Conversas)

```sql
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL REFERENCES matches(id),
    participants UUID[] NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived')),
    last_message JSONB,
    unread_count_user1 INT DEFAULT 0,
    unread_count_user2 INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_participants ON conversations USING GIN(participants);
CREATE INDEX idx_conversations_status ON conversations(status);
```

### 1.6 messages (Mensagens)

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id),
    sender_id UUID NOT NULL REFERENCES users(uid),
    type VARCHAR(20) NOT NULL CHECK (type IN ('text', 'photo', 'location', 'audio', 'video')),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    is_flagged BOOLEAN DEFAULT false,
    flag_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_flagged ON messages(is_flagged) WHERE is_flagged = true;
```

### 1.7 reports (Denuncias)

```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES users(uid),
    type VARCHAR(20) NOT NULL CHECK (type IN ('user', 'pet', 'message')),
    target_id UUID NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    evidence_urls TEXT[] DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    resolution TEXT,
    action_taken TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status, created_at);
CREATE INDEX idx_reports_target ON reports(target_id, type);
```

### 1.8 reviews (Avaliacoes)

```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL REFERENCES matches(id),
    reviewer_id UUID NOT NULL REFERENCES users(uid),
    reviewed_user_id UUID NOT NULL REFERENCES users(uid),
    reviewed_pet_id UUID NOT NULL REFERENCES pets(id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT CHECK (length(comment) <= 300),
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(match_id, reviewer_id)
);

CREATE INDEX idx_reviews_user ON reviews(reviewed_user_id);
CREATE INDEX idx_reviews_match ON reviews(match_id);
```

### 1.9 notifications (Notificacoes)

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(uid),
    type VARCHAR(30) NOT NULL,
    title VARCHAR(100) NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at);
```

### 1.10 consent_logs (Consentimentos - LGPD)

```sql
CREATE TABLE consent_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(uid),
    consent_type VARCHAR(50) NOT NULL,
    purpose TEXT NOT NULL,
    granted BOOLEAN NOT NULL,
    ip_address INET NOT NULL,
    user_agent TEXT,
    version VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ
);

CREATE INDEX idx_consent_user ON consent_logs(user_id, consent_type);
```

### 1.11 audit_logs (Auditoria - LGPD)

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    resource VARCHAR(50) NOT NULL,
    resource_id UUID,
    details JSONB DEFAULT '{}',
    ip_address INET NOT NULL,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id, created_at);
CREATE INDEX idx_audit_action ON audit_logs(action, created_at);
CREATE INDEX idx_audit_resource ON audit_logs(resource, resource_id);
```

### 1.12 subscriptions (Assinaturas)

```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(uid),
    plan VARCHAR(30) NOT NULL CHECK (plan IN ('monthly', 'yearly')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'past_due')),
    amount INT NOT NULL,
    currency CHAR(3) DEFAULT 'BRL',
    payment_method VARCHAR(20) NOT NULL,
    payment_id VARCHAR(255) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status);
CREATE INDEX idx_subscriptions_expires ON subscriptions(expires_at) WHERE status = 'active';
```

---

## 2. Diagrama de Relacionamentos

```
users (1) ----< (N) pets
users (1) ----< (N) swipes
users (1) ----< (N) matches (user1_id)
users (1) ----< (N) matches (user2_id)
users (1) ----< (N) messages
users (1) ----< (N) notifications
users (1) ----< (N) consent_logs
users (1) ----< (N) audit_logs
users (1) ----< (N) subscriptions
users (1) ----< (N) reviews (reviewer)
users (1) ----< (N) reviews (reviewed)

pets (1) ----< (N) swipes
pets (1) ----< (N) matches (user1_pet_id)
pets (1) ----< (N) matches (user2_pet_id)
pets (1) ----< (N) reviews (reviewed_pet)

matches (1) ---- (1) conversations
matches (1) ----< (N) reviews

conversations (1) ----< (N) messages
```

---

## 3. Funcoes Auxiliares

### 3.1 Incrementar Match Count

```sql
CREATE OR REPLACE FUNCTION increment_match_count(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users
    SET stats = jsonb_set(
        stats,
        '{total_matches}',
        ((stats->>'total_matches')::INT + 1)::TEXT::JSONB
    )
    WHERE uid = p_user_id;
END;
$$ LANGUAGE plpgsql;
```

### 3.2 Calcular Distancia

```sql
CREATE OR REPLACE FUNCTION nearby_pets(
    p_lat FLOAT,
    p_lng FLOAT,
    p_radius_km FLOAT,
    p_type TEXT DEFAULT NULL,
    p_breed TEXT DEFAULT NULL,
    p_sex TEXT DEFAULT NULL,
    p_interest TEXT DEFAULT NULL,
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    type VARCHAR,
    breed VARCHAR,
    sex VARCHAR,
    age_months INT,
    main_photo_url TEXT,
    distance_km FLOAT,
    interests TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.type,
        p.breed,
        p.sex,
        p.age_months,
        p.main_photo_url,
        ROUND((ST_Distance(
            p.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
        ) / 1000)::NUMERIC, 2)::FLOAT AS distance_km,
        p.interests
    FROM pets p
    WHERE p.is_active = true
        AND p.is_banned = false
        AND ST_DWithin(
            p.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radius_km * 1000
        )
        AND (p_type IS NULL OR p.type = p_type)
        AND (p_breed IS NULL OR p.breed = p_breed)
        AND (p_sex IS NULL OR p.sex = p_sex)
        AND (p_interest IS NULL OR p_interest = ANY(p.interests))
    ORDER BY distance_km ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
```

---

## 4. Estimativa de Tamanho (1 ano)

| Tabela | Documentos | Tamanho/doc | Total |
|--------|------------|-------------|-------|
| users | 10.000 | 2 KB | 20 MB |
| pets | 15.000 | 3 KB | 45 MB |
| swipes | 500.000 | 0.5 KB | 250 MB |
| matches | 50.000 | 1 KB | 50 MB |
| messages | 2.000.000 | 1 KB | 2 GB |
| reports | 1.000 | 2 KB | 2 MB |
| audit_logs | 5.000.000 | 0.3 KB | 1.5 GB |
| consent_logs | 30.000 | 0.5 KB | 15 MB |
| **TOTAL** | - | - | **~4 GB** |
