# 07 - Estrutura-Alvo: Refatoração de Pastas e Camadas

> **Status:** Alvo definido no OpenSpec `refactor-flutter-architecture` · Migração em execução (Phase 1: domain/value_objects + entities concluídas).
>
> Este documento registra o **levantamento de problemas organizacionais** das pastas, a
> estrutura alvo e a **matriz de cobertura** ligando cada problema às tasks/issues do backlog.

---

## 1. Levantamento — Problemas na estrutura organizacional

Levantamento feito sobre a árvore real de `lib/` antes da refatoração (confirmado
contra `docs/development/02-estrutura-projetos.md` e `lib/`):

```
lib/
├── core/        config · constants · errors · network · theme · utils
├── features/    auth · chat · feed · matching · notifications · pets · profile
│   └── <feature>/{data, domain, presentation}
├── routes/      app_router.dart · route_names.dart
├── shared/      services/ · widgets/
└── domain/      entities/ · value_objects/          ← novo (fase atual, coexiste com o legado)
```

| # | Problema | Onde | Por que incomoda |
|---|----------|------|------------------|
| **P1** | `presentation/providers/` guarda **ViewModels** | `auth_provider.dart`, `pets_provider.dart` | Naming mentiroso: são `ChangeNotifier` com lógica de negócio, não providers; confunde quem entra no projeto |
| **P2** | Serviço de dados em `shared/` | `shared/services/geolocation_service.dart` | Wrapper do `geolocator` é dependência externa = camada **data**, não "shared" (reuso de widget) |
| **P3** | Lógica de domínio em `core/utils/` | `core/utils/geohash.dart`, `core/utils/validators.dart` | Geohash/validação são conceitos de domínio disfarçados de "util"; sem VO não há validação/encapsulamento |
| **P4** | DTOs herdam de entities | `PetModel extends PetEntity`, `UserModel extends UserEntity` | Acopla data→domain; mudança de schema vaza para o domínio (raiz do bug `double lat/lng` vs PostGIS) |
| **P5** | Repositórios fazem trabalho de serviço | `PetRepository` (170+ linhas), `AuthRepository` | Queries cruas do Supabase + `geolocator` + regras misturadas; difíceis de testar |
| **P6** | Erro primitivo | `core/errors/app_exception.dart` | Só `try/catch` + hierarquia; sem `Result<T,E>` declarativo |
| **P7** | DI ad-hoc via Riverpod | providers espalhados | Sem container centralizado (`di/`) → testes sem override limpo |
| **P8** | Template de feature inconsistente | `notifications/` só tem `presentation/` | Features incompletas não seguem o mesmo esqueleto (data/domain/presentation) |
| **P9** | Sem camadas de topo | camadas **aninhadas por feature** | `features/auth/domain/...` força duplicação por feature e impede tipos compartilhados (Result, VOs) |

---

## 2. Estrutura Alvo

Fonte: `openspec/changes/refactor-flutter-architecture/proposal.md` (Target Architecture),
baseada na skill `flutter-apply-architecture-best-practices`.

```
lib/
├── app.dart, main.dart
├── core/                          # theme, constants, errors, utils, config (mantido)
├── data/
│   ├── models/                    # DTOs (api/db shapes) — user_dto.dart, pet_dto.dart
│   ├── repositories/              # Implementações — auth_repository_impl.dart, pet_repository_impl.dart
│   └── services/                  # Wrappers de APIs externas — supabase_service.dart, geolocation_service.dart, auth_service.dart
├── domain/
│   ├── entities/                  # Modelos do domínio — user.dart, pet.dart
│   ├── value_objects/             # GeoPoint, Geohash, Email, Result, failures/
│   ├── repositories/              # Interfaces (contratos)
│   ├── use_cases/                 # Lógica de negócio
│   └── failures/                  # Failures de domínio
├── ui/
│   ├── core/                      # Widgets e theme compartilhados
│   └── features/
│       ├── auth/{view_models, views}
│       ├── pets/{view_models, views, widgets}
│       ├── feed/{view_models, views}
│       └── matches/{view_models, views}
└── di/                            # injection_container.dart (get_it)
```

**Princípio:** camadas globais (`data/`, `domain/`, `ui/`) no topo; dentro de `ui/`,
organização por feature com `view_models/` + `views/`; entidades/VOs/Result compartilhados
vivem no `domain/` global (não aninhados por feature).

---

## 3. Matriz de Cobertura — Problema × Tasks/Issues

Cruzamento dos problemas do §1 contra `openspec/changes/refactor-flutter-architecture/tasks.md`
(tasks 1.1–12.3) e as issues do board (epics #29–#34, tasks #1–#28, sub-issues #35–#74).

| # | Problema | Tasks que cobrem | Issues (pai/sub) | Status |
|---|----------|------------------|------------------|--------|
| P1 | providers → ViewModels | 8.1–8.6, 9.1–9.5, 10.2 · cleanup 11.3, 11.4 | #14 (8.x), #15 (8.3–8.5), #16 (9.x), #17 (9.3–9.4), #18/10.2 · sub #59–#66 | ✅ **Coberto** |
| P2 | geolocation em shared/ | 4.1, 4.2, 4.7 (mover + deletar antigo) | #5 · sub ligadas à #5/#6 | ✅ **Coberto** |
| P3 | domínio em core/utils/ | 1.5 (GeoPoint), 1.6 (Geohash, 1.7 (Email) **criam os VOs** — **sem task p/ deletar** `core/utils/geohash.dart` e `core/utils/validators.dart` | #2, #3 | ⚠️ **Lacuna** (metade feita: cria substituto, não remove) |
| P4 | DTOs herdam de entities | 3.1, 3.2 (composição `toDomain/fromDomain`) · cleanup 11.7, 11.8 | #4 · sub #45, #46 | ✅ **Coberto** |
| P5 | repos com queries cruas | 4.3–4.6 (Services), 5.1–5.5 (interfaces/impls) · cleanup 11.1, 11.2, 11.9, 11.10 | #6 (4.x), #7 (5.x) · sub #48–#51 | ✅ **Coberto** |
| P6 | erro primitivo | 1.1–1.4 (Result + failures) — **sem task p/ deletar** `core/errors/app_exception.dart` | #1 · sub #35–#38 | ⚠️ **Lacuna menor** (Result criado; limpeza do arquivo órfão não agendada) |
| P7 | DI ad-hoc | 6.1–6.3 (`get_it`, `injection_container.dart`, `main.dart`) · 7.7, 13 | #8 · sub #52–#54 · #13 | ✅ **Coberto** |
| P8 | template inconsistente (notifications) | — (fora de escopo: **non-goal** — não criar features novas) · follow-up 12.3 | #34 (Evolução) | ⚠️ **Fora de escopo** (documentado como follow-up) |
| P9 | sem camadas de topo | 1.x–3.x (`domain/`, `data/models/`), 4.x–5.x (`data/`), 6.x (`di/`), 8.x–9.x (`ui/features/*/view_models`) — **tasks 8.3–8.5/9.3–9.4 atualizam as páginas IN PLACE**, sem mover para `ui/features/*/views/`; `shared/widgets` → `ui/core/` **não agendado** | #14–#18, #8 | ⚠️ **Desvio tarefa↔alvo** |

---

## 4. Lacunas identificadas

### ⚠️ G1 (P3) — Deletar os arquivos órfãos de `core/utils/`
O auto-substituto existe (VOs GeoPoint/Geohash/Email), mas **nenhuma task agendada** remove
`lib/core/utils/geohash.dart` e `lib/core/utils/validators.dart` (duplicação até o fim da refatoração).

### ⚠️ G2 (P6, menor) — Deletar `core/errors/app_exception.dart`
O `Result<T,E>` substitui o `AppException`, mas a remoção do arquivo órfão não consta na seção
Cleanup (11.x).

### ⚠️ G3 (P9) — Migrar páginas/widgets para a estrutura alvo
O alvo promete `ui/features/auth|pets/{views}` e `ui/core/`, porém as tasks **atualizam as páginas
onde estão** (`features/*/presentation/pages/`) e não agendam o movimento de `shared/widgets` →
`ui/core/`. Resultado final esperado ficaria **híbrido**, divergente do alvo do proposal.

### ⚠️ G4 (P8) — Entendimento explícito
`notifications/` e demais features incompletas continuam sem data/domain — **decisão consciente**
(non-goal: não criar features novas nesta refatoração). Deve constar no follow-up (#34 / task 12.3).

---

## 5. Recomendações

1. **G1 + G2:** adicionar à seção 11 (Cleanup) do `tasks.md` novos itens de exclusão
   (`core/utils/geohash.dart`, `core/utils/validators.dart`, `core/errors/app_exception.dart`).
2. **G3:** decidir entre (a) **cumprir o alvo** — adicionar tasks de movimento de páginas
   (`features/*/presentation/pages/*` → `ui/features/*/views/*` e `shared/widgets` → `ui/core/`)
   na Phase 4, ou (b) **ajustar o alvo** no proposal (manter páginas in-place e só documentar a
   divergência). Recomendado: **(a)**, para o alvo valer de fato.
3. **G4:** garantir que a issue #34 (follow-ups) registra "uniformizar esqueleto das features
   incompletas (notifications/ etc.)".

---

*Documento de apoio ao change `refactor-flutter-architecture`. A árvore "antes" fica
congelada no §1; o estado vivo das tasks está em `openspec/changes/refactor-flutter-architecture/tasks.md`.*