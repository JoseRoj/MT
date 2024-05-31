const connectionPostgres = require("../database/db");
module.exports = {
  /*
   * Obtener todos los clubes
   */
  async getClubs(deportes) {
    console.log("Deportes: ", deportes);
    const placeholders = deportes.map((_, index) => `$${index + 1}`).join(", ");
    console.log("Placeholders: ", placeholders);

    try {
      if (deportes.length === 0) {
        return {
          statusCode: 200,
          data: [],
          message: "No se han seleccionado deportes",
        };
      }
      let query = `SELECT * FROM public."Club" WHERE id_deporte IN (${placeholders})`;
      const response = await connectionPostgres.query(query, deportes);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
  /*
    * Obtener un club por su id
    ? @param id - id del club
  */
  async getClub(id) {
    try {
      const result = {
        club: null,
        categorias: [],
        tipo: [],
      };
      //* Get Club
      let query = `SELECT "Club".*, "Deporte".nombre AS deporte
      FROM public."Club"
      JOIN public."Deporte" ON "Club".id_deporte = "Deporte".id
      WHERE "Club".id = $1;`;
      const response = await connectionPostgres.query(query, [id]);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "Club no encontrado" };
      }
      //* Get Categorias
      let query2 = `SELECT "Categoria".nombre AS categoria
      FROM public."ClubCategoria"
      JOIN public."Categoria" ON "ClubCategoria".id_categoria = "Categoria".id
      WHERE "ClubCategoria".id_club = $1;`;

      const response2 = await connectionPostgres.query(query2, [id]);
      response2.rows.forEach((row) => {
        result.categorias.push(row.categoria);
      });

      //* Get Tipos
      let query3 = `SELECT "Tipo".nombre AS tipo
      FROM public."ClubTipo"
      JOIN public."Tipo" ON "ClubTipo".id_tipo = "Tipo".id
      WHERE "ClubTipo".id_club = $1;`;
      const response3 = await connectionPostgres.query(query3, [id]);
      response3.rows.forEach((row) => {
        result.tipo.push(row.tipo);
      });
      result.club = response.rows[0];

      return { statusCode: 200, data: result, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
  /*
    * Crear un club
    ? @param nombre - nombre del club
    ? @param descripcion - descripción del club
    ? @param latitud - latitud del club
    ? @param longitud - longitud del club
    ? @param id_deporte - id del deporte del club
    ? @param logo - logo del club
    ? @param correo - correo del club
    ? @param telefono - telefono del club
    ? @param categorias - categorias del club
    ? @param tipos - tipos del club
    ? @param id_usuario - id del usuario que crea el club
  */
  async createClub(
    id,
    nombre,
    descripcion,
    latitud,
    longitud,
    id_deporte,
    logo,
    correo,
    telefono,
    categorias,
    tipos,
    id_usuario
  ) {
    try {
      let query = `SELECT COUNT(*) 
      FROM public."Club"
      WHERE nombre = $1 OR correo = $2`;
      //await connectionPostgres.query("BEGIN"); // Inicia la transacción
      console.log("Nombre: ", id_usuario, correo);
      //* Primero se debe comprobar que el club no exista;

      let response = await connectionPostgres.query(query, [nombre, correo]);

      if (response.rows[0].count > 0) {
        return { statusCode: 400, message: "Nombre existente" };
      }
      if (id) {
        query = `INSERT INTO public."Club" (id, nombre, latitud, longitud, descripcion, id_deporte, logo, correo, telefono) VALUES ($9,$1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`;
        response = await connectionPostgres.query(query, [
          nombre,
          latitud,
          longitud,
          descripcion,
          id_deporte,
          logo,
          correo,
          telefono,
          id,
        ]);
      } else {
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
      }

      const id_club = response.rows[0].id;
      console.log("Id_club: ", id_club);
      /* Comprobar que el correo o nombre del club no exista */

      query =
        'INSERT INTO public."ClubCategoria" (id_club, id_categoria) VALUES ';
      query += categorias
        .map((categoria) => `(${id_club}, ${categoria})`)
        .join(", ");

      response = await connectionPostgres.query(query);

      query = 'INSERT INTO public."ClubTipo" (id_club,id_tipo) VALUES ';
      query += tipos.map((tipo) => `(${id_club}, ${tipo})`).join(", ");
      response = await connectionPostgres.query(query);

      //* Asociar al creador del club como administrador del club
      query = `INSERT INTO public."Administra" (id_club, id_usuario) VALUES ($1, $2)`;
      await connectionPostgres.query(query, [id_club, id_usuario]);

      //await connectionPostgres.query("COMMIT"); // Confirma la transacción
      return { statusCode: 200, message: "Club creado con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      //await connectionPostgres.query("ROLLBACK");
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async getMiembros(id_club) {
    /* Obtener todos los equipos de un club */
    try {
      let query = `SELECT * FROM public."Equipo"
      WHERE id_club = $1`;
      const equipos = await connectionPostgres.query(query, [id_club]);
      console.log("response: ", equipos.rows);
      // Obtener todos los miembros de un club
      const queryadministrador = ` SELECT "Usuarios".*
      FROM public."Usuarios"
      JOIN public."Administra" ON "Usuarios".id = "Administra".id_usuario
      WHERE "Administra".id_club = $1`;
      const administrador = await connectionPostgres.query(queryadministrador, [
        id_club,
      ]);
      const miembros = equipos.rows.map(async (equipo) => {
        query = `SELECT "Usuarios".*
        FROM public."Usuarios" 
        JOIN public."Miembros" ON "Usuarios".id = "Miembros".id_usuario
        WHERE "Miembros".id_equipo = $1`;
        const response = await connectionPostgres.query(query, [equipo.id]);
        return response.rows;
        //return response.rows;
        /* Obtener el rol que tiene en este equipo */
      });
      const resultados = await Promise.all(miembros);
      resultados.push(administrador.rows);
      console.log("resultados: ", resultados);

      const uniqueUsuarios = [];
      const ids = new Set();

      resultados.forEach((subArray) => {
        subArray.forEach((usuario) => {
          if (!ids.has(usuario.id)) {
            ids.add(usuario.id);
            uniqueUsuarios.push(usuario);
          }
        });
      });

      //resultados.push(administrador.rows);
      //const uniqueUser = new Map(resultados.map((user) => [user.id, user]));
      //console.log("uniqueUser: ", uniqueUser);
      //const arrayUniqueUser = Array.from(uniqueUser.values());

      return { statusCode: 200, data: uniqueUsuarios, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
