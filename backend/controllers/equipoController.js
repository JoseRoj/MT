const connectionPostgres = require("../database/db");
const moment = require("moment-timezone");

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
      const response = await connectionPostgres.query(query, [id_usuario, id_club]);
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
      let query = `INSERT INTO public."Equipo"(nombre, id_club) VALUES ($1 , $2) RETURNING id`;
      const response = await connectionPostgres.query(query, [nombre, id_club]);
      console.log(response);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "Error al crear equipo" };
      }
      return { statusCode: 201, data: response.rows[0].id, message: "Equipo creado correctamente" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async deleteEquipo(id_equipo) {
    try {
      let query = `DELETE FROM public."Equipo" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id_equipo]);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "Este equipo no existe" };
      }
      return { statusCode: 200, message: "Equipo eliminado correctamente" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async miembrosEquipo(id_equipo) {
    try {
      let query = `SELECT "Usuarios".id, "Usuarios".nombre, "Usuarios".apellido1, "Usuarios".apellido2, "Usuarios".fecha_nacimiento,"Usuarios".email, "Usuarios".telefono, "Usuarios".genero,"Usuarios".imagen
       FROM public."Usuarios" WHERE id IN (SELECT id_usuario FROM public."Miembros" WHERE id_equipo = $1)`;
      const response = await connectionPostgres.query(query, [id_equipo]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async stadisticTeams(fecha_inicio, fecha_final, id_club, id_equipo) {
    try {
      const data = {
        eventos: [],
        recurrentes: [],
        userList: [],
      };
      /* Trnasformar initialDate */
      const timeInit = moment(fecha_inicio, "YYYY-MM-DD HH:mm:ss.SSSSSS");
      //const timeEnd = moment(endDate, "YYYY-MM-DD HH:mm:ss.SSSSSS");
      // Configura la zona horaria a Chile/Continental
      timeInit.tz("America/Santiago");

      const formattedTimeInitString = timeInit.toDate().toISOString();
      console.log("fecha", fecha_inicio);
      console.log("fecha", fecha_final);

      // Consultas paralelas para obtener eventos y eventos recurrentes
      const [response, responseRecurrentes, responseList] = await Promise.all([
        // Obtener todos los eventos en el rango de fechas
        connectionPostgres.query(
          `SELECT e.*, COALESCE(
           json_agg(
             json_build_object(
               'nombre', u.nombre, 
               'apellido1', u.apellido1, 
               'apellido2', u.apellido2, 
               'id', CAST(u.id AS TEXT), 
               'imagen', u.imagen
             )
           ) FILTER (WHERE u.id IS NOT NULL), '[]'
         ) AS asistentes
       FROM "Evento" e
       LEFT JOIN "Asistencia" a ON e.id = a.id_evento
       LEFT JOIN "Usuarios" u ON a.id_usuario = u.id
       WHERE e.fecha >= $1 AND e.fecha <= $2 AND e.id_equipo = $3
       GROUP BY e.id
       ORDER BY e.fecha ASC`,
          [fecha_inicio, fecha_final, id_equipo]
        ),
        // Obtener posibles eventos recurrentes
        connectionPostgres.query(`SELECT * FROM configevento WHERE (fecha_inicio >= $1 OR fecha_final <= $2) AND id_equipo = $3`, [fecha_inicio, fecha_final, id_equipo]),
        // Obtener lista de usuarios seleccionados
        connectionPostgres.query(
          `WITH UsuariosSeleccionados AS (
         SELECT DISTINCT u.id
         FROM "Miembros" m
         JOIN "Usuarios" u ON u.id = m.id_usuario
         WHERE m.id_equipo = $3
         UNION
         SELECT DISTINCT u.id
         FROM "Administra" a
         JOIN "Usuarios" u ON u.id = a.id_usuario
         WHERE a.id_club = $4
      )
      SELECT CONCAT_WS(' ', u.nombre, u.apellido1, u.apellido2) AS nombreCompleto, 
             CAST(u.id AS TEXT) AS usuario_id, -- Aquí se convierte el id a string
             COUNT(CASE WHEN (e.fecha >= $1 AND e.fecha <= $2) AND e.id_equipo = $3 THEN a.id ELSE NULL END) AS total_asistencias
      FROM UsuariosSeleccionados us
      JOIN "Usuarios" u ON u.id = us.id
      LEFT JOIN "Asistencia" a ON u.id = a.id_usuario
      LEFT JOIN "Evento" e ON a.id_evento = e.id
      GROUP BY u.id, u.nombre, u.apellido1, u.apellido2
      ORDER BY total_asistencias DESC`,
          [fecha_inicio, fecha_final, id_equipo, id_club]
        ),
      ]);

      // Asignar los resultados a los objetos correspondientes
      data.eventos = response.rows;
      data.recurrentes = responseRecurrentes.rows;
      data.userList = responseList.rows;
      return { statusCode: 200, data: data, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar la petición" };
    }
  },
};
