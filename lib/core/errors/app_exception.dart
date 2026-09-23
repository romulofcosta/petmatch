class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AppAuthException extends AppException {
  const AppAuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AppAuthException.fromSupabase(dynamic error) {
    final message = error?.message ?? 'Erro de autenticação desconhecido';
    final code = error?.code ?? 'unknown';

    return AppAuthException(
      message: _mapSupabaseMessage(message, code),
      code: code,
      originalError: error,
    );
  }

  static String _mapSupabaseMessage(String message, String code) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha incorretos';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email não confirmado. Verifique sua caixa de entrada';
    }
    if (message.contains('User already registered')) {
      return 'Este email já está cadastrado';
    }
    if (message.contains('Password should be at least')) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    if (code == 'too_many_requests') {
      return 'Muitas tentativas. Aguarde 15 minutos';
    }
    return message;
  }
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Erro de conexão. Verifique sua internet',
    super.code,
    super.originalError,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Erro no servidor. Tente novamente',
    super.code,
    super.originalError,
  });
}
