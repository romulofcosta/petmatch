# Fluxo de Git do PetMatch

Alinhado ao backlog (épicos → tasks → sub-issues) e às boas práticas do GitHub Flow.

## Estratégia

- **Branch principal:** `main` (sempre deployable, protegida)
- **Modelo:** GitHub Flow extendido por sub-issue
- **Merge:** squash obrigatório (1 commit por PR, história linear)
- **Proteção de `main`:** PR obrigatório, 1 approval, checks CI obrigatórios (`flutter analyze` + `flutter test`), sem push direto

```
épico #33 → task #24 → sub-issue #68 → branch feat/68-login-responsiva → PR (Closes #68) → squash em main
```

## Nome de branches

Um branch por sub-issue. Formato: `<tipo>/<numero>-<slug>`.

| Tipo | Uso | Exemplo |
|------|-----|---------|
| `feat/`   | Nova funcionalidade        | `feat/68-login-responsiva`     |
| `refactor/` | Refatoração (architecture) | `refactor/1-result-pattern`    |
| `fix/`    | Correção de bug             | `fix/26-petspage-grid`         |
| `docs/`   | Documentação                | `docs/73-architecture`         |
| `test/`   | Testes                      | `test/20-suites`               |
| `chore/`  | Manutenção                  | `chore/52-get-it-pubspec`      |

O tipo segue o label da issue (`architecture` → `refactor`, `responsive` → `feat`, `clean-code` → `refactor`/`docs`).

## Commits — Conventional Commits

Template automático: `commit.template` → `.gitmessage`.

```
<type>(<scope>): <subject>

Corpo (opcional) — o PORQUÊ.

Closes #68
```

- **type:** feat, fix, docs, style, refactor, test, chore, perf, ci
- **scope:** número da issue (`#68`) ou área (`auth`, `di`, `responsive`)
- **subject:** imperativo, sem ponto final, ≤ 50 chars
- **footer:** `Closes #N` para fechar a sub-issue no merge

## Ciclo de trabalho de uma sub-issue

```bash
# 1. Partir da main atualizada
git co main
git pull

# 2. Criar branch da sub-issue
git co -b feat/68-login-responsiva

# 3. Commits atômicos ao longo do trabalho
git ci -m "feat(#68): envolver LoginPage com ResponsivePage"

# 4. Publicar e abrir PR
git pr                      # alias de push -u origin HEAD

# 5. No PR: template já vem preenchido — linkar a issue:
#    Closes #68   → fecha a sub-issue ao mergear
#    (você pode fechá-la manualmente no board quando o PR mergear)
```

> **Board:** mova a sub-issue para In Progress ao abrir o branch, e para Done
> quando o PR for mergeado. A task/épico pai acompanha automaticamente a barra
> de progresso. Fechar a task pai é manual (quando todas as subs estiverem Done).

## Regras

- Nunca commitar direto na `main` (bloqueado por proteção)
- Um PR = uma sub-issue = um squash commit
- PR pequeno (< 500 linhas); divida se crescer
- `flutter analyze` e `flutter test` verdes antes de pedir review
- Rebase em `main` para atualizar o branch: `git rebase main` (branch local/pushado só por você)
- `git push --force-with-lease` **somente** no seu branch de feature, nunca em `main`

## Fases e versões

- A cada fase (milestone) concluída, criar tag: `git tag -a petmatch-phase-<N> -m "Phase <N> concluída"` e `git push origin --tags`
- Versões do app seguem SemVer (`v0.1.0`, `v0.2.0`, ...)

## Aliases úteis

```bash
git co        # checkout
git br        # branch
git ci        # commit
git st        # status
git last      # log -1 HEAD
git visual    # log --oneline --graph --all
git pr        # push -u origin HEAD
```