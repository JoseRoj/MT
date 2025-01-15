const { Query } = require("pg");
const connectionPostgres = require("../database/db");
const { deleteSolicitud } = require("./solicitudController");
module.exports = {
  /*
   * Obtener todos los clubes
   */
  async getClubs(deportes, northeastLat, northeastLng, southwestLat, southwestLng) {
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
      let query = `SELECT * FROM public."Club" WHERE id_deporte IN (${placeholders})
              AND latitud <= $${deportes.length + 1} 
              AND latitud >= $${deportes.length + 2} 
              AND longitud <= $${deportes.length + 3} 
              AND longitud >= $${deportes.length + 4}`;
      console.log("Query: ", query);
      const response = await connectionPostgres.query(query, [...deportes, northeastLat, southwestLat, northeastLng, southwestLng]);
      console.log("Response: ", response.rows);
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
        eventos: [],
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

      //*Get EventosPublicos
      const queryEventosPublicos = ` SELECT "EventosPublicos".*
      FROM "EventosPublicos"
      WHERE "EventosPublicos".club_id = $1;`;
      const responseEventosPublicos = await connectionPostgres.query(queryEventosPublicos, [id]);
      responseEventosPublicos.rows.forEach((row) => {
        result.eventos.push(row);
      });
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
  async createClub(nombre, descripcion, latitud, longitud, id_deporte, logo, correo, telefono, categorias, tipos, id_usuario, facebook, instagram, tiktok) {
    try {
      /* Comprobar que el correo o nombre del club no exista */
      let query = `SELECT COUNT(*) 
      FROM public."Club"
      WHERE nombre = $1 OR correo = $2`;
      await connectionPostgres.query("BEGIN"); // Inicia la transacción

      let response = await connectionPostgres.query(query, [nombre, correo]);
      if (response.rows[0].count > 0) {
        return { statusCode: 400, message: "El nombre o correo ya se encuentra asociado a otro Club" };
      }

      let responseInsert;
      query = `INSERT INTO public."Club" (nombre, latitud, longitud, descripcion, id_deporte, logo, correo, telefono, facebook, instagram, tiktok) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id`;
      responseInsert = await connectionPostgres.query(query, [nombre, latitud, longitud, descripcion, id_deporte, logo, correo, telefono, facebook, instagram, tiktok]);

      const id_club = responseInsert.rows[0].id;
      query = 'INSERT INTO public."ClubCategoria" (id_club, id_categoria) VALUES ';
      query += categorias.map((categoria) => `(${id_club}, ${categoria})`).join(", ");
      response = await connectionPostgres.query(query);

      query = 'INSERT INTO public."ClubTipo" (id_club,id_tipo) VALUES ';
      query += tipos.map((tipo) => `(${id_club}, ${tipo})`).join(", ");
      response = await connectionPostgres.query(query);

      // Asociar al creador del Club como administrador del club
      query = `INSERT INTO public."Administra" (id_club, id_usuario) VALUES ($1, $2)`;
      await connectionPostgres.query(query, [id_club, id_usuario]);
      await connectionPostgres.query("COMMIT"); // Confirma la transacción
      return { statusCode: 200, data: id_club, message: "Club creado con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      await connectionPostgres.query("ROLLBACK");
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
      const administrador = await connectionPostgres.query(queryadministrador, [id_club]);
      const miembros = equipos.rows.map(async (equipo) => {
        query = `SELECT "Usuarios".*, "Miembros".rol, "Equipo".nombre AS equipo, "Equipo".id AS idequipo
        FROM public."Usuarios" 
        JOIN public."Miembros" ON "Usuarios".id = "Miembros".id_usuario
        JOIN public."Equipo" ON "Miembros".id_equipo = "Equipo".id
        WHERE "Miembros".id_equipo = $1`;
        const response = await connectionPostgres.query(query, [equipo.id]);
        return response.rows;
        //return response.rows;
        /* Obtener el rol que tiene en este equipo */
      });
      const resultados = await Promise.all(miembros);
      resultados.push(administrador.rows);

      console.log("resultados: ", resultados);

      //* Obtener todos los equipos de un usuario //*

      const uniqueUsuarios = [];
      const ids = new Set();

      resultados.forEach((subArray) => {
        subArray.forEach((usuario) => {
          if (!ids.has(usuario.id)) {
            ids.add(usuario.id);
            if (usuario.equipo != null && usuario.rol != null) {
              uniqueUsuarios.push({
                id: usuario.id,
                nombre: usuario.nombre,
                email: usuario.email,
                apellido1: usuario.apellido1,
                apellido2: usuario.apellido2,
                genero: usuario.genero,
                imagen: usuario.imagen,
                fecha_nacimiento: usuario.fecha_nacimiento,
                telefono: usuario.telefono,
                equipos: [
                  {
                    nombre: usuario.equipo ?? "",
                    id: usuario.idequipo ?? "",
                    rol: usuario.rol ?? "",
                  },
                ],
              });
            } else {
              uniqueUsuarios.push({
                id: usuario.id,
                nombre: usuario.nombre,
                email: usuario.email,
                apellido1: usuario.apellido1,
                apellido2: usuario.apellido2,
                genero: usuario.genero,
                imagen: usuario.imagen,
                fecha_nacimiento: usuario.fecha_nacimiento,
                telefono: usuario.telefono,
                equipos: [],
              });
            }
          } else {
            console.log("Usss");
            const index = uniqueUsuarios.findIndex((user) => user.id === usuario.id);
            if (!uniqueUsuarios[index].equipos) {
              uniqueUsuarios[index].equipos = [];
            }
            if (usuario.equipo !== null && usuario.equipo != "" && usuario.rol !== null && usuario.rol != "") {
              uniqueUsuarios[index].equipos.push({
                nombre: usuario.equipo ?? "",
                id: usuario.idequipo ?? "",
                rol: usuario.rol ?? "",
              });
            }
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

  // TODO : TEASTEAR
  async expulsarMiembros(id_club, id_usuario) {
    const client = await connectionPostgres.connect(); // Obtener una conexión única

    try {
      // COomprobar que el id del usuario sea de un administrador
      const queryIsAdmin = `SELECT COUNT(*) FROM public."Administra" WHERE "Administra".id_club = $1 AND "Administra".id_usuario = $2`;
      let responseIsAdmin = await client.query(queryIsAdmin, [id_club, id_usuario]);
      if (responseIsAdmin.rows[0].count == 1) {
        //* Comprobar que la cantidad de administradores sea mayor a 1
        const queryAdmin = `SELECT COUNT(*) FROM public."Administra" WHERE id_club = $1`;
        let responseAdmin = await client.query(queryAdmin, [id_club]);
        if (responseAdmin.rows[0].count <= 1) {
          return { statusCode: 400, message: "Solo existe un administrador, no es posible realizar la petición" };
        }
      }

      await client.query("BEGIN"); // Inicia la transacción
      //* obtener todos los equipos de un club //*
      const queryEquipos = `SELECT * FROM public."Equipo" WHERE id_club = $1`;
      const equipos = await client.query(queryEquipos, [id_club]);

      //* Eliminar al usuario de todos los equipos del club //*
      const queryDeleteMiembro = `DELETE FROM public."Miembros" WHERE id_usuario = $1 AND id_equipo = $2`;
      const promises = equipos.rows.map((equipo) => client.query(queryDeleteMiembro, [id_usuario, equipo.id]));
      await Promise.all(promises);

      //* Eliminar la solicitud del usuario //*
      const queryDeleteSolicitud = `DELETE FROM public."Solicitud" WHERE id_usuario = $1 AND id_club = $2`;
      await client.query(queryDeleteSolicitud, [id_usuario, id_club]);

      await client.query("COMMIT"); // Inicia la transacción
      console.log("Realizado");
      return { statusCode: 200, message: "Usuario expulsado con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      await client.query("ROLLBACK");
      return { statusCode: 500, message: "Error al realizar petición" };
    } finally {
      client.release();
    }
  },

  async editClub(id, nombre, descripcion, latitud, longitud, id_deporte, logo, correo, telefono, categorias, tipos, facebook, instagram, tiktok) {
    try {
      let query = `SELECT COUNT(*)
        FROM public."Club"
        WHERE (nombre = $1 OR correo = $2) AND id != $3`;
      let response = await connectionPostgres.query(query, [nombre, correo, id]);
      if (response.rows[0].count > 0) {
        return { statusCode: 400, message: "Nombre existente" };
      }
      console.log("datos: ", id, nombre, descripcion, latitud, longitud, id_deporte, logo, correo, telefono, facebook, instagram, tiktok);
      query = `UPDATE public."Club" SET nombre = $1, descripcion = $2, latitud = $3, longitud = $4, id_deporte = $5, logo = $6, correo = $7, telefono = $8, facebook = $9, instagram = $10, tiktok = $11 WHERE id = $12`;
      response = await connectionPostgres.query(query, [nombre, descripcion, latitud, longitud, id_deporte, logo, correo, telefono, facebook, instagram, tiktok, id]);

      query = `DELETE FROM public."ClubCategoria" WHERE id_club = $1`;
      response = await connectionPostgres.query(query, [id]);

      query = `DELETE FROM public."ClubTipo" WHERE id_club = $1`;
      response = await connectionPostgres.query(query, [id]);

      query = 'INSERT INTO public."ClubCategoria" (id_club, id_categoria) VALUES ';
      query += categorias.map((categoria) => `(${id}, ${categoria})`).join(", ");
      response = await connectionPostgres.query(query);

      query = 'INSERT INTO public."ClubTipo" (id_club, id_tipo) VALUES ';
      query += tipos.map((tipo) => `(${id}, ${tipo})`).join(", ");
      response = await connectionPostgres.query(query);

      return { statusCode: 200, message: "Club actualizado con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async deleteClub(id_club) {
    try {
      let query = `
        DELETE
        FROM public."Club"
        WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id_club]);
      return { statusCode: 200, message: "Club eliminado con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  // ? : NO TESTEABLE, NO SE UTILIZA
  async editImagenClub(id, logo) {
    try {
      let query = `UPDATE public."Club" SET logo = $1 WHERE id = $2`;
      const response = await connectionPostgres.query(query, [logo, id]);
      return { statusCode: 200, message: "Imagen actualizada con éxito" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
