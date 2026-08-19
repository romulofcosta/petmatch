# 02 - Funcionalidades Detalhadas

## Visao Geral

O PetMatch possui as seguintes funcionalidades principais:

---

## 1. Autenticacao

### 1.1 Cadastro
| Campo | Obrigatorio | Validacao |
|-------|-------------|-----------|
| Nome completo | Sim | 2-100 caracteres |
| Email | Sim | Formato valido, verificacao |
| Senha | Sim | Min 8 chars, 1 maiuscula, 1 numero, 1 especial |
| Telefone | Nao | Formato (XX) XXXXX-XXXX |
| Foto de perfil | Nao | JPG/PNG, max 1MB |
| Data de nascimento | Sim | Tutor deve ter 18+ anos |

### 1.2 Login
| Metodo | Descricao |
|--------|-----------|
| Email + Senha | Login tradicional |
| Google | OAuth 2.0 |
| Apple | Sign in with Apple (obrigatorio iOS) |

### 1.3 Seguranca
- Maximo 5 tentativas antes de bloqueio (15 min)
- Recuperacao de senha por email (link valido 24h)
- Refresh token rotation

---

## 2. Cadastro de Pet

### 2.1 Limites
| Plano | Limite de Pets |
|-------|----------------|
| Gratuito | 2 pets por tutor |
| Premium | Ilimitado |

### 2.2 Dados Obrigatorios
| Campo | Tipo | Validacao |
|-------|------|-----------|
| Nome | String | 2-30 caracteres |
| Tipo | Enum | dog/cat |
| Sexo | Enum | male/female |
| Raca | String | Lista controlada |
| Data de nascimento | Date | Min 4 meses (Lei 17.972/24) |
| Foto principal | Image | JPG/PNG, 400x400px min, 1MB max |
| Interesses | Array | socialization/breeding/adoption (min 1) |

### 2.3 Dados Opcionais
| Campo | Tipo | Validacao |
|-------|------|-----------|
| Fotos adicionais | Array | Max 6 fotos, 1MB cada |
| Peso | Number | 0.5 - 80 kg |
| Descricao | String | Max 500 caracteres |
| Personalidade | Array | Max 5 tags |
| Castrado | Boolean | Sim/Nao |
| Vacinas | Boolean | Sim/Nao |
| Pedigree | Boolean | Sim/Nao |
| Veterinario | String | Nome + telefone |
| Observacoes de saude | String | Max 300 caracteres |
| Microchip ID | String | Opcional |

### 2.4 Interesses
| Interesse | Descricao |
|-----------|-----------|
| socialization | Encontrar amigos para brincar |
| breeding | Buscar parceiro para filhotes |
| adoption | Encontrar novo lar |

---

## 3. Feed e Descoberta

### 3.1 Algoritmo de Feed
| Prioridade | Criterio |
|------------|----------|
| 1a | Pets na mesma cidade/regiao |
| 2a | Pets com interesses compativeis |
| 3a | Racas compativeis (mesmo porte) |
| 4a | Pets com perfil completo |
| 5a | Atividade recente do tutor |
| 6a | Pets nao visualizados recentemente |

### 3.2 Filtros de Busca
| Filtro | Opcoes |
|--------|--------|
| Tipo | Cao, Gato, Todos |
| Raca | Lista completa (busca por nome) |
| Sexo | Macho, Femea, Todos |
| Idade | Filhote (0-1), Jovem (1-3), Adulto (3-7), Senior (7+) |
| Distancia | 5km a 100km (slider) |
| Interesse | Socializacao, Cruzamento, Adocao |

### 3.3 Filtros Premium
| Filtro | Descricao |
|--------|-----------|
| Raças especificas | Filtrar por raca exata |
| Castrados apenas | Mostrar apenas castrados |
| Com pedigree | Mostrar apenas com pedigree |
| Raio de busca | Ate 100km (vs 30km no gratuito) |

---

## 4. Sistema de Swipe

### 4.1 Acoes
| Acao | Icone | Descricao |
|------|-------|-----------|
| Passar | X (vermelho) | Nao curtiu o pet |
| Super Like | Estrela (azul) | Curtir com prioridade |
| Curtir | Coracao (verde) | Curtir o pet |

### 4.2 Limites Diarios
| Acao | Gratuito | Premium |
|------|----------|---------|
| Curtidas (likes) | 20/dia | Ilimitado |
| Super Likes | 1/dia | Ilimitado |
| Passar | Ilimitado | Ilimitado |

### 4.3 Regras
- Tutor nao pode curtir proprio pet
- Um swipe por combinacao tutor/pet
- Super like notifica imediatamente o tutor destino
- Resets diarios as 00:00 (horario local)

---

## 5. Sistema de Match

### 5.1 Regras
| Regra | Descricao |
|-------|-----------|
| Match reciproco | So acontece quando AMBOS curtem |
| Super like | Notifica imediatamente |
| Desfazer match | Pode desfazer a qualquer momento |
| Block | Impede novo match e remove existente |

### 5.2 Compatibilidade
| Cenario | Socializacao | Cruzamento |
|---------|--------------|------------|
| Cao + Cao | Permitido | Permitido |
| Gato + Gato | Permitido | Permitido |
| Cao + Gato | Permitido | Nao recomendado |
| Macho + Femea | Permitido | Permitido |
| Macho + Macho | Permitido | Nao permitido |
| Femea + Femea | Permitido | Nao permitido |

### 5.3 Pos-Match
| Acao | Descricao |
|------|-----------|
| Notificacao | Push + In-app para ambos |
| Chat | Disponivel imediatamente |
| Desfazer | Pode desfazer a qualquer momento |
| Bloquear | Remove match + impede novos |

---

## 6. Chat

### 6.1 Tipos de Mensagem
| Tipo | Gratuito | Premium |
|------|----------|---------|
| Texto | Sim (50/dia) | Ilimitado |
| Foto | 1/dia | Ilimitado |
| Localizacao | 3x/dia | Ilimitado |
| Audio | Nao | Sim |
| Video | Nao | Sim |

### 6.2 Moderacao
| Regra | Descricao |
|-------|-----------|
| Links externos | Bloqueados |
| Numeros de telefone | Bloqueados (ate match confirmado) |
| Palavras ofensivas | IA de moderacao |
| Spam | Max 10 msgs iguais consecutivas |
| Denuncia | Botao disponivel em todas as msgs |

### 6.3 Real-time
- Mensagens aparecem instantaneamente
- Indicador de "digitando..."
- Status online do tutor
- Marcar como lida

---

## 7. Notificacoes

### 7.1 Tipos
| Tipo | Push | In-App | Email |
|------|------|--------|-------|
| Novo match | Sim | Sim | Nao |
| Nova mensagem | Sim | Sim | Nao |
| Super like recebido | Sim | Sim | Sim |
| 10 curtidas recebidas | Sim | Sim | Nao |
| Novidades do app | Nao | Sim | Sim |
| Renovacao premium | Nao | Sim | Sim |

### 7.2 Limites
| Canal | Limite |
|-------|--------|
| Push | Max 5/dia |
| Email | Max 2/semana |

---

## 8. Perfil do Tutor

### 8.1 Informacoes
| Campo | Visibilidade |
|-------|--------------|
| Nome | Publico |
| Foto | Publico |
| Localizacao | Aproximada (bairro/cidade) |
| Email | Privado |
| Telefone | Privado |
| Pets cadastrados | Publico (quantidade) |

### 8.2 Estatisticas
| Metrica | Descricao |
|---------|-----------|
| Curtidas recebidas | Total de likes nos pets |
| Conversas ativas | Chat em andamento |
| Encontros realizados | Avaliacoes pos-encontro |

---

## 9. Premium

### 9.1 Funcionalidades
| Recurso | Gratuito | Premium |
|---------|----------|---------|
| Pets cadastrados | 2 | Ilimitado |
| Likes diarios | 20 | Ilimitado |
| Super likes | 1/dia | Ilimitado |
| Filtros avancados | Nao | Sim |
| Ver quem curtiu | Nao | Sim |
| Mensagens de voz | Nao | Sim |
| Mensagens de video | Nao | Sim |
| Raio de busca | 30km | 100km |
| Remover anuncios | Nao | Sim |
| Boost mensal | Nao | 1x/mes |

### 9.2 Funcionalidades Avulsas
| Item | Preco |
|------|-------|
| Super like avulso | R$ 4,90 |
| Boost (24h) | R$ 9,90 |
| Destaque por 7 dias | R$ 14,90 |

---

## 10. Avaliacoes

### 10.1 Regras
| Regra | Descricao |
|-------|-----------|
| Quando | 24h apos primeiro chat |
| Frequencia | Uma vez por match |
| Obrigatorio | Nao (opcional) |

### 10.2 Sistema de Nota
| Nota | Significado |
|------|-------------|
| 5 estrelas | Excelente experiencia |
| 4 estrelas | Boa experiencia |
| 3 estrelas | Regular |
| 2 estrelas | Ruim |
| 1 estrela | Muito ruim |

### 10.3 Consequencias
| Media | Acao |
|-------|------|
| Abaixo de 2.0 | Badge "atencao" no perfil |
| Abaixo de 1.5 | Revisao manual do perfil |
| Abaixo de 1.0 | Possivel banimento |

---

## 11. Denuncias

### 11.1 Categorias
| Categoria | Descricao |
|-----------|-----------|
| animal_abuse | Maus-tratos ao animal |
| animal_neglect | Negligencia com o animal |
| fake_profile | Perfil falso |
| harassment | Assedio entre tutores |
| scam | Golpe ou fraude |
| spam | Mensagens indesejadas |
| inappropriate_content | Conteudo inadequado |
| minor_using_app | Menor de idade usando app |

### 11.2 Processo
| Etapa | Descricao |
|-------|-----------|
| 1. Denuncia | Tutor reporta problema |
| 2. Analise | Equipe revisa em ate 24h |
| 3. Acao | Aviso, suspensao ou banimento |
| 4. Feedback | Notifica denunciante do resultado |
