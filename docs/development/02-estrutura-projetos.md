# 02 - Estrutura de Pastas do Projeto

## Visao Geral

O projeto PetMatch segue a arquitetura feature-based com Clean Architecture.

---

## 1. Estrutura Completa

```
petmatch/
├── docs/                                    # Documentacao
│   ├── product/                             # Documentacao do produto
│   │   ├── 01-visao-geral.md
│   │   ├── 02-funcionalidades.md
│   │   ├── 03-wireframes.md
│   │   ├── 04-regras-de-negocio.md
│   │   └── 05-fluxos-usuario.md
│   ├── legal/                               # Compliance e leis
│   │   ├── 01-compliance-animal.md
│   │   ├── 02-lgpd.md
│   │   ├── 03-termos-de-uso.md
│   │   └── 04-politica-privacidade.md
│   ├── architecture/                        # Arquitetura tecnica
│   │   ├── 01-visao-geral.md
│   │   ├── 02-banco-de-dados.md
│   │   ├── 03-edge-functions.md
│   │   ├── 04-rls-policies.md
│   │   ├── 05-fluxos-api.md
│   │   └── 06-pagamentos.md
│   └── development/                         # Desenvolvimento
│       ├── 01-stack-tecnologica.md
│       ├── 02-estrutura-projetos.md
│       ├── 03-plano-de-testes.md
│       └── 04-roadmap.md
│
├── lib/                                     # Codigo Flutter
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/                                # Configuracoes globais
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   ├── supabase_config.dart
│   │   │   └── firebase_config.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   └── validation_constants.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── error_handler.dart
│   │   ├── network/
│   │   │   ├── supabase_client.dart
│   │   │   └── network_info.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       ├── geolocation_helper.dart
│   │       └── date_helper.dart
│   │
│   ├── features/                            # Modulos do app
│   │   ├── auth/                            # Autenticacao
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── datasources/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── pets/                            # Cadastro de pets
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── feed/                            # Feed e descoberta
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── matching/                        # Swipe e match
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── chat/                            # Mensagens
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── profile/                         # Perfil do tutor
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── notifications/                   # Notificacoes
│   │       └── presentation/
│   │
│   ├── shared/                              # Componentes compartilhados
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── loading_overlay.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state.dart
│   │   │   └── photo_grid.dart
│   │   └── services/
│   │       ├── notification_service.dart
│   │       ├── location_service.dart
│   │       ├── analytics_service.dart
│   │       └── storage_service.dart
│   │
│   └── routes/
│       ├── app_router.dart
│       └── route_names.dart
│
├── supabase/                                # Supabase
│   ├── migrations/                          # Migrations SQL
│   │   ├── 001_create_users.sql
│   │   ├── 002_create_pets.sql
│   │   ├── 003_create_swipes.sql
│   │   ├── 004_create_matches.sql
│   │   ├── 005_create_conversations.sql
│   │   ├── 006_create_messages.sql
│   │   ├── 007_create_reports.sql
│   │   ├── 008_create_reviews.sql
│   │   ├── 009_create_notifications.sql
│   │   ├── 010_create_consent_logs.sql
│   │   ├── 011_create_audit_logs.sql
│   │   ├── 012_create_subscriptions.sql
│   │   ├── 013_create_rls_policies.sql
│   │   ├── 014_create_functions.sql
│   │   └── 015_create_indexes.sql
│   │
│   ├── functions/                           # Edge Functions
│   │   ├── _shared/
│   │   ├── create-profile/
│   │   ├── process-swipe/
│   │   ├── send-message/
│   │   ├── send-push/
│   │   ├── nearby-pets/
│   │   ├── create-report/
│   │   ├── export-user-data/
│   │   ├── delete-account/
│   │   └── moderate-message/
│   │
│   └── seed/
│       └── breeds_data.sql
│
├── assets/                                  # Recursos estaticos
│   ├── images/
│   ├── icons/
│   └── animations/
│
├── test/                                    # Testes
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── .gitignore
├── .env.example
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

---

## 2. Descricao das Pastas

### 2.1 lib/core/

| Pasta | Descricao |
|-------|-----------|
| config/ | Configuracoes do app (Supabase, Firebase) |
| theme/ | Tema visual (cores, estilos) |
| constants/ | Constantes da API e do app |
| errors/ | Tratamento de erros |
| network/ | Cliente Supabase e informacoes de rede |
| utils/ | Funcoes utilitarias |

### 2.2 lib/features/

| Feature | Descricao |
|---------|-----------|
| auth/ | Login, cadastro, autenticacao OAuth |
| pets/ | CRUD de pets |
| feed/ | Feed principal com filtros |
| matching/ | Swipe, super like, match |
| chat/ | Mensagens e conversas |
| profile/ | Perfil do tutor e configuracoes |
| notifications/ | Notificacoes in-app |

### 2.3 lib/shared/

| Pasta | Descricao |
|-------|-----------|
| widgets/ | Componentes UI reutilizaveis |
| services/ | Servicos globais (notificacao, localizacao) |

### 2.4 supabase/

| Pasta | Descricao |
|-------|-----------|
| migrations/ | Scripts SQL de criacao/atualizacao do banco |
| functions/ | Edge Functions (logica de negocio) |
| seed/ | Dados iniciais (lista de racas) |

---

## 3. Convencoes de Arquivos

| Tipo | Formato | Exemplo |
|------|---------|---------|
| Paginas | `*_page.dart` | `login_page.dart` |
| Widgets | `*_widget.dart` ou descritivo | `pet_card.dart` |
| Providers | `*_provider.dart` | `auth_provider.dart` |
| Models | `*_model.dart` | `user_model.dart` |
| Entities | `*_entity.dart` | `pet_entity.dart` |
| Repositories | `*_repository.dart` | `auth_repository.dart` |
| Usecases | `*_usecase.dart` | `sign_in_usecase.dart` |
| Services | `*_service.dart` | `notification_service.dart` |
| Migrations | `NNN_description.sql` | `001_create_users.sql` |

---

## 4. Tamanho Estimado do Projeto

| Pasta | Arquivos | Linhas estimadas |
|-------|----------|------------------|
| lib/core/ | ~15 | ~1.500 |
| lib/features/ | ~60 | ~6.000 |
| lib/shared/ | ~10 | ~1.000 |
| lib/routes/ | ~2 | ~200 |
| supabase/migrations/ | ~15 | ~1.500 |
| supabase/functions/ | ~20 | ~3.000 |
| test/ | ~30 | ~3.000 |
| **TOTAL** | **~150** | **~16.000** |
