# 02 - LGPD - Lei Geral de Protecao de Dados

## Visao Geral

A LGPD (Lei 13.709/2018) regula o tratamento de dados pessoais no Brasil. O PetMatch deve estar em total conformidade com esta legislacao.

---

## 1. Classificacao dos Dados no App

### 1.1 Dados Pessoais (protegidos pela LGPD)

| Dado | Classificacao | Base Legal |
|------|---------------|------------|
| Nome do tutor | Dado pessoal | Art. 7, I (consentimento) |
| Email do tutor | Dado pessoal | Art. 7, I (consentimento) |
| Telefone do tutor | Dado pessoal | Art. 7, I (consentimento) |
| Localizacao do tutor | Dado pessoal sensivel | Art. 11, II, f (protecao da vida) |
| Foto do tutor | Dado pessoal | Art. 7, I (consentimento) |
| CPF (se coletado) | Dado pessoal sensivel | Art. 11, II, a (obrigacao legal) |

### 1.2 Dados NAO Protegidos pela LGPD

| Dado | Classificacao | Motivo |
|------|---------------|--------|
| Nome do pet | Nao e dado pessoal | Dado animal |
| Raca do pet | Nao e dado pessoal | Dado animal |
| Fotos do pet | Nao e dado pessoal | Dado animal |
| Localizacao do pet | Indiretamente identifica | Art. 7, I (consentimento) |

> Importante: Dados dos animais NAO sao protegidos pela LGPD (que protege pessoa humana), mas dados do TUTOR sim.

---

## 2. Principios LGPD Aplicaveis (Art. 6)

| Principio | Aplicacao no PetMatch |
|-----------|----------------------|
| **Finalidade** | Dados usados apenas para conexao entre tutores/pets |
| **Adequacao** | Coletar apenas dados necessarios ao servico |
| **Necessidade** | Minimo de dados para funcionar |
| **Livre acesso** | Tutor pode ver seus dados a qualquer momento |
| **Qualidade dos dados** | Dados atualizados e corretos |
| **Transparencia** | Politica de privacidade clara e acessivel |
| **Seguranca** | Criptografia e protecao dos dados |
| **Prevencao** | Medidas para evitar vazamentos |
| **Nao discriminacao** | Nao usar dados para discriminar |
| **Responsabilizacao** | Empresa responde por seus dados |

---

## 3. Bases Legais para Tratamento

| Operacao | Base Legal | Justificativa |
|----------|------------|---------------|
| Cadastro | Consentimento (Art. 7, I) | Usuario concorda ao se cadastrar |
| Localizacao | Consentimento (Art. 7, I) | Solicitar permissao ativa |
| Match | Consentimento (Art. 7, I) | Usuario curte voluntariamente |
| Chat | Consentimento (Art. 7, I) | Usuario inicia conversa |
| Notificacoes push | Consentimento (Art. 7, I) | Opt-in ativo |
| Denuncias | Legitimo interesse (Art. 7, IX) | Protecao da comunidade |
| Pagamentos | Obrigacao legal (Art. 7, II) | NF-e, impostos |
| Dados de saude do pet | Legitimo interesse (Art. 7, IX) | Seguranca dos pets envolvidos |

---

## 4. Direitos dos Titulares (Art. 18)

| Direito | Implementacao no App |
|---------|---------------------|
| Confirmacao da existencia de tratamento | Tela de Privacidade |
| Acesso aos dados | "Meus Dados" no perfil |
| Correcao de dados | Editar perfil |
| Anonimizacao/bloqueio/eliminacao | "Deletar Conta" |
| Portabilidade | Exportar dados em JSON/CSV |
| Eliminacao de dados tratados com consentimento | "Deletar Conta" |
| Informacao sobre compartilhamento | Politica de Privacidade |
| Revogacao do consentimento | Settings > Privacidade |
| Oposicao a tratamento nao consentido | Configuracoes |

---

## 5. Obrigacoes do Controlador (PetMatch)

| Obrigacao | Implementacao |
|-----------|---------------|
| Encarregado de Dados (DPO) | Nomear DPO (Art. 41) |
| Relatorio de Impacto (RIPD) | Criar antes do lancamento (Art. 38) |
| Comunicacao de incidentes | Notificar ANPD em 72h (Art. 48) |
| Registro de operacoes | Manter log de tratamentos (Art. 37) |
| Politica de privacidade | Documento publico e acessivel |
| Termos de uso | Contrato digital com consentimento |

---

## 6. Penalidades LGPD (Art. 52)

| Infracao | Penalidade |
|----------|------------|
| Leve | Advertencia + prazo para correcao |
| Media | Multa de **2% do faturamento** (max R$ 50 milhoes/infra) |
| Grave | Bloqueio dos dados |
| Muito grave | Eliminacao dos dados |
| Recorrente | Suspensao parcial do funcionamento |

---

## 7. Conformidade Tecnica

### 7.1 Medidas de Seguranca

| Medida | Descricao |
|--------|-----------|
| **Criptografia** | TLS 1.3 para transmissao, AES-256 para armazenamento |
| **Anonimizacao** | Localizacao nunca exata (aproximada por bairro) |
| **Consentimento** | Checkbox ativo em todas as coletas de dados |
| **Opt-out** | Facil cancelamento de notificacoes e compartilhamento |
| **Retencao** | Dados mantidos apenas enquanto conta ativa |
| **Backup** | Criptografado com acesso restrito |
| **Logs** | Auditoria de acessos aos dados |
| **DPO** | Encarregado acessivel pelo app |
| **RIPD** | Relatorio antes do lancamento |
| **Cookies** | Banner de consentimento (se web) |

### 7.2 Retencao de Dados

| Tipo de Dado | Periodo de Retencao |
|--------------|---------------------|
| Dados da conta | Enquanto conta ativa |
| Dados de pagamento | 5 anos (obrigacao fiscal) |
| Logs de auditoria | 5 anos |
| Logs de consentimento | Enquanto conta ativa + 5 anos |
| Mensagens | 1 ano apos exclusao da conta |
| Fotos | Enquanto conta ativa |

---

## 8. Documentos Obrigatorios

| Documento | Obrigatorio? | Conteudo |
|-----------|--------------|----------|
| **Termos de Uso** | Sim | Regras de uso, responsabilidades, proibicoes |
| **Politica de Privacidade** | Sim | Dados coletados, uso, compartilhamento, direitos |
| **Consentimento LGPD** | Sim | Base legal para cada tratamento |
| **RIPD** | Sim | Relatorio de Impacto a Protecao de Dados |
| **Politica de Cookies** | Se web | Uso de cookies e rastreadores |
| **LGPD Kids** | Se <14 anos | ECA Digital (se aplicavel) |

---

## 9. Fluxo de Consentimento

```
1. Usuario abre app pela 1a vez
  |
  v
2. Exibe Termos de Uso + Politica de Privacidade
  |
  v
3. Usuario marca checkbox "Li e aceito"
  |
  v
4. Registra consentimento:
  - user_id
  - consent_type: "terms_of_use"
  - granted: true
  - ip_address
  - version: "1.0.0"
  - created_at
  |
  v
5. Solicita permissoes adicionais:
  - Localizacao (opt-in)
  - Notificacoes push (opt-in)
  |
  v
6. Registra cada consentimento separadamente
```

---

## 10. Direito de Exclusao (Deletar Conta)

```
1. Usuario solicita exclusao
  |
  v
2. Confirma exclusao
  |
  v
3. Soft delete (deleted_at)
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
  - Auditoria (5 anos)
  - Metricas agregadas
  |
  v
6. Registra consent log de exclusao
  |
  v
7. Registra audit log
```

---

## 11. Checklist de Conformidade LGPD

```
PRE-LANCAMENTO:
☐ Termos de Uso redigidos e publicados
☐ Politica de Privacidade redigida e publicada
☐ Consentimento LGPD em todas as telas de coleta
☐ RIPD (Relatorio de Impacto) elaborado
☐ DPO (Encarregado) nomeado e acessivel
☐ Mecanismo de exclusao de dados implementado
☐ Criptografia implementada (TLS + AES)
☐ Politica de retencao de dados definida
☐ Banner de cookies implementado (se web)
☐ Mecanismo de denuncia implementado
☐ Verificacao de idade minima (18 anos)
☐ Verificacao de idade do pet (120 dias)
☐ Politica de moderacao de conteudo definida
☐ Canal de comunicacao com ANPD definido
☐ Plano de resposta a incidentes definido

POS-LANCAMENTO:
☐ Monitoramento de conformidade continuo
☐ Revisao trimestral da politica de privacidade
☐ Treinamento da equipe sobre LGPD
☐ Auditoria anual de seguranca
☐ Atualizacao conforme novas leis
```
