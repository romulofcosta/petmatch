# Politica de Privacidade - PetMatch

**Ultima atualizacao:** Janeiro 2025

Em conformidade com a Lei Geral de Protecao de Dados Pessoais (Lei 13.709/2018 - LGPD).

---

## 1. Controlador dos Dados

| Campo | Dado |
|-------|------|
| Nome/Razao Social | [Razao Social] |
| CNPJ | [XX.XXX.XXX/XXXX-XX] |
| Endereco | [Endereco completo] |
| Email | privacidade@petmatch.com.br |
| Encarregado (DPO) | [Nome do DPO] |
| Email DPO | dpo@petmatch.com.br |

---

## 2. Dados Coletados

### 2.1 Dados de Identificacao

| Dado | Finalidade | Base Legal |
|------|------------|------------|
| Nome completo | Identificacao do tutor | Execucao de contrato (Art. 7o, V) |
| Email | Login e comunicacoes | Execucao de contrato (Art. 7o, V) |
| Telefone | Verificacao e suporte | Execucao de contrato (Art. 7o, V) |
| Data de nascimento | Verificacao de maioridade | Obligacao legal (Art. 7o, II) |
| Foto de perfil | Identificacao no app | Consentimento (Art. 7o, I) |

### 2.2 Dados de Localizacao

| Dado | Finalidade | Base Legal |
|------|------------|------------|
| Localizacao GPS | Busca por proximidade | Consentimento (Art. 7o, I) |
| Cidade/Estado | Filtros regionais | Execucao de contrato (Art. 7o, V) |
| Geohash | Eficiencia na busca | Legitimo interesse (Art. 7o, IX) |

### 2.3 Dados de Pets

| Dado | Finalidade | Base Legal |
|------|------------|------------|
| Nome do pet | Identificacao | Execucao de contrato (Art. 7o, V) |
| Raca | Compatibilidade | Execucao de contrato (Art. 7o, V) |
| Sexo | Compatibilidade | Execucao de contrato (Art. 7o, V) |
| Data de nascimento | Verificacao de idade minima | Obligacao legal (Art. 7o, II) |
| Fotos | Exibicao no feed | Consentimento (Art. 7o, I) |
| Interesses | Matching | Consentimento (Art. 7o, I) |
| Dados veterinarios | Informacoes opcionais | Consentimento (Art. 7o, I) |

### 2.4 Dados de Uso

| Dado | Finalidade | Base Legal |
|------|------------|------------|
| Swipes | Melhorar recomendacoes | Legitimo interesse (Art. 7o, IX) |
| Mensagens | Funcionamento do chat | Execucao de contrato (Art. 7o, V) |
| Tempo de uso | Analytics | Legitimo interesse (Art. 7o, IX) |
| Erros/Crashes | Correcao de bugs | Legitimo interesse (Art. 7o, IX) |

### 2.5 Dados de Pagamento

| Dado | Finalidade | Base Legal |
|------|------------|------------|
| Dados do cartao | Processamento de pagamento | Execucao de contrato (Art. 7o, V) |
| Historico de compras | Fiscal e suporte | Obligacao legal (Art. 7o, II) |
| Notas fiscais | Cumprimento fiscal | Obligacao legal (Art. 7o, II) |

---

## 3. Principios de Tratamento (Art. 6o LGPD)

| Principio | Aplicacao no PetMatch |
|-----------|----------------------|
| Finalidade | Dados coletados para fins especificos e legitimos |
| Adequacao | Tratamento compativel com a finalidade declarada |
| Necessidade | Coleta minima necessaria para o servico |
| Livre acesso | Usuario pode acessar seus dados a qualquer momento |
| Qualidade | Dados mantidos atualizados e precisos |
| Transparencia | Esta Politica descreve todas as praticas |
| Seguranca | Medidas tecnicas e administrativas implementadas |
| Nao discriminacao | Dados nao sao usados para discriminacao |
| Responsabilizacao | Demonstracao de aderencia aos principios |

---

## 4. Compartilhamento de Dados

### 4.1 Com Quem Compartilhamos

| Destinatario | Dados | Finalidade |
|--------------|-------|------------|
| Stripe | Dados de pagamento | Processamento de cobranca |
| Firebase (Google) | Token FCM | Notificacoes push |
| Supabase | Todos os dados | Hospedagem do backend |
| NFe.io | Dados fiscais | Emissao de notas fiscais |
| Autoridades | Dados quando solicitado | Cumprimento de obrigacao legal |

### 4.2 Nao Compartilhamos

- Dados de localizacao exata com outros usuarios (apenas distancia aproximada)
- Dados de pagamento com terceiros (alem do Stripe)
- Dados de saude do pet com terceiros
- Dados pessoais para fins de marketing de terceiros

---

## 5. Retencao de Dados

| Tipo de Dado | Prazo de Retencao |
|--------------|-------------------|
| Dados de conta | Ate exclusao pela usuario + 30 dias |
| Dados de pets | Ate exclusao pelo tutor + 30 dias |
| Mensagens | 2 anos apos envio |
| Swipes/Matches | 1 ano apos criacao |
| Logs de auditoria | 5 anos (obrigacao legal) |
| Consentimentos | 5 anos apos revogacao |
| Notas fiscais | 5 anos (obrigacao fiscal) |
| Dados de pagamento | 5 anos (obrigacao fiscal) |

---

## 6. Direitos do Titular (Art. 18 LGPD)

O usuario tem direito a:

| Direito | Como exercer |
|---------|-------------|
| **Confirmacao** | Solicitar confirmacao do tratamento |
| **Acesso** | Acessar todos os dados pessoais |
| **Correcao** | Corrigir dados incompletos ou desatualizados |
| **Anonimizacao** | Anonimizar dados desnecessarios |
| **Bloqueio** | Bloquear dados tratados indevidamente |
| **Eliminacao** | Excluir dados tratados com consentimento |
| **Portabilidade** | Exportar dados em formato estruturado |
| **Informacao** | Saber com quem dados foram compartilhados |
| **Revogacao** | Revogar consentimento a qualquer momento |
| **Oposicao** | Opor-se a tratamento em caso delegitimo interesse |

### 6.1 Como Exercer

- **In-app:** Configuracoes > Privacidade > Meus Dados
- **Email:** privacidade@petmatch.com.br
- **Prazo de resposta:** 15 dias uteis (Art. 18, §5o)

---

## 7. Seguranca dos Dados

### 7.1 Medidas Tecnicas

| Medida | Descricao |
|--------|-----------|
| Criptografia em transito | TLS 1.3 em todas as comunicacoes |
| Criptografia em repouso | AES-256 para dados sensiveis |
| Autenticacao | JWT com expiracao curta |
| RLS | Row Level Security no PostgreSQL |
| Backups | Diarios com criptografia |
| Logs de acesso | Auditoria completa de acessos |

### 7.2 Medidas Administrativas

| Medida | Descricao |
|--------|-----------|
| Acesso restrito | Equipe com acesso minimo necessario |
| Treinamento | Equipe treinada em seguranca de dados |
| Acordo de confidencialidade | Contratos com colaboradores |
| Politica de senha | Senhas fortes obrigatorias |
| Revisao periodica | Auditorias trimestrais |

---

## 8. Menores de Idade

O PetMatch e voltado para **maiores de 18 anos**. Nao coletamos dados de menores intencionalmente. Se descobrirmos que um menor forneceu dados, excluiremos imediatamente.

Para animais, a idade minima e de **120 dias (4 meses)** conforme Lei 17.972/2024 (SP).

---

## 9. Cookies e Rastreadores

O PetMatch usa:

- **Cookies essenciais**: Para autenticacao e seguranca
- **Cookies de analise**: Para melhorar o servico (opt-in)
- **Nao usa cookies de terceiros** para rastreamento

---

## 10. Transferencia Internacional

Os dados podem ser processados em servidores fora do Brasil (Supabase Cloud). Nesses casos, garantimos:

- Paises com nivel adequado de protecao (Art. 33, I)
- Ou clausulas contratuais padrao (Art. 33, II, b)
- Ou consentimento especifico do titular (Art. 33, I)

---

## 11. Alteracoes nesta Politica

Alteracoes significativas serao comunicadas:

- **Email** para todos os usuarios ativos
- **Notificacao no app** com 30 dias de antecedencia
- **Versao atualizada** com data de "ultima atualizacao"

O uso continuado apos as alteracoes implica aceitacao.

---

## 12. Canal de Contato

| Canal | Contato | Prazo |
|-------|---------|-------|
| Privacidade | privacidade@petmatch.com.br | 15 dias uteis |
| DPO | dpo@petmatch.com.br | 15 dias uteis |
| Ouvidoria | ouvidoria@petmatch.com.br | 15 dias uteis |
| ANPD |.gov.br/anpd | Conforme regulamentacao |

---

## 13. Bases Legais Resumidas

| Base Legal | Art. 7o LGPD | Quando Aplicada |
|------------|-------------|-----------------|
| Consentimento | I | Fotos, localizacao, interesses |
| Obrigacao legal | II | Idade, notas fiscais, logs |
| Execucao de contrato | V | Cadastro, matching, chat |
| Legitimo interesse | IX | Analytics, seguranca, melhoria |
