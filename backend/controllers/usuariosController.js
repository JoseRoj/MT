const connectionPostgres = require("../database/db");

module.exports = {
  /*
   * Obtener todos los usuarios
   */
  async getUsuarios() {
    try {
      let query = `SELECT * FROM public."Usuarios"`;
      const response = await connectionPostgres.query(query);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
  /*
    * Obtener un usuario por su id
    ? @param id - id del usuario
  */
  async getUsuario(id) {
    try {
      let query = `SELECT * FROM public."Usuarios" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id]);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "Usuario no encontrado" };
      }
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
  /*
    * Crear un usuario
    ? @param nombre - nombre del usuario
    ? @param apellido1 - primer apellido del usuario
    ? @param apellido2 - segundo apellido del usuario
    ? @param email - email del usuario
    ? @param contrasena - contraseña del usuario
    ? @param telefono - teléfono del usuario
    ? @param fecha_nacimiento - fecha de nacimiento del usuario
    ? @param genero - género del usuario
    ? @param imagen - imagen del usuario
  */
  async createUsuario(
    id,
    nombre,
    apellido1,
    apellido2,
    email,
    contrasena,
    telefono,
    fecha_nacimiento,
    genero,
    imagen
  ) {
    try {
      //* Primero se debe comprobar que el usuario no exista;
      let query = `SELECT COUNT(*) AS cantidad_usuarios
            FROM public."Usuarios"
            WHERE email = $1`;
      let response = await connectionPostgres.query(query, [email]);
      if (response.rows[0].cantidad_usuarios > 0) {
        return { statusCode: 400, message: "Correo existente" };
      }

      //* Query para insertar el usuario
      if (id) {
        let query1 = `INSERT INTO public."Usuarios" (id, nombre, apellido1, apellido2, email, telefono, contrasena, fecha_nacimiento, genero, imagen) VALUES ($10 ,$1, $2, $3, $4, $5, $6, $7, $8, $9);`;
        response = await connectionPostgres.query(query1, [
          nombre,
          apellido1,
          apellido2,
          email,
          telefono,
          contrasena,
          fecha_nacimiento,
          genero,
          imagen,
          id,
        ]);
      } else {
        let query1 = `INSERT INTO public."Usuarios" (nombre, apellido1, apellido2, email, telefono, contrasena, fecha_nacimiento, genero, imagen) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);`;
        response = await connectionPostgres.query(query1, [
          nombre,
          apellido1,
          apellido2,
          email,
          telefono,
          contrasena,
          fecha_nacimiento,
          genero,
          imagen,
        ]);
      }

      return { statusCode: 201, message: "Usuario creado con éxito" };
    } catch (error) {
      console.log("error: ", error);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  /**
   * * Obtener el rol del usuario
   *
   */
  async getRolClub(id_usuario, id_club, id_equipo) {
    console.log("id_usuario: ", id_usuario);
    console.log("id_club: ", id_club);
    console.log("id_equipo: ", id_equipo);
    try {
      // *  Verficar que el usuario es administrador del club
      let query = `SELECT * FROM public."Administra" WHERE id_usuario = $1 AND id_club = $2`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
      ]);
      if (response.rows.length === 0) {
        //* Si no es Administrador Verificar si es Entrenador  --- cuando se ingresa al equipo especifico**/
        if (id_equipo != null && id_equipo != undefined && id_equipo != "") {
          let queryEntrenador = `SELECT * FROM public."Miembros" WHERE id_usuario = $1 AND id_equipo = $2 AND rol = 'Entrenador'`;
          const rolEntrenador = await connectionPostgres.query(
            queryEntrenador,
            [id_usuario, id_equipo]
          );

          if (rolEntrenador.rows.length > 0) {
            return {
              statusCode: 200,
              data: "Entrenador",
              message: "",
            };
          }
        }
        return {
          statusCode: 200,
          data: "",
          message: "No existe información",
        };
      }
      // * Si no es administrador del club, ver si es Deportista o Entrenador
      /*if (response.rows.length === 0) {
        // No es administrador del club
        let query2 = `SELECT * FROM public."Deportistas" WHERE id_usuario = $1 AND id_club = $2`;
        const response2 = await connectionPostgres.query(query2, [
          id_usuario,
          id_club,
        ]);

      }*/
      return { statusCode: 200, data: "Administrador", message: "" };
    } catch (error) {
      console.log("Error: ", error);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
  /**
   * * Obtener los clubes de un usuario
   * TODO:
   */
  async getClubesUser(id_usuario) {
    try {
      // * Si el administrador se obtiene solo los clubes de administrador
      let query = `SELECT "Club".*, "Deporte".nombre AS deporte
      FROM public."Club"
      JOIN public."Deporte" ON "Club".id_deporte = "Deporte".id
      JOIN public."Administra" ON "Club".id = "Administra".id_club
      WHERE "Administra".id_usuario = $1;`;
      const response = await connectionPostgres.query(query, [id_usuario]);
      //* Si el usuario es deportista se obtienen los clubes de deportista
      let query2 = `SELECT "Club".*, "Deporte".nombre AS deporte
      FROM public."Club"
      JOIN public."Deporte" ON "Club".id_deporte = "Deporte".id
      JOIN public."Equipo" ON "Club".id = "Equipo".id_club
      JOIN public."Miembros" ON "Equipo".id = "Miembros".id_equipo
      WHERE "Miembros".id_usuario = $1;`;
      /* Obetener no repetidos por id de club */
      const response2 = await connectionPostgres.query(query2, [id_usuario]);
      /* Unir ambos clubes */
      const arrayClubes = response.rows.concat(response2.rows);
      const uniqueClub = new Map(arrayClubes.map((club) => [club.id, club]));
      const arrayUniqueClub = Array.from(uniqueClub.values());
      return { statusCode: 200, data: arrayUniqueClub, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async updateImage(id, imagen) {
    try {
      let query = `UPDATE public."Usuarios" SET imagen = $1 WHERE id = $2`;
      const response = await connectionPostgres.query(query, [imagen, id]);
      console.log("response: ", imagen);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "Usuario no encontrado" };
      }
      return { statusCode: 200, message: "Imagen actualizada" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async getStadistic(id_usuario, id_equipo) {
    try {
      let query = `SELECT *
        FROM(
        SELECT 
            CountEventos.year,
            CASE CountEventos.mes
                WHEN 1 THEN 'Enero'
                WHEN 2 THEN 'Febrero'
                WHEN 3 THEN 'Marzo'
                WHEN 4 THEN 'Abril'
                WHEN 5 THEN 'Mayo'
                WHEN 6 THEN 'Junio'
                WHEN 7 THEN 'Julio'
                WHEN 8 THEN 'Agosto'
                WHEN 9 THEN 'Septiembre'
                WHEN 10 THEN 'Octubre'
                WHEN 11 THEN 'Noviembre'
                WHEN 12 THEN 'Diciembre'
            END AS mes,
              CAST(COALESCE(countParticipacion.cantidad_participacion, 0) AS INTEGER) AS participation,
            CAST(CountEventos.total_eventos AS INTEGER) AS total_eventos,
                    PERCENT_RANK() OVER (ORDER BY cantidad_participacion) * 100 AS percentile,
            CAST(COALESCE(CountParticipacion.id_usuario,0) AS INTEGER) AS id_usuario

        FROM 
            (SELECT 
                EXTRACT(YEAR FROM fecha) AS year,
                EXTRACT(MONTH FROM fecha) AS mes,
                COUNT(*) AS total_eventos
            FROM 
                "Evento"
            WHERE fecha >= (CURRENT_DATE - INTERVAL '5 months')
            GROUP BY 
                EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha)
            ) countEventos
        INNER JOIN 
            (SELECT 
                EXTRACT(YEAR FROM fecha) AS year,
                EXTRACT(MONTH FROM fecha) AS mes,
                COUNT(*) AS cantidad_participacion,
                "Asistencia".id_usuario

            FROM 
                "Asistencia"
            JOIN "Miembros" ON "Asistencia".id_usuario = "Miembros".id_usuario
            INNER JOIN "Evento" ON "Evento".id = "Asistencia".id_evento
            WHERE "Evento".id_equipo = $2 
              AND "Evento".fecha >= (CURRENT_DATE - INTERVAL '5 months')
            GROUP BY 
                EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha), "Asistencia".id_usuario
            ) countParticipacion
        ON CountEventos.year = countParticipacion.year AND CountEventos.mes = countParticipacion.mes
        ORDER BY 
            CountEventos.year, CountEventos.mes
        ) AS dataParticipation
        WHERE id_usuario = $1`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_equipo,
      ]);
      console.log("response: ", response.rows);
      if (response.rowCount === 0) {
        return {
          statusCode: 200,
          data: [],
          message: "Estadísticas no encontradas",
        };
      }
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
