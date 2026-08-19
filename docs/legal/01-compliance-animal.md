# 01 - Compliance Animal - Legislacao Aplicavel

## Visao Geral

O PetMatch deve atender todas as legislacoes brasileiras de protecao animal para garantir conformidade legal e etica.

---

## 1. Legislacao Federal

### 1.1 Constituicao Federal (Art. 225, 1, VII)

> "... vedadas, na forma da lei, as praticas que coloquem em risco sua funcao ecologica, provoquem a extincao de especies ou **submetam os animais a crueldade**."

**Impacto no app:** O PetMatch deve promover a posse responsavel e nao pode ser utilizado como ferramenta para crueldade ou maus-tratos.

### 1.2 Lei 9.605/1998 - Lei de Crimes Ambientais (Art. 32)

| Dispositivo | Detalhe |
|-------------|---------|
| Tipo penal | Abuso, maus-tratos, ferir ou mutilar animais domesticos |
| Pena geral | Detencao de 3 meses a 1 ano + multa |
| Acao penal | Publica incondicionada |

**Impacto no app:** O PetMatch deve ter mecanismos para identificar e reportar possiveis casos de maus-tratos.

### 1.3 Lei 14.064/2020 - "Lei Sansao"

| Dispositivo | Detalhe |
|-------------|---------|
| Alvo | Caes e gatos especificamente |
| Pena agravada | Reclusao de 2 a 5 anos + multa + **prohibicao de guarda** |
| Aumento de pena | +1/6 a +1/3 se houver morte do animal |
| Proibicao adicional | Tatuagem e piercings esteticos em caes e gatos |

**Impacto no app:** Regra de ouro - o app NAO pode ser usado para:
- Cruzamento que resulte em sofrimento animal
- Comercializacao ilegal de filhotes
- Qualquer forma de exploracao

### 1.4 Lei 15.046/2024 - Cadastro Nacional de Animais Domesticos (Dez/2024)

| Dispositivo | Detalhe |
|-------------|---------|
| Obrigacao | Cadastro de animais domesticos com dados do tutor |
| Dados | Identidade, CPF, endereco, raca, sexo, idade, vacinas, doencas |
| Responsavel | Uniao (implementacao), Municipios (cadastramento), Estados (fiscalizacao) |
| Acesso | Publico, disponivel pela internet |

**Impacto no app:** O PetMatch pode se integrar ao Cadastro Nacional no futuro, validando dados dos pets cadastrados.

---

## 2. Legislacao Estadual (Referencia: Sao Paulo)

### 2.1 Lei 17.972/2024 - Protecao Animal em SP

| Dispositivo | Detalhe |
|-------------|---------|
| Idade minima comercializacao | **120 dias** |
| Vacinacao | Ciclo completo (3 doses + antirrabica) |
| Esterilizacao | Obrigatoria para comercializacao (com excecoes para criadores) |
| Microchipagem | Obrigatoria |
| Plataformas digitais | Devem observar as mesmas regras de comercio |
| Proibido | Brindes, sorteios, exposicao em rua |

**Impacto no app:** Regras de referencia para o PetMatch - o app deve exigir:
- Idade minima de 120 dias para cadastrar
- Dados de vacinacao (mesmo que opcionais)
- Nao promover comercializacao ilegal

---

## 3. Regras de Conformidade para o App

### 3.1 Cadastro de Pet - Validacoes

| Regra | Base Legal | Implementacao |
|-------|------------|---------------|
| Idade minima 120 dias | Lei 17.972/2024 (SP) | Campo data de nascimento obrigatorio |
| Tutor maior de 18 anos | Codigo Civil | Validacao no cadastro do tutor |
| Nao comercializar filhotes menores | Lei 17.972/2024 | Bloquear funcao de venda para <120 dias |
| Nao promover crueldade | Art. 32, Lei 9.605/1998 | Termos de uso + moderacao |
| Dados de vacinacao (opcional) | Conformidade voluntaria | Campo opcional com destaque |

### 3.2 Funcionalidades Proibidas/Restritas

| Funcionalidade | Status | Justificativa |
|----------------|--------|---------------|
| Venda de filhotes | Proibida | Lei 17.972/2024 |
| Comercializacao direta | Restrita | Exigir CNPJ para criadores |
| Troca de filhotes menores de 120 dias | Proibida | Lei 17.972/2024 |
| Divulgacao de canis/gateis nao licenciados | Proibida | Lei 17.972/2024 |
| Cruzamento forcado | Proibida | Lei Sansao |
| Cobranca por filhotes | Restrita | Tutores combinam entre si |

---

## 4. Checklist de Conformidade Animal

```
PRE-LANCAMENTO:
☐ Verificar idade minima do pet (120 dias)
☐ Verificar idade minima do tutor (18 anos)
☐ Termos de uso mencionam proibicao de crueldade
☐ Mecanismo de denuncia implementado
☐ Politica de moderacao definida
☐ Equipe de moderacao treinada

POS-LANCAMENTO:
☐ Monitoramento de denuncias
☐ Revisao de perfis sinalizados
☐ Cooperacao com autoridades (se necessario)
☐ Atualizacao conforme novas leis
```
