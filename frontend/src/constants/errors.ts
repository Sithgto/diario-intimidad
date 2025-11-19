// Constantes globales para mensajes de error identificados
export const ERROR_MESSAGES = {
  // Errores de autenticación
  AUTH_INVALID_CREDENTIALS: 'Credenciales inválidas. Verifica tu email y contraseña.',
  AUTH_TOKEN_EXPIRED: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
  AUTH_UNAUTHORIZED: 'No tienes permisos para acceder a esta sección.',
  AUTH_FORBIDDEN: 'Acceso denegado. Contacta al administrador.',

  // Errores de red
  NETWORK_ERROR: 'Error de conexión. Verifica tu internet e intenta nuevamente.',
  SERVER_ERROR: 'Error del servidor. Intenta más tarde.',
  TIMEOUT_ERROR: 'La solicitud tardó demasiado. Intenta nuevamente.',

  // Errores de validación
  VALIDATION_REQUIRED: 'Este campo es obligatorio.',
  VALIDATION_EMAIL_INVALID: 'Ingresa un email válido.',
  VALIDATION_PASSWORD_TOO_SHORT: 'La contraseña debe tener al menos 6 caracteres.',
  VALIDATION_PASSWORD_MISMATCH: 'Las contraseñas no coinciden.',

  // Errores de usuario
  USER_NOT_FOUND: 'Usuario no encontrado.',
  USER_ALREADY_EXISTS: 'El email ya está registrado.',
  USER_CREATE_FAILED: 'Error al crear el usuario.',
  USER_UPDATE_FAILED: 'Error al actualizar el usuario.',
  USER_DELETE_FAILED: 'Error al eliminar el usuario.',

  // Errores genéricos
  UNKNOWN_ERROR: 'Ha ocurrido un error inesperado. Intenta nuevamente.',
  OPERATION_FAILED: 'La operación no pudo completarse.',
} as const;

// Función para obtener mensaje de error por código
export const getErrorMessage = (errorCode: keyof typeof ERROR_MESSAGES): string => {
  return ERROR_MESSAGES[errorCode] || ERROR_MESSAGES.UNKNOWN_ERROR;
};

// Tipos para errores
export type ErrorCode = keyof typeof ERROR_MESSAGES;