const connectionPostgres = require("../database/db");

module.exports = {
  /*
   * Obtener todas las categorias
   */
  async getCategoria() {
    try {
      let query = `SELECT * FROM public."Categoria"`;
      const response = await connectionPostgres.query(query);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
