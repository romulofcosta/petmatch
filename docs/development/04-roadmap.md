# 04 - Roadmap de Desenvolvimento

## Visao Geral

Roadmap em 4 fases, com estimativas de tempo e entregas claras.

---

## Fase 1: MVP (6-8 semanas)

### Objetivo
App funcional com fluxo completo: cadastro → feed → swipe → match → chat.

| Semana | Entrega |
|--------|---------|
| 1-2 | Setup do projeto, autenticacao (email + Google + Apple), tela de onboarding |
| 3-4 | Cadastro de pets (CRUD, fotos, validacoes), localizacao |
| 5-6 | Feed com filtros, swipe/like/super like, algoritmo basico de matching |
| 7 | Chat (mensagens de texto, tempo real via Supabase Realtime) |
| 8 | Notificacoes push, testes, correcao de bugs, beta interno |

### Funcionalidades Incluidas
- Cadastro com email, Google, Apple Sign In
- Perfil do tutor
- Cadastro de ate 2 pets (free)
- Feed com busca por proximidade (30km)
- Swipe com like, super like, pass
- Match reciproco
- Chat por mensagem de texto
- Notificacoes push basicas
- Design responsivo (iOS + Android)

### Nao Incluido (Fase 2+)
- Pagamentos/Assinatura
- Filtros avancados
- Avaliacoes
- Denuncias
- Moderacao avancada

---

## Fase 2: Premium (4-6 semanas)

### Objetivo
Monetizacao e recursos premium.

| Semana | Entrega |
|--------|---------|
| 1-2 | Integracao Stripe, tela de assinatura, gerenciamento de plano |
| 3-4 | Super like (1 free/dia, 10 premium), filtros avancados, ver quem curtiu |
| 5-6 | Notas fiscais (NFe.io), webhooks, testes de pagamento |

### Funcionalidades Incluidas
- Assinatura Premium (R$29,90/mes, R$249,90/ano)
- Limite de likes: 20 free / ilimitado premium
- Limite de super likes: 1 free / 10 premium
- Raio de busca: 30km free / 100km premium
- Filtros avancados (premium)
- Ver quem curtiu (premium)
- Notas fiscais automaticas
- Gerenciamento de assinatura (cancelar, trocar plano)

---

## Fase 3: Social (3-4 semanas)

### Objetivo
Comunidade e seguranca.

| Semana | Entrega |
|--------|---------|
| 1-2 | Sistema de avaliacoes, perfis publicos com reviews |
| 3-4 | Denuncias, moderacao, whitelist de racas CNPF |

### Funcionalidades Incluidas
- Avaliacoes apos match (1-5 estrelas + comentarios)
- Tags de avaliacoes (respeitoso, responsavel, etc.)
- Denuncias (usuario, pet, mensagem)
- Painel de moderacao (admin)
- Lista oficial de racas (CNPF)
- Bloqueio de racas nao listadas

---

## Fase 4: Escala (4-6 semanas)

### Objetivo
Performance, analytics e preparacao para crescimento.

| Semana | Entrega |
|--------|---------|
| 1-2 | Dashboard de analytics, metricas de uso |
| 3-4 | Otimizacao de performance, cache, indexacao |
| 5-6 | Migraçao para backend robusto (NestJS/Django), Redis |

### Funcionalidades Incluidas
- Analytics dashboard (DAU, churn, conversao)
- Otimizacao de queries PostGIS
- Cache com Redis (feed, matches)
- Rate limiting avancado
- Monitoramento (Sentry, logging)
- Preparacao para escala (10k+ usuarios)

---

## Resumo do Timeline

```
Mes 1-2:  Fase 1 - MVP
Mes 3-4:  Fase 2 - Premium
Mes 5:    Fase 3 - Social
Mes 6-7:  Fase 4 - Escala
```

**Total estimado: 6-7 meses** para todas as fases.

---

## Marcos Importantes

| Marco | Data Estimada | Descricao |
|-------|---------------|-----------|
| Alpha | Final Fase 1 | App funcional (bugs esperados) |
| Beta | Final Fase 1 + 1 sem | Testes com usuarios reais |
| Launch | Final Fase 2 | Lancamento oficial na App Store/Play Store |
| v2.0 | Final Fase 3 | Avaliacoes e moderacao |
| v3.0 | Final Fase 4 | Escala e performance |

---

## Metricas de Sucesso por Fase

### Fase 1 (MVP)
- 100 beta testers
- 70% completam onboarding
- 50% fazem pelo menos 1 match

### Fase 2 (Premium)
- 5% conversao Free→Premium
- Churn < 10%
- MRR > R$1.500

### Fase 3 (Social)
- 20% dos matches recebem avaliacao
- Tempo medio de resposta a denuncia < 24h
- Nenhuma raca nao listada visivel

### Fase 4 (Escala)
- 1.000+ usuarios ativos
- Tempo medio de resposta < 200ms
- 99.9% uptime
