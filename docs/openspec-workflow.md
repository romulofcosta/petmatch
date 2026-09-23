# Playbook — OpenSpec + GitHub + Git de ponta a ponta

Guia operacional passo a passo cobrindo o ciclo completo:
**explore → propose → apply → archive**, integrando OpenSpec, board de issues e fluxo git.

## Convenções (resumo)

- Branch principal: `main` (protegida — PR + checks + squash)
- Nome de branch: `<tipo>/<numero>-<slug>` — `refactor/1-result-pattern`
- Commits: Conventional Commits com `Closes #N` → `feat(#68): envolver LoginPage com ResponsivePage`
- Merge: `gh pr merge <N> --squash --delete-branch --admin` (repo pessoal sem self-review)
- Check da proteção: `flutter analyze` + `flutter test` (CI + hooks locais)

---

## Fase 0 — EXPLORE (pensar antes de propor)

**Objetivo:** investigar o problema, amadurecer a ideia. NADA de código de produção.

```bash
# 1. Entrar em modo explore do OpenSpec
openspec explore

# 2. Investigar o código/ambiente, anotar decisões
#    (fichas técnicas, arquivos de referência, trade-offs)
```

**Entregáveis:** notas de exploração, caminho claro para o proposal.

**Git:** nada obrigatório. Se quiser versionar as notas: branch `docs/explore-<tema>` → PR.

---

## Fase 1 — PROPOSE (formalizar a mudança)

**Objetivo:** gerar todos os artefatos de planejamento da mudança.

```bash
# 1. Gerar a mudança completa (proposal + specs + design + tasks)
openspec propose "refactor-flutter-architecture"    # ou nome do tema

# 2. Revisar e preencher os artefatos
#    proposal.md  → por quê / o quê / impacto
#    specs/*      → capacidades (edição por delta)
#    design.md    → decisões técnicas
#    tasks.md     → tarefas agrupadas + critérios de verificação

# 3. Validar que o planejamento está completo
openspec status --change refactor-flutter-architecture
# → "All planning artifacts complete!"
```

**Git + Board:**

```bash
# 4. Commit dos artefatos (congela o planejamento — regra 1 do contrato)
git co -b docs/openspec-refactor-flutter-architecture
git add openspec/
git ci -m "docs: adicionar proposal de refactor da arquitetura Flutter"
git pr
gh pr merge --squash --delete-branch --admin

# 5. Gerar o backlog a partir do tasks.md
#    Tasks → issues #N · tasks grandes (≥5 checks) → epics + sub-issues
#    Associar milestones (Phase 1-5) e labels (architecture, responsive...)
#    Adicionar todas as issues ao Project Board
```

**Entregáveis:** change no OpenSpec commitado + backlog completo no board (Todo).

---

## Fase 2 — APPLY (executar o backlog)

**Objetivo:** implementar as sub-issues uma a uma, da base para o topo (respeitando dependências das fases).

```bash
# 1. Pegar a próxima sub-issue (ex: #1 — Result<T,E>)
#    → board: mover para In Progress
git co main && git pull
git co -b refactor/1-result-pattern

# 2. Implementar + testar localmente
#    (hooks: pre-commit formata, commit-msg valida, pre-push roda analyze/test)

# 3. Commits atômicos ao longo do trabalho
git ci -m "refactor(#1): criar sealed Result<T,E> com when()"
git ci -m "refactor(#1): adicionar hierarquias de Failure"

# 4. Publicar e abrir PR (template já linka a issue)
git pr

# 5. CI verde → merge (squash fecha #1 automaticamente via Closes #1)
gh pr merge 1 --squash --delete-branch --admin

# 6. Sincronizar (regra 2 do contrato)
#    → board: sub-issue #1 → Done
#    → tasks.md: marcar os checkboxes correspondentes
```

**Conferir progresso a qualquer momento:**

```bash
openspec status --change refactor-flutter-architecture   # % do tasks.md
# board: contagem Todo/In Progress/Done por fase          # % real
```

---

## Fase 3 — ARCHIVE (encerrar a mudança)

**Objetivo:** incorporar as specs (delta → principais) e arquivar o change.

```bash
# Pré-condição (regra 4 do contrato):
#   Todas as sub-issues da mudança estão Done no board.
openspec status --change refactor-flutter-architecture

# 1. Sincronizar delta specs para as specs principais
openspec sync-specs --change refactor-flutter-architecture

# 2. Arquivar a mudança
openspec archive --change refactor-flutter-architecture

# 3. Commit do archive + specs atualizadas
git co -b chore/archive-refactor-flutter-architecture
git add openspec/
git ci -m "chore: arquivar mudança refactor-flutter-architecture"
git pr
gh pr merge --squash --delete-branch --admin

# 4. Encerrar no board
#    → épicos da mudança → Done · milestone da fase → 100%
#    → tag de fase (se aplicável): git tag petmatch-phase-<N> && git push --tags
```

**Entregáveis:** change arquivado em `openspec/changes/archive/`, specs principais atualizadas, board 100%.

---

## Tabela-resumo do ciclo

| Fase OpenSpec | Comando | Board | Git |
|--------------|---------|-------|-----|
| Explore | `openspec explore` | — | (opcional) br `docs/` |
| Propose | `openspec propose` | — | commit artefatos |
| Approve | (revisão) | issues criadas, Todo | — |
| Apply | (sub-issue) | In Progress → Done | branch → PR → squash |
| Archive | `sync-specs` + `archive` | épico Done | commit archive |

---

## Labels vs OpenSpec (quem é dono de quê)

**O contêiner do trabalho é sempre o change do OpenSpec.** Label é **filtro de
leitura** — nunca contêiner. Uma mesma issue pode ter vários labels sem conflito.

| Camada/dimensão | Papel | Exemplo |
|---|---|---|
| Change (OpenSpec) | Contêiner — *porquê + o quê* | `refactor-flutter-architecture` |
| Issues/backlog | Unidades de execução | tasks + epics + sub-issues |
| Milestone | Fase/data | Phase 1-5 |
| Board | Status (Todo/In Progress/Done) | — |
| Label | Classificação (filtro ortogonal) | `architecture`, `responsive`, `phase-1` |

**Labels de origem** (convenção criada com o backlog):

| Label | Significado | Quando usar |
|---|---|---|
| `change:<nome>` | Issue nasce das tasks de um change | Marcar toda issue derivada de `.openspec`/tasks.md |
| `dev-direct` | Issue avulsa de desenvolvimento (não passa pelo OpenSpec) | Bugs restauradores, chores, tooling, typos |

Exemplo: sub-issue #68 tem `change:refactor-flutter-architecture` + `responsive`
+ `phase-5`. O label de origem diz *de onde veio*; os demais dizem *sobre o quê*.

---

## Issue direta vs change (fluxo de desenvolvimento)

Nem todo trabalho precisa do ciclo OpenSpec completo. O critério de corte:

| Tipo de trabalho | Passa pelo OpenSpec? | Por quê |
|---|---|---|
| Refactor de arquitetura | ✅ Sempre | Muda o *o quê* do sistema |
| Feature nova (comportamento/UX) | ✅ Sempre | Muda capacidade do produto |
| Bug que **restaura** comportamento esperado | ❌ Geralmente não | Não muda a spec — só corrige |
| Chore/CI/typo/tooling | ❌ Não | Não toca o produto |
| Refactor interno (sem mudar contrato) | ⚠️ Talvez | Se só estrutura — pode ser issue direta |

**Regra de ouro:** se a mudança altera o *o quê* do sistema (spec/capacidade),
ela **passa pelo OpenSpec** (explore → propose → approve → apply → archive),
mesmo que o change seja pequeno (`proposal.md` + `tasks.md` bastam). Se apenas
restaura ou organiza o que já existe, é **issue direta** (label `dev-direct`),
sem ciclo de specs.

```text
Nova ideia / bug / melhoria
   │
   ├─ TRIVIAL (typo, bug 1 linha, chore de 1 commit)
   │     └─► issue `dev-direct` → branch → PR → merge   (sem OpenSpec)
   │
   └─ SIGNIFICATIVA (arquitetura, UX, comportamento, camada)
         └─► openspec explore → propose → approve
              → gerar issues no board (label `change:<nome>`)
              → apply via git flow (Closes #N) → archive
```

---

## Solução de divergência

Se Board e tasks.md divergirem: **o Git (código mergeado) é a verdade**.
Reconcile: reabra a sub-issue e refaça, ou ajuste o tasks.md/board manualmente
conforme o que foi realmente entregue.