# 05 - Fluxos de Usuario

## Visao Geral

O PetMatch possui 4 fluxos principais que o usuario percorre.

---

## Fluxo 1: Primeiro Acesso

```
Inicio
  |
  v
Splash Screen (2-3s)
  |
  v
Welcome/Onboarding (3 slides)
  |
  +---> Pular onboarding ---> Login
  |
  v
Login
  |
  +---> Ja tem conta? ---> Login
  |
  +---> Nao tem conta? ---> Cadastro
  |
  v
Cadastro (nome, email, senha)
  |
  v
Verificacao de email
  |
  v
Cadastro Pet - Step 1 (dados basicos)
  |
  v
Cadastro Pet - Step 2 (interesses)
  |
  v
Cadastro Pet - Step 3 (dados veterinarios)
  |
  v
Permissoes (GPS/Camera)
  |
  v
Home/Feed (inicio do app)
```

**Tempo estimado:** 3-5 minutos

---

## Fluxo 2: Swipe + Match

```
Home/Feed
  |
  v
Visualiza pet no card
  |
  +---> Passar (X) ---> Proximo pet
  |
  +---> Super Like (*) ---> Verifica limite -> Registra swipe -> Verifica match
  |
  +---> Curtir (@) ---> Verifica limite -> Registra swipe -> Verifica match
  |
  v
Verificacao de Match
  |
  +---> Nao houve match ---> Proximo pet
  |
  +---> Houve match ---> Tela de Match
  |
  v
Tela de Match
  |
  +---> Enviar mensagem ---> Chat
  |
  +---> Continuar descobrindo ---> Home/Feed
```

### Detalhamento do Swipe

```
Tutor A curte pet do Tutor B
  |
  v
1. Verificar se Tutor B ja curtiu algum pet do Tutor A
  |
  +---> NAO: Apenas registra swipe
  |
  +---> SIM: Cria match!
  |
  v
2. Criar registro na tabela matches
  |
  v
3. Criar conversa
  |
  v
4. Notificar ambos os tutores
  |
  v
5. Registrar audit log
```

### Regras de Limite

```
Tutor clica em Curtir
  |
  v
Verificar se e Premium
  |
  +---> SIM: Permite (ilimitado)
  |
  +---> NAO: Verificar likes hoje
          |
          +---> < 20: Permite
          |
          +---> >= 20: Bloqueia (limite atingido)
```

---

## Fluxo 3: Chat

```
Matches
  |
  v
Seleciona conversa
  |
  v
Chat Room
  |
  v
Visualiza mensagens anteriores
  |
  v
Digita mensagem
  |
  v
Envia mensagem
  |
  v
1. Verificar limite de mensagens
  |
  +---> Dentro do limite: Envia
  |
  +---> Fora do limite: Bloqueia
  |
  v
2. Verificar moderacao de conteudo
  |
  +---> Conteudo OK: Envia
  |
  +---> Conteudo proibido: Bloqueia
  |
  v
3. Salva mensagem no banco
  |
  v
4. Envia via Realtime para o outro tutor
  |
  v
5. Envia notificacao push (se app fechado)
  |
  v
6. Registra audit log
```

### Fluxo de Compartilhamento

```
Tutor quer enviar foto
  |
  v
Verificar plano
  |
  +---> Premium: Permite (ilimitado)
  |
  +---> Gratuito: Verificar fotos hoje
          |
          +---> 0: Permite (1/dia)
          |
          +---> >= 1: Bloqueia
  |
  v
 seleciona foto da galeria
  |
  v
 Upload para Supabase Storage
  |
  v
 Envia mensagem com URL da foto
```

---

## Fluxo 4: Feed com Filtros

```
Home/Feed
  |
  v
Clica em Filtros
  |
  v
Tela de Filtros
  |
  v
Seleciona filtros
  |
  v
Aplica filtros
  |
  v
1. Verificar se filtros sao Premium
  |
  +---> Filtros basicos: Permite
  |
  +---> Filtros avancados: Verifica Premium
          |
          +---> Premium: Permite
          |
          +---> Gratuito: Bloqueia
  |
  v
2. Monta query com filtros
  |
  v
3. Executa busca geografica (PostGIS)
  |
  v
4. Retorna lista de pets
  |
  v
5. Exibe cards no feed
```

---

## Fluxo 5: Gerenciamento de Perfil

```
Meu Perfil
  |
  v
+---> Editar perfil ---> Salvar alteracoes
  |
  +---> Meus pets ---> Lista de pets
  |       |
  |       +---> Ver detalhes ---> Perfil do Pet
  |       |
  |       +---> Editar pet ---> Salvar alteracoes
  |       |
  |       +---> Adicionar pet ---> Cadastro Pet (3 steps)
  |       |
  |       +---> Remover pet ---> Soft delete
  |
  +---> Estatisticas ---> Metricas do perfil
  |
  +---> Configuracoes ---> Tela de configuracoes
```

---

## Fluxo 6: Denuncia

```
Qualquer tela
  |
  v
Clica em Denunciar
  |
  v
Seleciona categoria
  |
  v
Adiciona descricao (opcional)
  |
  v
Adiciona provas - fotos/videos (opcional)
  |
  v
Envia denuncia
  |
  v
1. Cria registro na tabela reports
  |
  v
2. Notifica equipe de moderacao
  |
  v
3. Confirma para o denunciante
  |
  v
4. Registra audit log
```

### Fluxo de Revisao (Admin)

```
Denuncia recebida
  |
  v
Equipe de moderacao analisa
  |
  v
+---> Sem fundamento ---> Descarta denuncia
  |
  +---> Com fundamento ---> Toma acao
  |
  v
Acao tomada
  |
  +---> Aviso ---> Notifica usuario
  |
  +---> Suspensao (7 dias) ---> Notifica usuario
  |
  +---> Ban temporario (30 dias) ---> Notifica usuario
  |
  +---> Ban permanente ---> Notifica usuario
  |
  +---> Denuncia as autoridades ---> Registra acao
  |
  v
Notifica denunciante do resultado
```

---

## Fluxo 7: Assinatura Premium

```
Configuracoes / Tela Premium
  |
  v
Visualiza planos
  |
  v
Seleciona plano
  |
  v
1. Verifica gateway de pagamento
  |
  v
2. Cria sessao de checkout
  |
  v
3. Redireciona para pagamento
  |
  v
4. Processa pagamento
  |
  +---> Sucesso:
  |       |
  |       v
  |     5. Atualiza status da assinatura
  |       |
  |       v
  |     6. Ativa funcionalidades Premium
  |       |
  |       v
  |     7. Notifica usuario
  |       |
  |       v
  |     8. Registra audit log
  |
  +---> Falha:
          |
          v
        5. Notifica usuario do erro
          |
          v
        6. Registra tentativa
```

---

## Fluxo 8: Deletar Conta (LGPD)

```
Configuracoes
  |
  v
Deletar Conta
  |
  v
Confirma exclusao
  |
  v
1. Solicita motivo (opcional)
  |
  v
2. Soft delete (marca deleted_at)
  |
  v
3. Desativa perfil (is_active = false)
  |
  v
4. Remove dados pessoais:
  - Nome -> "Usuario Deletado"
  - Email -> hash anonimo
  - Telefone -> removido
  - Foto -> removida
  - Localizacao -> removida
  |
  v
5. Mantem dados anonimizados para:
  - Auditoria (LGPD)
  - Metricas agregadas
  |
  v
6. Registra consent log de exclusao
  |
  v
7. Registra audit log
  |
  v
8. Notifica usuario
```

---

## Resumo dos Fluxos

| Fluxo | Descricao | Tempo Estimado |
|-------|-----------|----------------|
| 1. Primeiro Acesso | Cadastro completo | 3-5 min |
| 2. Swipe + Match | Encontrar e conectar | 1-3 min |
| 3. Chat | Comunicacao | Variavel |
| 4. Feed + Filtros | Busca avancada | 1-2 min |
| 5. Gerenciamento | Perfil e pets | 5-10 min |
| 6. Denuncia | Reportar problema | 2-3 min |
| 7. Assinatura | Upgrade Premium | 2-3 min |
| 8. Deletar Conta | Exclusao LGPD | 1-2 min |
