# 05 - CI/CD e Deploy

## Visao Geral

Pipeline automatizada para testes, builds e distribuicao do PetMatch.

```
Push/PR → CI (lint + test) → Build → Distribute → Store
```

---

## 1. GitHub Actions

### 1.1 CI Workflow (Testes)

`.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze --no-fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $3}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi
```

### 1.2 Build Android

`.github/workflows/build-android.yml`

```yaml
name: Build Android

on:
  push:
    tags: ["v*"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: "zulu"
          java-version: "17"

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"

      - name: Decode keystore
        run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/release.keystore

      - name: Build AAB
        run: |
          flutter build apprelease \
            --release \
            --obfuscate \
            --split-debug-info=build/debug-info

      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: app-release.aab
          path: build/app/outputs/bundle/release/app-release.aab

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: com.petmatch.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

### 1.3 Build iOS

`.github/workflows/build-ios.yml`

```yaml
name: Build iOS

on:
  push:
    tags: ["v*"]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"

      - name: Install CocoaPods
        run: cd ios && pod install

      - name: Build IPA
        run: |
          flutter build ipa \
            --release \
            --obfuscate \
            --split-debug-info=build/debug-info \
            --export-options-plist=ios/ExportOptions.plist

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: app-release.ipa
          path: build/ios/ipa/*.ipa
```

---

## 2. Firebase App Distribution

### 2.1 Setup
1. No Firebase Console, va em **App Distribution**
2. Adicione o app (Android + iOS)
3. Baixe `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
4. Crie um grupo de teste (ex: "petmatch-testers")

### 2.2 GitHub Action para Beta

`.github/workflows/beta.yml`

```yaml
name: Beta Distribution

on:
  push:
    branches: [develop]

jobs:
  beta-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - name: Build APK
        run: flutter build apk --debug
      - uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: petmatch-testers
          file: build/app/outputs/flutter-apk/app-debug.apk

  beta-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: cd ios && pod install
      - name: Build IPA
        run: flutter build ipa --debug --no-codesign
      - uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_IOS_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: petmatch-testers
          file: build/ios/ipa/*.ipa
```

---

## 3. Build Local

### 3.1 Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (para teste)
flutter build apk --release

# Release AAB (para Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### 3.2 iOS

```bash
# Resolver pods
cd ios && pod install && cd ..

# Build IPA
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```

---

## 4. Versionamento

Utilize **SemVer** no `pubspec.yaml`:

```yaml
version: 1.2.3+45
#       |  |  |  |
#       |  |  |  └─ Build number (incremento automatico)
#       |  |  └─ Patch (bugfix)
#       |  └─ Minor (novas features)
#       └─ Major (breaking changes)
```

| Mudanca | Exemplo | Quando |
|---------|---------|--------|
| Bugfix | 1.0.0 → 1.0.1 | Correcao de bug |
| Feature | 1.0.1 → 1.1.0 | Nova funcionalidade |
| Breaking | 1.1.0 → 2.0.0 | Mudanca incompativel |

---

## 5. Segredos no GitHub

Configure em **Settings > Secrets and variables > Actions**:

| Secret | Descricao |
|--------|-----------|
| `SUPABASE_URL` | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Chave anon do Supabase |
| `ANDROID_KEYSTORE_BASE64` | Keystore codificado em base64 |
| `ANDROID_KEY_PASSWORD` | Senha do keystore |
| `PLAY_SERVICE_ACCOUNT` | JSON da service account Google Play |
| `FIREBASE_ANDROID_APP_ID` | App ID Firebase (Android) |
| `FIREBASE_IOS_APP_ID` | App ID Firebase (iOS) |
| `FIREBASE_SERVICE_ACCOUNT` | JSON da service account Firebase |
| `APPLE_TEAM_ID` | Team ID Apple Developer |
| `APPLE_CERTIFICATE_BASE64` | Certificado iOS |
| `APPLE_PROVISION_PROFILE_BASE64` | Provisioning profile |

---

## 6. Checklist Pre-Deploy

### Android
- [ ] Versao atualizada no pubspec.yaml
- [ ] Keystore configurado e seguro
- [ ] google-services.json atualizado
- [ ] Proguard rules configurados
- [ ] Permissoes no AndroidManifest.xml
- [ ] Testado em dispositivo real
- [ ] Screenshots atualizadas
- [ ] Descricao da release pronta

### iOS
- [ ] Versao atualizada no pubspec.yaml
- [ ] Certificados Apple validos
- [ ] Provisioning profile configurado
- [ ] GoogleService-Info.plist atualizado
- [ ] Permissoes no Info.plist
- [ ] Testado em dispositivo real
- [ ] Screenshots para todas as device classes
- [ ] App Store Connect com metadata

---

## 7. Ambientes

| Ambiente | Supabase | Firebase | Uso |
|----------|----------|----------|-----|
| Development | Projeto dev | Projeto dev | Desenvolvimento local |
| Staging | Projeto staging | Projeto staging | QA e testes |
| Production | Projeto prod | Projeto prod | Usuarios reais |

Variavel de ambiente controla qual configuracao usar:

```dart
// lib/core/config/app_config.dart
enum Environment { dev, staging, production }

class AppConfig {
  static late Environment _environment;
  
  static void init(Environment env) {
    _environment = env;
  }
  
  static String get supabaseUrl {
    switch (_environment) {
      case Environment.dev:
        return const String.fromEnvironment('SUPABASE_URL_DEV');
      case Environment.staging:
        return const String.fromEnvironment('SUPABASE_URL_STAGING');
      case Environment.production:
        return const String.fromEnvironment('SUPABASE_URL_PROD');
    }
  }
}
```

---

## 8. Fastlane (Opcional)

### 8.1 Instalacao

```bash
# macOS
brew install fastlane

# Inicializar
cd android && fastlane init && cd ..
cd ios && fastlane init && cd ..
```

### 8.2 Android Fastfile

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  lane :beta do
    gradle(task: "clean assembleDebug")
    firebase_distribution(
      release_notes: "Bug fixes and improvements",
      groups: "petmatch-testers",
      apk: "app/build/outputs/apk/debug/app-debug.apk"
    )
  end

  lane :deploy do
    gradle(task: "clean bundleRelease")
    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/release/app-release.aab"
    )
  end
end
```

### 8.3 iOS Fastfile

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  lane :beta do
    build_app(scheme: "Runner")
    upload_to_testflight
  end

  lane :deploy do
    build_app(scheme: "Runner")
    upload_to_app_store
  end
end
```

---

## 9. Monitoramento Pos-Deploy

| Ferramenta | Uso |
|------------|-----|
| Firebase Crashlytics | Crash reports automaticos |
| Firebase Analytics | Metricas de uso |
| Sentry | Erros em tempo real (alternativa) |
| Play Console | Metricas Android |
| App Store Connect | Metricas iOS |

---

## 10. Comandos Uteis

```bash
# Analise de codigo
flutter analyze

# Testes
flutter test
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Build limpo
flutter clean && flutter pub get

# Gerar codigo (Riverpod, JSON)
dart run build_runner build --delete-conflicting-outputs

# Gerar em watch mode
dart run build_runner watch --delete-conflicting-outputs
```
