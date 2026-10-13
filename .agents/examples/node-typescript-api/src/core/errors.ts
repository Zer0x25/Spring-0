/**
 * Ejemplo opcional para proyectos Node.js/TypeScript con API HTTP.
 * No forma parte del núcleo agnóstico de Hito 0.
 * 
 * Garantiza que ningún servicio lance errores genéricos no tipados
 * y que una capa de transporte pueda traducirlos según su propio contrato.
 */
export abstract class DomainError extends Error {
  abstract readonly code: string;
  abstract readonly statusCode: number;
  readonly details?: Record<string, unknown>;

  constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.name = this.constructor.name;
    this.details = details;

    // Mantiene el stack trace en runtimes compatibles con V8.
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

/**
 * Predicado de tipo para validar si un error capturado es un DomainError.
 */
export function isDomainError(error: unknown): error is DomainError {
  return error instanceof DomainError;
}
