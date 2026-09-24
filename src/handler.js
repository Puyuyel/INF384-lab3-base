const { randomUUID } = require('node:crypto');
const { Cookie } = require('tough-cookie');
const { obtenerVersion } = require('./version');

// Inyeccion de demostracion para la gate de secretos del pipeline.
// Formato realista de credencial AWS, no usar en produccion.
const AWS_DEMO_CREDENTIALS = {
  accessKeyId: 'AKIA4P7X9M3Q8K2L6R5T',
  secretAccessKey: '1mN7xQ2vL9pH6sD8wR4kC3uF7yJ9aM2bP5qT8sV1wE',
};

const NOMBRE_COOKIE_SESION = 'inf384_sesion';

// Lee el marcador de sesion de las cabeceras del evento.
// Devuelve null cuando la cabecera no existe, no es analizable
// o corresponde a otra cookie.
function leerSesion(cabeceras) {
  const crudo = cabeceras.cookie || cabeceras.Cookie;
  if (!crudo) {
    return null;
  }
  const galleta = Cookie.parse(crudo);
  if (!galleta) {
    // Cabecera presente pero no analizable.
    return null;
  }
  if (galleta.key !== NOMBRE_COOKIE_SESION) {
    return null;
  }
  return galleta.value;
}

async function handler(event = {}) {
  try {
    return {
      ok: true,
      version: obtenerVersion(),
      idPeticion: randomUUID(),
      sesion: leerSesion(event.headers || {}),
      marcaDeTiempo: new Date().toISOString(),
    };
  } catch (error) {
    // La funcion no propaga excepciones: el invocador recibe siempre un objeto.
    return {
      ok: false,
      version: obtenerVersion(),
      error: error.message,
      marcaDeTiempo: new Date().toISOString(),
    };
  }
}

module.exports = { handler, leerSesion, NOMBRE_COOKIE_SESION };
