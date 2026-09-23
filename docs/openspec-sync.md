# Contrato de Sincronização — OpenSpec ↔ Issues/Board ↔ Git

Regras para manter o planejamento (OpenSpec), o rastreamento (Board) e a
entrega (Git) sempre alinhados. Este documento é o **contrato** de governança.

## As 3 camadas e seus papéis

| Camada | Fonte de verdade de | Papel |
|--------|--------------------|-------|
| **OpenSpec** (`openspec/changes/`) | Planejamento (*porquê + o quê*) | proposal, specs, design, tasks |
| **Issues + Board** | Execução (*status*) | Todo / In Progress / Done de cada unidade |
| **Git (main + PRs)** | Entrega (*como*) | Código, commits, PRs mergeados |

## Regras do contrato

### 1. PROPOSE → congela o planejamento
Quando o proposal é aceito, os artefatos são commitados no repo. A partir daí,
o **Board é o rastreador de execução**. Não se altera o escopo no `tasks.md`
sem criar/ajustar a issue correspondente primeiro.

- Ação: commit dos artefatos em `docs/` ou `feat/` → PR → merge
- Quem: o proposer

### 2. APPLY → o Git alimenta o Board e o tasks.md
Ao mergear um PR que fecha a sub-issue `#N`:

1. `Closes #N` no commit/PR fecha a sub-issue automaticamente
2. Movem o card para **Done** no board
3. Marcam o checkbox correspondente no `tasks.md`
4. `openspec status` passa a refletir o progresso real

Regra de ouro: **uma sub-issue → um branch → um PR → um squash commit → Done**.

### 3. Fonte de verdade encadeada (quem decide se está pronto?)

Consulta nesta ordem — se divergir, o código vence:

```
1. Git    → o PR está mergeado na main?      (verdade final)
2. Board  → o card está em Done?
3. tasks.md → o checkbox está marcado?
```

### 4. ARCHIVE só com o Board 100%
Uma fase só é arquivada / épico fechado quando **todas** as sub-issues da fase
estiverem Done. Nunca "por confiança" ou por progresso parcial.

## Fluxo de transição entre fases

```
EXPLORE ──> PROPOSE ──> APPROVE ──> APPLY ──────> ARCHIVE
   │           │           │           │              │
   │           │           └──► Issues criadas (Todo)
   │           │           └──► Milestones/épicos mapeados
   │           └──────────────────────────────────────► Commit dos artefatos
   │                            │
   │                            └──► Por sub-issue:
   │                                1. branch refactor/<N>-slug
   │                                2. commit + git pr
   │                                3. CI verde → squash merge → Closes #N
   │                                4. board: In Progress → Done
   │                                5. ✓ no tasks.md
   │
   └────────────────────────────────────────────────────► ARCHIVE:
                                                          1. openspec sync-specs
                                                          2. openspec archive
                                                          3. commit do archive
                                                          4. board: épico Done
```

## Estado atual (baseline)

| Change | Planejamento | Aplicado | No Board? |
|--------|-------------|----------|-----------|
| `refactor-flutter-architecture` | 4/4 | 0/65 | ✅ #1-#74 |
| `align-pet-location-schema` | 4/4 | 9/14 | ❌ gap (ver abaixo) |

### Gap conhecido
`align-pet-location-schema` tem ~5 tarefas de verificação de banco aplicadas
fora do board. Decisão pendente: transformá-las em issues (`docs`/`chore`) ou
mantê-las como checklist puro no tasks.md (tarefas sem PR).