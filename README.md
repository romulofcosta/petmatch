# PetMatch - Tinder para Pets

## Visao Geral

**PetMatch** e um aplicativo mobile que conecta tutores de caes e gatos para **socializacao** e **cruzamento** de pets, funcionando como um "Tinder para animais de estimacao".

## Missao

Facilitar a conexao entre tutores de pets que buscam:
- **Socializacao**: Encontrar amigos para brincar e conviver
- **Cruzamento**: Encontrar parceiros para reproducao de filhotes
- **Ambos os objetivos**

## Publico-Alvo

- Tutores de caes e gatos
- Idade minima: 18 anos
- Interessados em socializacao e/ou cruzamento

## Funcionalidades Principais

| Funcionalidade | Descricao |
|----------------|-----------|
| Cadastro de Pets | Fotos, raca, idade, interesses, dados veterinarios |
| Feed com Filtros | Busca por raca, sexo, idade, distancia, interesse |
| Swipe | Curtir (coracao) ou Passar (X) |
| Match | So acontece quando ambos curtem |
| Chat | Mensagens de texto, fotos, localizacao (pos-match) |
| Notificacoes | Push notifications para matches e mensagens |
| Premium | Likes ilimitados, super likes, filtros avancados |

## Arquitetura Tecnica

```
App Flutter (iOS/Android)
    |
    v
Supabase (Backend as a Service)
    |-- PostgreSQL + PostGIS (banco de dados + geolocalizacao)
    |-- Supabase Auth (autenticacao: Email + Google + Apple)
    |-- Supabase Storage (fotos de pets)
    |-- Supabase Realtime (chat em tempo real)
    |-- Supabase Edge Functions (logica de negocio)
    |
Firebase Cloud Messaging (notificacoes push)
```

## Stack Tecnologica

| Camada | Tecnologia |
|--------|------------|
| Frontend | Flutter (Dart) |
| Backend | Supabase (PostgreSQL + Edge Functions) |
| Autenticacao | Supabase Auth (Email + Google + Apple) |
| Banco de Dados | PostgreSQL + PostGIS |
| Storage | Supabase Storage |
| Realtime | Supabase Realtime |
| Notificacoes | Firebase Cloud Messaging |
| State Management | Riverpod |
| Navegacao | GoRouter |

## Estrutura do Projeto

```
petmatch/
├── docs/                          # Documentacao
│   ├── product/                   # Documentacao do produto
│   │   ├── 01-visao-geral.md
│   │   ├── 02-funcionalidades.md
│   │   ├── 03-wireframes.md
│   │   ├── 04-regras-de-negocio.md
│   │   └── 05-fluxos-usuario.md
│   ├── legal/                     # Compliance e leis
│   │   ├── 01-compliance-animal.md
│   │   ├── 02-lgpd.md
│   │   ├── 03-termos-de-uso.md
│   │   └── 04-politica-privacidade.md
│   ├── architecture/              # Arquitetura tecnica
│   │   ├── 01-visao-geral.md
│   │   ├── 02-banco-de-dados.md
│   │   ├── 03-edge-functions.md
│   │   ├── 04-rls-policies.md
│   │   ├── 05-fluxos-api.md
│   │   └── 06-pagamentos.md
│   └── development/               # Desenvolvimento
│       ├── 01-stack-tecnologica.md
│       ├── 02-estrutura-projetos.md
│       ├── 03-plano-de-testes.md
│       └── 04-roadmap.md
├── lib/                           # Codigo Flutter (futuro)
├── supabase/                      # Migrations e Edge Functions (futuro)
└── pubspec.yaml                   # Dependencias (futuro)
```

## Compliance e Legal

O PetMatch atende as seguintes legislacoes:

| Legislacao | Abrangencia |
|------------|-------------|
| Lei 9.605/1998 | Crimes Ambientais (protecao animal) |
| Lei 14.064/2020 | Lei Sansao (penas agravadas caes/gatos) |
| Lei 15.046/2024 | Cadastro Nacional de Animais Domesticos |
| Lei 17.972/2024 | Protecao animal em SP (comercializacao) |
| LGPD (Lei 13.709/2018) | Protecao de dados pessoais |

## Estatisticas do MVP

| Metrica | Meta |
|---------|------|
| Cadastros/mes | 1.000 |
| Matches/semana | 500 |
| Mensagens trocadas/mes | 10.000 |
| Conversao Free->Premium | 5% |
| Retencao D7 | 40% |
| Retencao D30 | 20% |

## Versao

- **Fase atual**: Especificacao / Planejamento
- **Versao da documentacao**: 1.0.0
- **Ultima atualizacao**: Agosto 2026
