# 01 - Arquitetura do Sistema - Visao Geral

## Visao Geral

O PetMatch utiliza uma arquitetura moderna baseada em servicos gerenciados (BaaS) para minimizar infraestrutura propria e acelerar o desenvolvimento do MVP.

---

## 1. Stack Tecnologica

| Camada | Tecnologia | Funcao |
|--------|------------|--------|
| Frontend | Flutter (Dart) | App mobile iOS/Android |
| Backend | Supabase | Backend as a Service |
| Banco de Dados | PostgreSQL + PostGIS | Dados + Geolocalizacao |
| Autenticacao | Supabase Auth | Email + Google + Apple |
| Storage | Supabase Storage | Fotos de pets |
| Realtime | Supabase Realtime | Chat em tempo real |
| Edge Functions | Supabase Edge Functions | Logica de negocio |
| Notificacoes | Firebase Cloud Messaging | Push notifications |

---

## 2. Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CAMADA DE CLIENTE                                  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        Flutter App (iOS/Android)                        │   │
│  │                                                                         │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐              │   │
│  │  │    Auth   │ │    Feed   │ │   Match   │ │    Chat   │              │   │
│  │  │  Module   │ │  Module   │ │  Module   │ │  Module   │              │   │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘              │   │
│  │                                                                         │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │                    State Management (Riverpod)                  │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                         │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │                    Supabase Flutter Client                      │   │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │   │   │
│  │  │  │   Auth   │ │ Database │ │ Storage  │ │ Realtime │          │   │   │
│  │  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘          │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                         │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │                    Firebase SDK (FCM)                           │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
           │                                    │
           │ HTTPS/WSS                          │ FCM
           ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CAMADA DE SERVICOS                                  │
│                                                                                 │
│  ┌─────────────────────────────────────┐  ┌─────────────────────────────────┐  │
│  │          Supabase Platform          │  │       Firebase Platform         │  │
│  │                                     │  │                                 │  │
│  │  ┌───────────────────────────────┐  │  │  ┌───────────────────────────┐  │  │
│  │  │       PostgreSQL + PostGIS    │  │  │  │  Cloud Messaging (FCM)    │  │  │
│  │  └───────────────────────────────┘  │  │  └───────────────────────────┘  │  │
│  │  ┌───────────────────────────────┐  │  │                                 │  │
│  │  │       Auth (Supabase)         │  │  │                                 │  │
│  │  └───────────────────────────────┘  │  │                                 │  │
│  │  ┌───────────────────────────────┐  │  │                                 │  │
│  │  │       Storage (Supabase)      │  │  │                                 │  │
│  │  └───────────────────────────────┘  │  │                                 │  │
│  │  ┌───────────────────────────────┐  │  │                                 │  │
│  │  │       Realtime (Supabase)     │  │  │                                 │  │
│  │  └───────────────────────────────┘  │  │                                 │  │
│  │  ┌───────────────────────────────┐  │  │                                 │  │
│  │  │   Edge Functions (Supabase)   │  │  │                                 │  │
│  │  └───────────────────────────────┘  │  │                                 │  │
│  └─────────────────────────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
           │                                    │
           ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CAMADA DE DADOS                                     │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    PostgreSQL + PostGIS                                  │   │
│  │                                                                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │   │
│  │  │  users   │ │   pets   │ │  swipes  │ │ matches  │ │ messages │    │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘    │   │
│  │                                                                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │   │
│  │  │reports   │ │consent   │ │audit_log │ │reviews   │ │subscript │    │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    Supabase Storage                                     │   │
│  │                                                                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐                               │   │
│  │  │  pets/   │ │  users/  │ │ reports/ │                               │   │
│  │  │  photos  │ │  photos  │ │ evidence │                               │   │
│  │  └──────────┘ └──────────┘ └──────────┘                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Fases da Arquitetura

### Fase 1: MVP (Firebase/Supabase)

| Componente | Tecnologia | Descricao |
|------------|------------|-----------|
| Auth | Supabase Auth | Email + Google + Apple |
| Database | Supabase PostgreSQL | Todas as tabelas |
| Storage | Supabase Storage | Fotos |
| Realtime | Supabase Realtime | Chat |
| Push | Firebase FCM | Notificacoes |
| Logic | Supabase Edge Functions | Logica de negocio |

### Fase 2: Escalabilidade (Backend Proprio)

| Componente | Tecnologia | Descricao |
|------------|------------|-----------|
| Auth | Supabase Auth | Mantido |
| Database | PostgreSQL + PostGIS | Mantido, com replicacao |
| Storage | S3/Cloudflare R2 | Migracao para custo |
| Realtime | Supabase/Migration | Manter ou migrar |
| Push | Firebase FCM | Mantido |
| Logic | NestJS/Django | API propria |
| Cache | Redis | Performance |
| Queue | Bull/BullMQ | Filas de jobs |

---

## 4. Vantagens da Arquitetura

| Vantagem | Descricao |
|----------|-----------|
| **Rapidez** | MVP em semanas, nao meses |
| **Custo** | Free tier suficiente para validacao |
| **Escalabilidade** | Supabase escala automaticamente |
| **Seguranca** | RLS, criptografia, autenticacao |
| **Realtime** | Chat sem infraestrutura propria |
| **Flexibilidade** | Facil migrar componentes |

---

## 5. Riscos e Mitigacoes

| Risco | Impacto | Mitigacao |
|-------|---------|-----------|
| Vendor lock-in | Alto | Abstracao via interfaces |
| Limite free tier | Medio | Monitoramento + alertas |
| Latencia Edge Functions | Baixo | Regiao de deploy proxima |
| Disponibilidade Supabase | Alto | Multi-cloud fallback (futuro) |
