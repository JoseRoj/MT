const connectionPostgres = require("../database/db");

module.exports = {
  /*
   * Obtener todos los deportes
   */
  async getDeportes() {
    try {
      let query = `SELECT * FROM public."Deporte"`;
      const response = await connectionPostgres.query(query);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
