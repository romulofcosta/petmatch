# 03 - Plano de Testes

## Visao Geral

Estrategia de testes completa para garantir qualidade, seguranca e compliance do PetMatch.

---

## 1. Piramide de Testes

```
        /  E2E  \           ~5% (Fluxos criticos)
       / Integracao \       ~15% (Servicos + DB)
      /   Unitarios   \     ~80% (Regras de negocio)
     ───────────────────
```

| Nivel | Quantidade | Ferramenta |
|-------|------------|------------|
| Unit | ~80% | flutter_test |
| Widget | ~10% | flutter_test |
| Integration | ~5% | integration_test |
| E2E | ~5% | integration_test + mocks |

---

## 2. Testes Unitarios

### 2.1 Models

| Teste | Descricao |
|-------|-----------|
| UserModel.fromJson | Parsing correto de JSON |
| UserModel.toJson | Serializacao correta |
| UserModel.validations | Validacao de campos obrigatorios |
| PetModel.ageMonths | Calculo correto de idade |
| PetModel.interests | Validacao de interesses |

### 2.2 Validators

| Teste | Descricao |
|-------|-----------|
| validateUserAge >= 18 | Recusa menores |
| validatePetAge >= 4 meses | Recusa pets novos |
| validateEmail | Formato valido |
| validatePassword | Forca minima |
| validateGeoPoint | Limites geograficos |

### 2.3 Repositories

| Teste | Descricao |
|-------|-----------|
| AuthRepository.signIn | Login com credenciais validas |
| AuthRepository.signIn | Erro com credenciais invalidas |
| AuthRepository.signUp | Cadastro com dados validos |
| PetsRepository.createPet | Criacao com validacao |
| PetsRepository.getNearby | Query PostGIS com filtros |
| SwipeRepository.processSwipe | Like, superlike, pass |
| SwipeRepository.checkLimits | Limite diario free |
| SwipeRepository.checkMatch | Match reciproco |
| MessageRepository.sendMessage | Envio com validacao |
| MessageRepository.checkLimits | Limite diario free |

### 2.4 UseCases

| Teste | Descricao |
|-------|-----------|
| ProcessSwipeUseCase | Fluxo completo de swipe |
| ProcessSwipeUseCase | Match reciproco |
| ProcessSwipeUseCase | Limite atingido |
| SendMessageUseCase | Envio normal |
| SendMessageUseCase | Conteudo inadequado |
| SendMessageUseCase | Limite atingido |
| NearbyPetsUseCase | Filtros aplicados |
| NearbyPetsUseCase | Exclusao de visualizados |

---

## 3. Testes de Widget

| Teste | Descricao |
|-------|-----------|
| LoginPage.render | Elementos visuais presentes |
| LoginPage.validation | Mensagens de erro exibidas |
| PetCard.display | Dados do pet exibidos |
| PetCard.actions | Botoes like/pass/superlike |
| ChatPage.messages | Lista de mensagens renderizada |
| MatchPage.display | Match exibido corretamente |
| ProfilePage.data | Dados do usuario exibidos |

---

## 4. Testes de Integracao

| Teste | Descricao |
|-------|-----------|
| Cadastro completo | Signup → Profile → Pet |
| Fluxo de match | Swipe → Match → Conversa |
| Fluxo de chat | Mensagem enviada → Recebida |
| Filtros de busca | Tipo, raca, distancia |
| Edge Function | Create-profile com validacoes |
| Edge Function | Process-swipe com match |
| Edge Function | Send-message com moderacao |
| RLS | Usuario so ve seus dados |

---

## 5. Testes de Edge Functions

### 5.1 Testes por Funcao

| Funcao | Teste |
|--------|-------|
| create-profile | Cria perfil com dados validos |
| create-profile | Rejeita idade < 18 |
| create-profile | Rejeita localizacao invalida |
| create-profile | Impede duplicidade |
| process-swipe | Registra like |
| process-swipe | Registra super like |
| process-swipe | Cria match reciproco |
| process-swipe | Bloqueia limite diario |
| process-swipe | Bloqueia swipe no proprio pet |
| send-message | Envia texto |
| send-message | Bloqueia conteudo inadequado |
| send-message | Bloqueia limite diario |
| send-message | Bloqueia nao-participante |
| nearby-pets | Retorna pets proximos |
| nearby-pets | Aplica filtros |
| nearby-pets | Exclui visualizados |

---

## 6. Testes de Seguranca

### 6.1 RLS Policies

| Teste | Descricao |
|-------|-----------|
| User A nao ve User B | SELECT bloqueado |
| User A nao edita User B | UPDATE bloqueado |
| User A ve seus pets | SELECT permitido |
| User A nao ve swipes de B | SELECT bloqueado |
| User A ve seus matches | SELECT permitido |
| Mensagens isoladas | User A so ve msgs de suas conversas |
| service_role bypass | Edge Functions acessam tudo |

### 6.2 Autenticacao

| Teste | Descricao |
|-------|-----------|
| Token invalido | Rejeitado |
| Token expirado | Rejeitado |
| Token ausente | Rejeitado |
| Supabase anon key | So ve dados publicos |

### 6.3 LGPD

| Teste | Descricao |
|-------|-----------|
| Consentimento registrado | consent_logs criado |
| Audit log completo | Todas as acoes registradas |
| Exportacao de dados | Dados completos retornados |
| Delecao de conta | Soft delete + agendamento |
| Retencao de dados | Logs expiram apos 5 anos |

---

## 7. Testes de Performance

| Teste | Meta |
|-------|------|
| Tempo de resposta API | < 200ms |
| Tempo de busca nearby | < 500ms |
| Tempo de carregamento feed | < 1s |
| Tempo de envio de mensagem | < 300ms |
| Uso de memoria | < 200MB |
| Tamanho do APK | < 30MB |

---

## 8. Testes de Compliance Animal

| Teste | Descricao |
|-------|-----------|
| Idade minima pet | 120 dias (4 meses) |
| Publicidade obrigatoria | Mensagem: "Adote, nao compre" |
| Lista de racas | Conforme tabela CNPF |
| Filtros de busca | Funcionam corretamente |

---

## 9. Codigo de Testes

### 9.1 Exemplo: Unit Test

```dart
// test/features/auth/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/core/utils/validators.dart';

void main() {
  group('validateUserAge', () {
    test('deve retornar erro para idade menor que 18', () {
      final result = Validators.validateUserAge('2010-01-01');
      expect(result.isValid, false);
      expect(result.error, contains('18 anos'));
    });

    test('deve aceitar idade 18 ou mais', () {
      final result = Validators.validateUserAge('2000-01-01');
      expect(result.isValid, true);
    });
  });

  group('validatePetAge', () {
    test('deve retornar erro para pet com menos de 4 meses', () {
      final result = Validators.validatePetAge(
        DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
      );
      expect(result.isValid, false);
    });

    test('deve aceitar pet com 4 meses ou mais', () {
      final result = Validators.validatePetAge(
        DateTime.now().subtract(Duration(days: 150)).toIso8601String(),
      );
      expect(result.isValid, true);
    });
  });
}
```

### 9.2 Exemplo: Widget Test

```dart
// test/features/auth/presentation/pages/login_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage deve renderizar campos de login', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    expect(find.byType(TextField), findsNWidgets(2)); // email + senha
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('LoginPage deve mostrar erro para email invalido', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextField).first, 'email_invalido');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Email invalido'), findsOneWidget);
  });
}
```

### 9.3 Exemplo: Integration Test

```dart
// integration_test/auth_flow_test.dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:petmatch/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo completo de cadastro', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Tap em "Criar conta"
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    // Preencher formulario
    await tester.enterText(find.byKey(Key('name_field')), 'Joao Silva');
    await tester.enterText(find.byKey(Key('email_field')), 'joao@teste.com');
    await tester.enterText(find.byKey(Key('password_field')), 'SenhaForte123!');
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    // Verificar navegacao para completar perfil
    expect(find.text('Complete seu perfil'), findsOneWidget);
  });
}
```

---

## 10. Execucao

```bash
# Todos os testes
flutter test

# Apenas unitarios
flutter test test/unit/

# Apenas widgets
flutter test test/widget/

# Integracao (emulador necessario)
flutter test integration_test/

# Com cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 11. Cobertura Minima

| Modulo | Cobertura Minima |
|--------|------------------|
| core/ | 90% |
| features/auth/ | 85% |
| features/pets/ | 85% |
| features/feed/ | 80% |
| features/matching/ | 85% |
| features/chat/ | 80% |
| shared/ | 90% |
| **Geral** | **80%** |
