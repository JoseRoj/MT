const connectionPostgres = require("../database/db");

module.exports = {
  /*
   * Obtener todas las categorias
   */
  async confirmAsistencia(id_usuario, id_evento) {
    try {
      let query = `INSERT INTO public."Asistencia" (id_usuario, id_evento) VALUES ($1, $2)`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_evento,
      ]);
      return { statusCode: 201, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async deleteAsistencia(id_usuario, id_evento) {
    try {
      let query = `DELETE FROM public."Asistencia" WHERE id_usuario = $1 AND id_evento = $2`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_evento,
      ]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};