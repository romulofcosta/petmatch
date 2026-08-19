# 01 - Stack Tecnologica

## Visao Geral

O PetMatch utiliza uma stack moderna e eficiente para desenvolvimento mobile multiplataforma.

---

## 1. Stack Completa

### 1.1 Frontend

| Tecnologia | Versao | Descricao |
|------------|--------|-----------|
| Flutter | 3.x | Framework mobile multiplataforma |
| Dart | 3.x | Linguagem de programacao |
| Riverpod | 2.x | State management |
| GoRouter | 13.x | Navegacao |
| Supabase Flutter | 2.x | Cliente Supabase |
| Firebase Messaging | 14.x | Push notifications |

### 1.2 Backend

| Tecnologia | Versao | Descricao |
|------------|--------|-----------|
| Supabase | - | Backend as a Service |
| PostgreSQL | 15+ | Banco de dados |
| PostGIS | 3.x | Extensao geografica |
| Edge Functions | Deno | Logica de negocio serverless |
| Supabase Auth | - | Autenticacao |
| Supabase Storage | - | Armazenamento de arquivos |
| Supabase Realtime | - | Chat em tempo real |

### 1.3 Infraestrutura

| Tecnologia | Descricao |
|------------|-----------|
| Firebase | Push notifications (FCM) |
| Supabase Cloud | Hosting do backend |
| GitHub | Controle de versao |
| GitHub Actions | CI/CD (futuro) |

---

## 2. Dependencias Principais (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Supabase
  supabase_flutter: ^2.3.0
  supabase: ^2.2.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0

  # Authentication
  google_sign_in: ^6.2.0
  sign_in_with_apple: ^6.1.0

  # Navigation
  go_router: ^13.0.0

  # Location
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0

  # UI
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.0
  shimmer: ^3.0.0
  lottie: ^3.0.0

  # Utils
  intl: ^0.19.0
  uuid: ^4.2.0
  url_launcher: ^6.2.0
  path_provider: ^2.1.0

  # Image
  image_picker: ^1.0.0
  image_cropper: ^5.0.0

  # Permissions
  permission_handler: ^11.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  mockito: ^5.4.0
```

---

## 3. Ferramentas de Desenvolvimento

| Ferramenta | Uso |
|------------|-----|
| VS Code / Android Studio | IDE |
| Flutter SDK | Framework |
| Dart SDK | Linguagem |
| Supabase CLI | Migrations, Edge Functions |
| Firebase CLI | Push notifications |
| Postico / DBeaver | Gerenciamento PostgreSQL |
| Postman / Insomnia | Teste de APIs |
| Git | Controle de versao |

---

## 4. Configuracao de Ambiente

### 4.1 Variaveis de Ambiente (.env)

```env
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJxxx...
SUPABASE_SERVICE_ROLE_KEY=eyJxxx...

# Firebase
FIREBASE_API_KEY=xxx
FIREBASE_AUTH_DOMAIN=xxx.firebaseapp.com
FIREBASE_PROJECT_ID=xxx
FIREBASE_STORAGE_BUCKET=xxx.appspot.com
FIREBASE_MESSAGING_SENDER_ID=xxx
FIREBASE_APP_ID=1:xxx:android:xxx

# FCM
FCM_SERVER_KEY=xxx
```

### 4.2 Supabase CLI

```bash
# Instalar Supabase CLI
brew install supabase/tap/supabase

# Login
supabase login

# Criar projeto
supabase init

# Criar migration
supabase migration new create_users_table

# Aplicar migrations
supabase db push

# Deploy Edge Functions
supabase functions deploy create-profile
```

---

## 5. Padroes de Codigo

### 5.1 Arquitetura

- **Clean Architecture**: Separacao em camadas (data, domain, presentation)
- **Feature-based**: Organizacao por funcionalidade
- **Repository Pattern**: Abstracao de fontes de dados

### 5.2 Naming Conventions

| Elemento | Formato | Exemplo |
|----------|---------|---------|
| Arquivos | snake_case | `user_model.dart` |
| Classes | PascalCase | `UserModel` |
| Variaveis | camelCase | `userName` |
| Constantes | SCREAMING_SNAKE | `API_BASE_URL` |
| Tabelas SQL | snake_case | `users`, `pet_photos` |

### 5.3 Estrutura de uma Feature

```
feature/
├── data/
│   ├── models/
│   │   └── feature_model.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── datasources/
│       └── feature_remote_datasource.dart
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   ├── repositories/
│   │   └── feature_repository_interface.dart
│   └── usecases/
│       └── get_feature_usecase.dart
└── presentation/
    ├── providers/
    │   └── feature_provider.dart
    ├── pages/
    │   └── feature_page.dart
    └── widgets/
        └── feature_widget.dart
```
