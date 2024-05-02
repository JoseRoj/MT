const connectionPostgres = require("../database/db");
module.exports = {
  async getClubs() {
    try {
      let query = `SELECT * FROM public."Club"`;
      const response = await connectionPostgres.query(query);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async getClub(id) {
    try {
      let query = `SELECT * FROM public."Club" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id]);
      console.log("Response: ", response);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async createClub(nombre, descripcion, latitud, longitud, id_deporte) {
    try {
      console.log("Nombre: ", nombre);
      //* Primero se debe comprobar que el club no exista;
      let query = `SELECT COUNT(*) AS cantidad_clubes
      FROM public."Club"
      WHERE nombre = $1`;
      let response = await connectionPostgres.query(query, [nombre]);
      if (response.rowCount[0] > 0) {
        return { statusCode: 400, message: "Nombre existente" };
      }
      //* Query para insertar el club
      query = `INSERT INTO public."Club" (nombre, latitud, longitud, descripcion, id_deporte) VALUES ($1, $2, $3, $4, $5)`;
      response = await connectionPostgres.query(query, [
        nombre,
        latitud,
        longitud,
        descripcion,
        id_deporte,
      ]);
      return { statusCode: 200, message: "Club creado con éxito" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
