const connectionPostgres = require("../database/db");
const moment = require("moment-timezone");

const estados = {
  activo: "Activo",
  finalizado: "Finalizado",
  todos: "Todos",
};
module.exports = {
  async getEventos(id_equipo, estado, initialDate, endDate) {
    /* Trnasformar initialDate */
    const timeInit = moment(initialDate, "YYYY-MM-DD HH:mm:ss.SSSSSS");
    const timeEnd = moment(endDate, "YYYY-MM-DD HH:mm:ss.SSSSSS");

    // Configura la zona horaria a Chile/Continental
    timeInit.tz("America/Santiago");
    timeEnd.tz("America/Santiago");

    const formattedTimeInitString = timeInit.toDate().toISOString();
    const formattedTimeEndString = timeEnd.toDate().toISOString();

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
              WHERE "Evento".id_equipo = $1
              AND "Evento".fecha BETWEEN $2 AND $3
              ORDER BY "Evento".fecha ASC`;
        response = await connectionPostgres.query(query, [
          id_equipo,
          formattedTimeInitString,
          formattedTimeEndString,
        ]);
      } else {
        /* Obtener Todos los eventos */
        query = `SELECT "Evento".* FROM public."Evento" 
              WHERE "Evento".id_equipo = $1 AND "Evento".estado = $2
              AND "Evento".fecha BETWEEN $3 AND $4
              ORDER BY "Evento".fecha ASC`;
        response = await connectionPostgres.query(query, [
          id_equipo,
          estado,
          formattedTimeInitString,
          formattedTimeEndString,
        ]);
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
    titulo,
    lugar
  ) {
    try {
      let query = `INSERT INTO public."Evento" (fecha, id_equipo, descripcion, hora_inicio, hora_final, titulo, estado, Lugar ) VALUES `;
      const values = [];
      const valueInserts = fechas
        .map((fecha, index) => {
          const offset = index * 7;
          values.push(
            fecha,
            id_equipo,
            descripcion,
            horaInicio,
            horaFin,
            titulo,
            lugar
          );
          return `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${
            offset + 4
          }, $${offset + 5}, $${offset + 6}, '${estados.activo}' , $${
            offset + 7
          })`;
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

  // TODO: TESTEAR
  async deleteEvento(id_evento) {
    try {
      let query = `DELETE FROM public."Evento" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id_evento]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async editEvento(
    id_evento,
    fecha,
    descripcion,
    horaInicio,
    horaFin,
    titulo,
    lugar,
    asistentesDelete
  ) {
    try {
      //* Actualizar Información del Evento **/
      let query = `UPDATE public."Evento" SET fecha = $1, descripcion = $2, hora_inicio = $3, hora_final = $4, titulo = $5, lugar = $6 WHERE id = $7`;
      const response = await connectionPostgres.query(query, [
        fecha,
        descripcion,
        horaInicio,
        horaFin,
        titulo,
        lugar,
        id_evento,
      ]);
      if (response.rowCount === 0)
        return { statusCode: 400, message: "No se encontró el evento" };
      console.log("Asistentes :" + asistentesDelete);
      //*Actualizar asistentes a los eventos //*
      if (asistentesDelete.length > 0) {
        query = `DELETE FROM public."Asistencia" WHERE id_evento = $1 AND id_usuario = $2`;
        for (var asistente of asistentesDelete) {
          await connectionPostgres.query(query, [id_evento, asistente]);
        }
      }
      return { statusCode: 200, data: response.rows, message: "Actualizado" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async updateEstado(id_evento, estado) {
    try {
      let query = `UPDATE public."Evento" SET estado = $2 WHERE id = $1`;
      const response = await connectionPostgres.query(query, [
        id_evento,
        estado,
      ]);
      if (response.rowCount === 0)
        return { statusCode: 400, message: "No se encontró el evento" };
      return {
        statusCode: 200,
        data: response.rows,
        message: "Evento Finalizado",
      };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
