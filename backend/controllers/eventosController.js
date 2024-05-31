const connectionPostgres = require("../database/db");

module.exports = {
  async getEventos(id_equipo, estado) {
    try {
      const data = [];
      const result = {
        evento: null,
        asistentes: [],
      };

      let query = "";
      let response;
      if (estado == "Todos") {
        /* Obtener Todos los eventos */
        query = `SELECT "Evento".* FROM public."Evento" 
              WHERE "Evento".id_equipo = $1`;
        response = await connectionPostgres.query(query, [id_equipo]);
      } else {
        /* Obtener Todos los eventos */
        query = `SELECT "Evento".* FROM public."Evento" 
              WHERE "Evento".id_equipo = $1 AND "Evento".estado = $2 `;
        response = await connectionPostgres.query(query, [id_equipo, estado]);
      }

      for (var equipo of response.rows) {
        query = `SELECT "Usuarios".nombre, "Usuarios".apellido1, "Usuarios".id FROM public."Usuarios" 
        JOIN public."Asistencia" ON "Usuarios".id = "Asistencia".id_usuario
        WHERE "Asistencia".id_evento = $1`;
        const response2 = await connectionPostgres.query(query, [equipo.id]);
        data.push({ evento: equipo, asistentes: response2.rows });
      }
      return { statusCode: 200, data: data, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async createEvento(
    fechas,
    id_equipo,
    descripcion,
    horaInicio,
    horaFin,
    titulo
  ) {
    try {
      let query = `INSERT INTO public."Evento" (fecha, id_equipo, descripcion, hora_inicio, hora_final, titulo, estado ) VALUES `;
      const values = [];
      const valueInserts = fechas
        .map((fecha, index) => {
          const offset = index * 6;
          values.push(
            fecha,
            id_equipo,
            descripcion,
            horaInicio,
            horaFin,
            titulo
          );
          return `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${
            offset + 4
          }, $${offset + 5}, $${offset + 6}, 'Activo')`;
        })
        .join(", ");

      query += valueInserts;
      const response = await connectionPostgres.query(query, values);
      return {
        statusCode: 201,
        data: response.rows,
        message: "Evento Creado Correctamente",
      };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
