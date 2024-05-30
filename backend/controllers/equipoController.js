const connectionPostgres = require("../database/db");

module.exports = {
  /*
   * Obtener todos los equipos de un club
   ? @param id_grupo - id del grupo
 */
  async getEquiposClub(id_club) {
    try {
      let query = `SELECT * FROM public."Equipo" WHERE id_club = $1`;
      const response = await connectionPostgres.query(query, [id_club]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async getEquiposByUser(id_usuario, id_club) {
    try {
      let query = `SELECT * FROM public."Equipo" WHERE id IN (SELECT id_equipo FROM public."Miembros" WHERE id_usuario = $1) AND id_club = $2`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
      ]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  /*
    * Obtener un equipo por su id
    ? @param id_equipo - id del equipo
  */
  async getEquipobyId(id_equipo) {
    try {
      let query = `SELECT * FROM public."Equipo" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id_equipo]);
      return { statusCode: 200, data: response.rows[0], message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async createEquipo(nombre, id_club) {
    try {
      let query = `INSERT INTO public."Equipo"(nombre, id_club) VALUES ($1 , $2)`;
      const response = await connectionPostgres.query(query, [nombre, id_club]);
      console.log(response);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "Error al crear equipo" };
      }
      return { statusCode: 201, message: "Equipo creado correctamente" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
