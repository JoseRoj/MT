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
      const result = {
        club: null,
        categorias: [],
      };
      // Get Club
      let query = `SELECT "Club".*, "Deporte".nombre AS deporte
      FROM public."Club"
      JOIN public."Deporte" ON "Club".id_deporte = "Deporte".id
      WHERE "Club".id = $1;`;
      const response = await connectionPostgres.query(query, [id]);

      // Get Categorias
      let query2 = `SELECT "Categoria".nombre AS categoria
      FROM public."ClubCategoria"
      JOIN public."Categoria" ON "ClubCategoria".id_categoria = "Categoria".id
      WHERE "ClubCategoria".id_club = $1;`;
      const response2 = await connectionPostgres.query(query2, [id]);
      response2.rows.forEach((row) => {
        result.categorias.push(row.categoria);
      });
      result.club = response.rows[0];
      return { statusCode: 200, data: result, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async createClub(
    nombre,
    descripcion,
    latitud,
    longitud,
    id_deporte,
    logo,
    correo,
    telefono,
    categorias
  ) {
    try {
      let query = `SELECT COUNT(*) AS cantidad_clubes
      FROM public."Club"
      WHERE nombre = $1`;
      //await connectionPostgres.query("BEGIN"); // Inicia la transacción
      console.log("Nombre: ");
      //* Primero se debe comprobar que el club no exista;

      let response = await connectionPostgres.query(query, [nombre]);
      if (response.rowCount[0] > 0) {
        return { statusCode: 400, message: "Nombre existente" };
      }
      //* Query para insertar el club
      query = `INSERT INTO public."Club" (nombre, latitud, longitud, descripcion, id_deporte, logo, correo, telefono) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`;
      response = await connectionPostgres.query(query, [
        nombre,
        latitud,
        longitud,
        descripcion,
        id_deporte,
        logo,
        correo,
        telefono,
      ]);
      const id_club = response.rows[0].id;
      console.log("Id_club: ", id_club);
      query =
        'INSERT INTO public."ClubCategoria" (id_club, id_categoria) VALUES ';
      query += categorias
        .map((categoria) => `(${id_club}, ${categoria})`)
        .join(", ");

      response = await connectionPostgres.query(query);
      //await connectionPostgres.query("COMMIT"); // Confirma la transacción
      return { statusCode: 200, message: "Club creado con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      //await connectionPostgres.query("ROLLBACK");
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
