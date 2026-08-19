# 04 - Regras de Negocio

## 1. Autenticacao e Conta

### 1.1 Cadastro
| Regra | Detalhe |
|-------|---------|
| Idade minima do tutor | 18 anos |
| Campos obrigatorios | Nome, Email, Senha |
| Senha | Minimo 8 caracteres, 1 maiuscula, 1 numero, 1 especial |
| Email | Validacao de formato + verificacao de dominio |
| Telefone | Formato (XX) XXXXX-XXXX, opcional |

### 1.2 Login
| Regra | Detalhe |
|-------|---------|
| Metodos | Email+Senha, Google, Apple |
| Tentativas | Maximo 5 tentativas antes de bloqueio temporario |
| Bloqueio | 15 min apos 5 tentativas falhas |
| Recuperacao de senha | Link valido por 24h, 1 uso |

### 1.3 Conta
| Regra | Detalhe |
|-------|---------|
| Editar email | Exige confirmacao no novo email |
| Deletar conta | Perde todos os dados permanentemente |
| Logout | Limpa sessao local |

---

## 2. Cadastro de Pet

### 2.1 Limite de Pets
| Plano | Limite |
|-------|--------|
| Gratuito | 2 pets por tutor |
| Premium | Ilimitado |

### 2.2 Dados Obrigatorios
| Campo | Regra |
|-------|-------|
| Nome | 2-30 caracteres, apenas letras e espacos |
| Tipo | Cao ou Gato (obrigatorio) |
| Sexo | Macho ou Femea (obrigatorio) |
| Raca | Obrigatorio selecionar da lista |
| Idade | Minimo 4 meses, maximo 20 anos |
| Foto principal | 1 foto obrigatoria (minimo 400x400px) |
| Interesse | Pelo menos 1: Socializacao, Cruzamento, Adocao |

### 2.3 Dados Opcionais
| Campo | Regra |
|-------|-------|
| Fotos adicionais | Maximo 6 fotos, 1MB cada |
| Peso | 0.5kg a 80kg |
| Descricao | Maximo 500 caracteres |
| Personalidade | Ate 5 tags selecionadas |
| Castrado | Sim/Nao |
| Vacinas | Sim/Nao |
| Pedigree | Sim/Nao |
| Veterinario | Nome + telefone (opcional) |
| Observacoes | Maximo 300 caracteres |

### 2.4 Validacao de Fotos
| Regra | Detalhe |
|-------|---------|
| Formatos aceitos | JPG, PNG, HEIC |
| Tamanho maximo | 1MB por foto |
| Resolucao minima | 400x400px |
| Proporcao | 1:1 (quadrada) ou 4:5 (retrato) |
| Conteudo proibido | Nudidade, violencia, animais mortos |
| IA de moderacao | Verificacao automatica antes de publicar |

---

## 3. Sistema de Swipe e Match

### 3.1 Likes Diarios
| Plano | Limite |
|-------|--------|
| Gratuito | 20 likes/dia |
| Premium | Ilimitado |

> Resets diariamente as 00:00 (horario local do tutor)

### 3.2 Super Like
| Plano | Limite |
|-------|--------|
| Gratuito | 1 super like/dia |
| Premium | Ilimitados |

> Super like tem prioridade no feed do pet destino

### 3.3 Algoritmo de Feed
| Regra | Prioridade |
|-------|------------|
| 1a | Pets na mesma cidade/regiao |
| 2a | Pets com interesses compativeis |
| 3a | Racas compativeis (mesmo porte) |
| 4a | Pets com perfil completo |
| 5a | Atividade recente do tutor |
| 6a | Pets nao visualizados recentemente |

### 3.4 Regras de Match
| Regra | Detalhe |
|-------|---------|
| Match | So acontece quando AMBOS curtem |
| Super Like | Notifica imediatamente o tutor destino |
| Desfazer match | Pode desfazer a qualquer momento |
| Block | Impede novo match e remove existente |

### 3.5 Filtros de Busca
| Filtro | Opcoes |
|--------|--------|
| Tipo | Cao, Gato, Todos |
| Raca | Lista completa (busca por nome) |
| Sexo | Macho, Femea, Todos |
| Idade | Filhote (0-1), Jovem (1-3), Adulto (3-7), Senior (7+) |
| Distancia | 5km a 100km (slider) |
| Interesse | Socializacao, Cruzamento, Adocao |
| Castrado | Sim, Nao, Todos |

> Filtros avancados: Exclusivos Premium

---

## 4. Sistema de Chat

### 4.1 Regras de Acesso
| Regra | Detalhe |
|-------|---------|
| Pre-requisito | Match confirmado entre ambos |
| Inicio | Apos match, qualquer um pode iniciar |
| Prazo | Sem prazo para iniciar conversa |
| Bloqueio | Pode bloquear a qualquer momento |

### 4.2 Limites do Chat
| Plano | Limite |
|-------|--------|
| Gratuito | 50 mensagens/dia por conversa |
| Premium | Ilimitado |

### 4.3 Tipos de Mensagem
| Tipo | Gratuito | Premium |
|------|----------|---------|
| Texto | Sim (50/dia) | Ilimitado |
| Foto | 1/dia | Ilimitado |
| Localizacao | 3x/dia | Ilimitado |
| Audio | Nao | Sim |
| Video | Nao | Sim |

### 4.4 Moderacao do Chat
| Regra | Detalhe |
|-------|---------|
| Palavras proibidas | Sistema de IA detecta ofensas |
| Spam | Maximo 10 mensagens iguais consecutivas |
| Links | Bloqueio automatico de links externos |
| Numeros de telefone | Bloqueio ate match confirmado |
| Denuncia | Botao disponivel em todas as mensagens |

### 4.5 Compartilhamento
| Permissao | Gratuito | Premium |
|-----------|----------|---------|
| Foto (galeria) | 1/dia | Ilimitado |
| Localizacao atual | 3x/dia | Ilimitado |
| Contato veterinario | Sim | Sim |

---

## 5. Sistema de Localizacao

### 5.1 Precisao
| Nivel | Detalhe |
|-------|---------|
| Perfil do pet | Bairro/Cidade (aproximado) |
| Feed | Distancia exata (km) |
| Chat | Compartilhamento opcional |

### 5.2 Permissoes
| Regra | Detalhe |
|-------|---------|
| Obrigatorio? | Nao (app funciona sem, mas com funcionalidade limitada) |
| Quando pedir | Apos cadastro do pet |
| Como pedir | Tela dedicada com explicacao |
| Sem permissao | Mostra pets de toda a regiao (sem filtro de distancia) |

### 5.3 Raio de Busca
| Plano | Raio padrao |
|-------|-------------|
| Gratuito | Ate 30km |
| Premium | Ate 100km |

> Tutor pode ajustar raio manualmente

---

## 6. Sistema de Match - Regras Especificas

### 6.1 Compatibilidade
| Cenario | Socializacao | Cruzamento |
|---------|--------------|------------|
| Cao + Cao | Permitido | Permitido |
| Gato + Gato | Permitido | Permitido |
| Cao + Gato | Permitido | Nao recomendado |
| Macho + Femea | Permitido | Permitido |
| Macho + Macho | Permitido | Nao permitido |
| Femea + Femea | Permitido | Nao permitido |

### 6.2 Regras de Cruzamento
| Regra | Detalhe |
|-------|---------|
| Verificacao | Tutor deve confirmar que pet esta saudavel |
| Recomendacao | Sugerir verificacao veterinaria antes do encontro |
| Responsabilidade | App nao se responsabiliza por filhotes |
| Cobranca | Tutores combinam valores entre si |

### 6.3 Pos-Match
| Acao | Detalhe |
|------|---------|
| Notificacao | Push + In-app para ambos |
| Chat | Disponivel imediatamente |
| Desfazer | Pode desfazer a qualquer momento |
| Bloquear | Remove match + impede novos |

---

## 7. Sistema de Avaliacao (Pos-Encontro)

### 7.1 Quando Pedir
| Regra | Detalhe |
|-------|---------|
| Timing | 24h apos o primeiro chat |
| Frequencia | Uma vez por match |
| Obrigatorio | Nao (opcional) |

### 7.2 Sistema de Nota
| Nota | Significado |
|------|-------------|
| 5 estrelas | Excelente experiencia |
| 4 estrelas | Boa experiencia |
| 3 estrelas | Regular |
| 2 estrelas | Ruim |
| 1 estrela | Muito ruim |

### 7.3 Consequencias
| Media | Acao |
|-------|------|
| Abaixo de 2.0 | Perfil fica com badge "atencao" |
| Abaixo de 1.5 | Revisao manual do perfil |
| Abaixo de 1.0 | Possivel banimento |

### 7.4 Denuncias
| Motivo | Acao |
|--------|------|
| Perfil falso | Verificacao + possivel ban |
| Assedio | Ban imediato + review |
| Animal maltratado | Ban + denuncia as autoridades |
| Spam | Aviso + possivel ban |

---

## 8. Sistema Premium (Freemium)

### 8.1 Funcionalidades Premium
| Recurso | Gratuito | Premium |
|---------|----------|---------|
| Pets cadastrados | 2 | Ilimitado |
| Likes diarios | 20 | Ilimitados |
| Super likes | 1/dia | Ilimitados |
| Filtros avancados | Nao | Sim |
| Ver quem curtiu | Nao | Sim |
| Mensagens de voz | Nao | Sim |
| Mensagens de video | Nao | Sim |
| Raio de busca | 30km | 100km |
| Remover anuncios | Nao | Sim |
| Boost mensal | Nao | 1x/mes |
| Relatorio de matches | Nao | Sim |

### 8.2 Planos
| Plano | Preco | Desconto |
|-------|-------|----------|
| Mensal | R$ 29,90/mes | - |
| Trimestral | R$ 69,90/trimestre | 22% off |
| Anual | R$ 199,90/ano | 44% off |

### 8.3 Funcionalidades Avulsas
| Item | Preco |
|------|-------|
| Super like avulso | R$ 4,90 |
| Boost (24h) | R$ 9,90 |
| Destaque por 7 dias | R$ 14,90 |

---

## 9. Sistema de Notificacoes

### 9.1 Tipos
| Tipo | Push | In-App | Email |
|------|------|--------|-------|
| Novo match | Sim | Sim | Nao |
| Nova mensagem | Sim | Sim | Nao |
| Super like recebido | Sim | Sim | Sim |
| 10 curtidas | Sim | Sim | Nao |
| Novidades do app | Nao | Sim | Sim |
| Renovacao premium | Nao | Sim | Sim |

### 9.2 Frequencia Maxima
| Regra | Limite |
|-------|--------|
| Push | Maximo 5/dia |
| Email | Maximo 2/semana |

### 9.3 Configuracoes
| Opcao | Padrao |
|-------|--------|
| Novos matches | ON |
| Mensagens | ON |
| Curtidas | ON |
| Marketing | OFF |

---

## 10. Moderacao e Seguranca

### 10.1 Perfil Falso
| Sinal | Acao |
|-------|------|
| Foto generica | Verificacao manual |
| Dados inconsistentes | Alerta + revisao |
| Denuncias multiplas | Suspensao temporaria |

### 10.2 Conteudo Proibido
| Tipo | Acao |
|------|------|
| Nudidade | Remocao imediata + ban |
| Violencia | Remocao + ban + denuncia |
| Drogas | Remocao + ban |
| Discurso de odio | Remocao + ban |
| Spam | Aviso + possivel ban |

### 10.3 Sistema de Ban
| Nivel | Duracao | Motivo |
|-------|---------|--------|
| Aviso | - | 1a infracao leve |
| Suspensao | 7 dias | 2a infracao leve ou 1a moderada |
| Ban temporario | 30 dias | Infracoes graves |
| Ban permanente | - | Assedio, maltrato animal, crime |

---

## 11. Dados e Privacidade

### 11.1 Dados Coletados
| Dado | Uso |
|------|-----|
| Localizacao | Encontrar pets proximos |
| Fotos | Perfil do pet |
| Dados de uso | Melhorar algoritmo |
| Dispositivo | Analytics |

### 11.2 Compartilhamento
| Dado | Compartilha? |
|------|--------------|
| Localizacao exata | Nunca (apenas bairro) |
| Telefone | So apos match + consentimento |
| Email | Nunca publicamente |
| Nome completo | So no perfil privado |

### 11.3 Direitos do Usuario
| Direito | Como exercer |
|---------|--------------|
| Acessar dados | Configuracoes > Privacidade |
| Deletar dados | Configuracoes > Conta |
| Exportar dados | Solicitacao via email |
| Revogar consentimento | Configuracoes > Privacidade |

---

## 12. Suporte

### 12.1 Canais
| Canal | Disponibilidade |
|-------|-----------------|
| Chat in-app | 24/7 (bot) + humano (horario comercial) |
| Email | Resposta em ate 24h |
| FAQ | Disponivel sempre |

### 12.2 Motivos de Contato
| Motivo | Tempo de Resposta |
|--------|-------------------|
| Conta bloqueada | Ate 2h |
| Pagamento | Ate 4h |
| Denuncia | Ate 24h |
| Duvida geral | Ate 24h |

---

## 13. Metricas de Sucesso (KPIs)

| Metrica | Meta MVP |
|---------|----------|
| Cadastros/mes | 1.000 |
| Matches/semana | 500 |
| Mensagens trocadas/mes | 10.000 |
| Conversao Free->Premium | 5% |
| Retencao D7 | 40% |
| Retencao D30 | 20% |
| NPS | > 50 |
