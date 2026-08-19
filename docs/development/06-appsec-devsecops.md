# 06 - AppSec e DevSecOps

## Visao Geral

Documento de seguranca da aplicacao e praticas DevSecOps do PetMatch. Complementa os docs existentes (RLS, LGPD, Edge Functions) focando nos gaps de seguranca nao cobertos.

---

## 1. OWASP Mobile Top 10 - Mapeamento

| # | Risco OWASP | Status | Documento de Referencia | Acao Necessaria |
|---|-------------|--------|------------------------|-----------------|
| M1 | Improper Credential Usage | Parcial | 06-appsec (este) | Definir gestao de chaves |
| M2 | Inadequate Supply Chain Security | Nao | 06-appsec (este) | Configurar dependabot |
| M3 | Insecure Auth/Authorization | **Coberto** | 04-rls-policies, 03-edge-functions | Nenhuma |
| M4 | Insufficient Input/Output Validation | **Coberto** | 03-edge-functions (validators.ts) | Nenhuma |
| M5 | Insecure Communication | Parcial | 06-appsec (este) | Cert pinning + headers |
| M6 | Inadequate Privacy Controls | **Coberto** | 02-lgpd | Nenhuma |
| M7 | Insufficient Binary Protections | Nao | 06-appsec (este) | Obfuscation + anti-tampering |
| M8 | Security Misconfiguration | Nao | 06-appsec (este) | Checklist de configuracao |
| M9 | Insecure Data Storage | Parcial | 06-appsec (este) | flutter_secure_storage |
| M10 | Insufficient Cryptography | Parcial | 02-lgpd (TLS 1.3, AES-256) | Documentar |

---

## 2. OWASP API Security Top 10 - Mapeamento

| # | Risco | Status PetMatch | Protecao |
|---|-------|-----------------|----------|
| API1 | Broken Object Level Authorization | **Coberto** | RLS policies (04-rls-policies) |
| API2 | Broken Authentication | **Coberto** | JWT + middleware (03-edge-functions) |
| API3 | Broken Object Property Level Authorization | Parcial | Campo a campo nas policies |
| API4 | Unrestricted Resource Consumption | **Coberto** | Rate limiting (100 req/min) |
| API5 | Broken Function Level Authorization | Parcial | service_role isolado |
| API6 | Unrestricted Access to Sensitive Business Flows | **Coberto** | Limites diarios (likes, msgs) |
| API7 | Server Side Request Forgery | Baixo risco | Supabase gerencia HTTP |
| API8 | Security Misconfiguration | Parcial | Checklist necessario |
| API9 | Improper Inventory Management | Nao | Mapear todos os endpoints |
| API10 | Unsafe Consumption of APIs | Baixo risco | Poucas integracoes externas |

---

## 3. Gestao de Segredos

### 3.1 O que e Segredo

| Tipo | Exemplo | Risco se Vazado |
|------|---------|-----------------|
| **Critico** | SUPABASE_SERVICE_ROLE_KEY | Acesso total ao banco |
| **Critico** | FCM_SERVER_KEY | Envio de notificacoes falsas |
| **Critico** | STRIPE_SECRET_KEY | Acesso a pagamentos |
| **Alto** | SUPABASE_ANON_KEY | Acesso nao autenticado |
| **Alto** | Database password | Acesso direto ao PostgreSQL |
| **Medio** | SUPABASE_URL | Informacao publica |

### 3.2 Regras de Segredos

```
NAO COMMITAR:
  - Chaves de API
  - Senhas de banco
  - Certificados
  - Tokens de acesso

NAO LOGAR:
  - Service role key
  - Credenciais de pagamento
  - Tokens de usuario

ROTACIONAR:
  - A cada 90 dias (chaves de producao)
  - Imediatamente apos vazamento suspeito
  - Ao mudar de equipe/acesso
```

### 3.3 Onde Armazenar

| Ambiente | Onde | Como |
|----------|------|------|
| Desenvolvimento | `.env` local | Nunca commitar (.gitignore) |
| CI/CD | GitHub Secrets | Variaveis criptografadas |
| Producao | Supabase Dashboard | Environment variables |
| Firebase | Firebase Console | Server key config |

### 3.4 Rotacao de Chaves

```bash
# Supabase: Settings > API > Regenerate keys
# Firebase: Settings > Cloud Messaging > Server key > Regenerate
# Stripe: Dashboard > Developers > API keys > Roll key
```

**Frequencia:** A cada 90 dias ou apos incidente de seguranca.

---

## 4. Seguranca do App Flutter

### 4.1 Certificado Pinning (SSL Pinning)

Previne ataques Man-in-the-Middle mesmo com certificados validos.

```yaml
# pubspec.yaml - adicionar
dependencies:
  flutter_secure_storage: ^9.2.2
```

```dart
// lib/core/network/certificate_pinner.dart
import 'dart:io';

class CertificatePinner {
  static const List<String> _pinnedCerts = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Supabase
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Firebase
  ];

  static HttpOverrides get httpOverrides => _PetMatchHttpOverrides();
}

class _PetMatchHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) {
      // Verificar se o certificado esta na lista de pins
      // Em producao: rejeitar certificados nao pinados
      return false; // Rejeitar por padrao
    };
    return client;
  }
}
```

**Nota:** Supabase e Firebase ja usam certificados validos. O pinning e uma camada adicional.

### 4.2 Obfuscation de Codigo

```bash
# Build release com obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```

**O que faz:** Torna o codigo Dart extremamente dificil de decompilar.

**IMPORTANTE:** Salve `build/debug-info/` em local seguro. Sem ele, crash reports nao serao simbolizados.

### 4.3 Detecao de Jailbreak/Root

```dart
// lib/core/utils/device_security.dart
class DeviceSecurity {
  static Future<bool> isDeviceCompromised() async {
    // Verificar jailbreak (iOS) ou root (Android)
    // Usar pacote JailBreakRootDetection ou similar
    return false;
  }

  static Future<void> checkAndAct() async {
    if (await isDeviceCompromised()) {
      // Opcao 1: Bloquear uso do app
      // Opcao 2: Mostrar alerta e continuar
      // Opcao 3: Desabilitar funcionalidades sensiveis
    }
  }
}
```

### 4.4 Armazenamento Seguro

```dart
// CORRETO: usar flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);

// Salvar token
await storage.write(key: 'auth_token', value: token);

// Ler token
final token = await storage.read(key: 'auth_token');

// NUNCA usar shared_preferences para dados sensiveis
// NUNCA logar tokens em producao
```

### 4.5 Biometria (Opcional)

```dart
// pubspec.yaml
dependencies:
  local_auth: ^2.3.0

// Uso
final localAuth = LocalAuthentication();
final didAuthenticate = await localAuth.authenticate(
  localizedReason: 'Autentique-se para acessar sua conta',
  options: const AuthenticationOptions(stickyAuth: true),
);
```

---

## 5. Pipeline de Seguranca (CI/CD)

### 5.1 Dependabot (GitHub)

`.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "dart"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 5.2 Secret Scanning

Adicionar ao `.github/workflows/ci.yml`:

```yaml
- name: Check for secrets in code
  uses: trufflesecurity/trufflehog@main
  with:
    extra_args: --only-verified
```

### 5.3 Dependencias com Vulnerabilidades

```yaml
# Adicionar ao CI
- name: Audit dependencies
  run: dart pub audit || true

- name: Check for known vulnerabilities
  run: |
    dart pub deps 2>/dev/null | grep -i "CVE" && echo "VULNERABILITY FOUND" && exit 1 || echo "No known vulnerabilities"
```

### 5.4 Security Lint Rules

```yaml
# analysis_options.yaml - adicionar
linter:
  rules:
    avoid_print: true  # Nao logar dados sensiveis
    avoid_relative_lib_imports: true
```

---

## 6. Seguranca de Rede

### 6.1 Headers de Seguranca

As Edge Functions devem retornar estes headers:

```typescript
// supabase/functions/_shared/security-headers.ts
export const securityHeaders = {
  "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "X-XSS-Protection": "1; mode=block",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Content-Security-Policy": "default-src 'self'",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=(self)",
};
```

### 6.2 CORS Restritivo

```typescript
// ATUAL (inseguro - wildcard):
"Access-Control-Allow-Origin": "*"

// CORRIGIDO (restritivo):
const allowedOrigins = [
  "https://petmatch.com.br",
  "https://app.petmatch.com.br",
];

export const corsHeaders = {
  "Access-Control-Allow-Origin": allowedOrigins.includes(origin)
    ? origin
    : allowedOrigins[0],
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Max-Age": "86400",
};
```

### 6.3 Limites de Requisicao

```typescript
// Adicionar ao inicio de cada Edge Function
const MAX_BODY_SIZE = 1024 * 1024; // 1MB

if (req.headers.get("content-length") &&
    parseInt(req.headers.get("content-length")!) > MAX_BODY_SIZE) {
  return new Response("Payload too large", { status: 413 });
}
```

---

## 7. Gestao de Vulnerabilidades

### 7.1 Ciclo de Vida

```
Descoberta → Triagem → Remediacao → Verificacao → Fechamento
    ↓           ↓           ↓             ↓            ↓
  Qualquer   Classificar  Corrigir    Testar fix   Documentar
  fonte      prioridade   o bug       + re-testar  + metrics
```

### 7.2 SLA por Severidade

| Severidade | Exemplo | Prazo de Correcao |
|------------|---------|-------------------|
| **Critico** | Vazamento de dados, service_role key exposta | 24 horas |
| **Alto** | Bypass de RLS, autenticacao quebrada | 72 horas |
| **Medio** | Rate limiting insuficiente, input nao sanitizado | 1 semana |
| **Baixo** | Headers faltando, logs incompletos | 2 semanas |
| **Info** | Melhorias de seguranca, hardening | Proximo sprint |

### 7.3 Fontes de Descoberta

| Fonte | Frequencia |
|-------|------------|
| Dependabot alerts | Automatico |
| Code review | Cada PR |
| Penetration testing | Trimestral |
| Bug bounty (futuro) | Continuo |
| Auditoria de seguranca | Anual |

---

## 8. Resposta a Incidentes

### 8.1 Playbook Tecnico

```
FASE 1: CONTENCAO (0-1 hora)
├── Identificar o que foi afetado
├── Revogar credenciais comprometidas
├── Bloquear vetor de ataque
├── Preservar evidencias (logs)
└── Notificar equipe de seguranca

FASE 2: ERRADICACAO (1-24 horas)
├── Corrigir vulnerabilidade
├── Rotacionar todos os segredos expostos
├── Verificar integridade dos dados
├── Aplicar patches de seguranca
└── Revisar configurations

FASE 3: RECUPERACAO (24-72 horas)
├── Restaurar servicos
├── Monitorar comportamento anomalo
├── Validar que o ataque nao continua
├── Testar funcionalidades criticas
└── Confirmar que dados estao seguros

FASE 4: FORENSE + DOCUMENTACAO (72 horas - 2 semanas)
├── Analise completa do incidente
├── Timeline de eventos
├── Raiz do problema
├── Acoes corretivas
├── Documentar lições aprendidas
└── Atualizar playbook se necessario
```

### 8.2 Notificacao Obrigatoria

| Destinatario | Prazo | Base Legal |
|--------------|-------|------------|
| ANPD | 72 horas | LGPD Art. 48 |
| Usuarios afetados | Imediatamente apos confirmacao | LGPD Art. 48 §1o |
| Equipe interna | Imediato | Politica interna |

### 8.3 Comunicacao aos Usuarios

```
Assunto: Aviso de Seguranca - PetMatch

Prezado(a) [Nome],

Identificamos uma violacao de seguranca que pode ter afetado seus dados.
[Dados especificos do que foi afetado]

Acoes que tomamos:
1. [Acao corretiva]
2. [Acao corretiva]

O que voce deve fazer:
1. [Recomendacao ao usuario]
2. [Recomendacao ao usuario]

Pedimos desculpas pelo inconveniente.
Canal de duvidas: seguranca@petmatch.com.br
```

---

## 9. Monitoramento e Alertas

### 9.1 O que Monitorar

| Metrica | Alerta Critico | Ferramenta |
|---------|----------------|------------|
| Taxa de erros 5xx > 5% | > 5% por 5 min | Supabase Dashboard |
| Tentativas de login com falha | > 50/min no mesmo IP | Edge Function logs |
| Queries lentas (> 2s) | > 10/min | PostgreSQL logs |
| Bypass de RLS detectado | Qualquer ocorrencia | Audit logs |
| Acesso a service_role key | Qualquer uso inesperado | Supabase logs |
| Vazamento de dados | Qualquer deteccao | Monitoramento externo |

### 9.2 Firebase Crashlytics

```dart
// lib/core/config/crashlytics_config.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsConfig {
  static void init() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  static void setUser(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
}
```

### 9.3 Sentry (Opcional - Mais Completo)

```dart
// pubspec.yaml
dependencies:
  sentry_flutter: ^8.8.0

// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://YOUR_DSN@sentry.io/PROJECT_ID';
      options.tracesSampleRate = 1.0;
      options.environment = 'production';
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

---

## 10. Checklist de Code Review de Seguranca

### Cada PR deve verificar:

**Credenciais e Segredos**
- [ ] Nenhuma chave hardcoded no codigo
- [ ] `.env` nunca commitado
- [ ] Logs nao contem tokens ou senhas
- [ ] Variaveis de ambiente usadas corretamente

**Input e Output**
- [ ] Todos os inputs validados antes de usar
- [ ] Outputs nao expoem informacao interna
- [ ] Erros retornam mensagens genericas (nao stack traces)
- [ ] SQL usa parameterized queries (nunca string interpolation)

**Autenticacao e Autorizacao**
- [ ] RLS policies testadas para a feature
- [ ] Autenticacao verificada em todas as Edge Functions
- [ ] service_role key so usada quando necessario
- [ ] Usuarios nao acessam dados de outros

**Dados Sensiveis**
- [ ] Dados pessoais criptografados em repouso
- [ ] Comunicacao sempre via HTTPS
- [ ] Fotos redimensionadas antes de upload
- [ ] Localizacao aproximada (nao exata) para outros usuarios

**Logging**
- [ ] Logs nao contem dados pessoais
- [ ] Audit log registrado para acoes criticas
- [ ] Erros logados com contexto (sem dados sensiveis)

---

## 11. Hardening do Supabase

### 11.1 Configuracoes de Seguranca

| Configuracao | Valor Recomendado | Onde |
|--------------|-------------------|------|
| JWT Expiry | 3600s (1 hora) | Auth > Settings |
| Refresh Token Rotation | Habilitado | Auth > Settings |
| Password Min Length | 8 caracteres | Auth > Settings |
| Rate Limiting | 100 req/min | Database > Settings |
| Connection Limit | 50 por funcao | Database > Settings |
| Statement Timeout | 30s | Database > Settings |
| Log Retention | 7 dias | Logs > Settings |

### 11.2 Funcao de Seguranca

```sql
-- Criar funcao para verificar se usuario e admin
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE uid = user_id
    AND is_verified = true
    -- Adicionar campo is_admin quando necessario
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 12. Auditoria de Seguranca

### 12.1 Frequencia

| Atividade | Frequencia |
|-----------|------------|
| Code review de seguranca | Cada PR |
| Dependency audit | Semanal |
| Penetration testing | Trimestral |
| Full security audit | Anual |
| Disaster recovery test | Semestral |

### 12.2 Ferramentas Recomendadas

| Ferramenta | Uso | Custo |
|------------|-----|-------|
| Dependabot | Dependency scanning | Gratuito |
| TruffleHog | Secret scanning | Gratuito |
| Sentry | Error monitoring | Free tier |
| Firebase Crashlytics | Crash reports | Gratuito |
| OWASP ZAP | DAST testing | Gratuito |
| SonarCloud | SAST analysis | Free tier |
