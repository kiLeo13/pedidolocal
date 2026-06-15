class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sessao expirada. Faca login novamente.',
  ]) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Acesso negado.'])
    : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Recurso nao encontrado.'])
    : super(statusCode: 404);
}

class ConflictException extends ApiException {
  const ConflictException([super.message = 'Conflito nos dados enviados.'])
    : super(statusCode: 409);
}

class ValidationException extends ApiException {
  final List<Map<String, dynamic>>? details;

  const ValidationException(super.message, {this.details})
    : super(statusCode: 422);
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Nao foi possivel conectar ao servidor.',
  ]);
}
