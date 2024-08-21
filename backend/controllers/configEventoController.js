const connectionPostgres = require("../database/db");
const eventosController = require("./eventosController");
const estados = {
  activo: "Activo",
  finalizado: "Finalizado",
  todos: "Todos",
};
module.exports = {
  /*  
        ? param : {string} fecha_inicio :  fecha inicial de los eventos concurrentes
        ? param : {string} fecha_final  :  fecha final de los eventos concurrentes
        ? param : {string} hora_inicio  :  hora inicial de los eventos concurrentes
        ? param : {string} hora_final   :  hora final de los eventos concurrentes
        ? param : {int}    id_equipo    :  id del equipo que se le asignará la configuración
        ? param : {string} descripcion  :  descripción de los eventos concurrentes
        ? param : {string} lugar        :  lugar de los eventos concurrentes
        ? param : {int}    dia_repetible:  día de la semana en el que se repetirá el evento
    */
  async addConfigEvent(
    fecha_inicio,
    fecha_final,
    hora_inicio,
    hora_final,
    id_equipo,
    descripcion,
    lugar,
    titulo,
    dia_repetible
  ) {
    await connectionPostgres.query("BEGIN");
    /* Crear la configuración del evento */
    try {
      const sqlConfig = `INSERT INTO configevento 
        (fecha_inicio , fecha_final , hora_inicio , hora_final , id_equipo , descripcion , lugar , titulo, dia_repetible)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING id`;

      const response = await connectionPostgres.query(sqlConfig, [
        fecha_inicio,
        fecha_final,
        hora_inicio,
        hora_final,
        id_equipo,
        descripcion,
        lugar,
        titulo,
        dia_repetible,
      ]);
      const id_config = response.rows[0].id;
      console.log(id_config);

      /* Obtener las fechas en las que se repetirá el evento */
      const fechas = `SELECT gs::date 
            FROM generate_series($1::date, $2::date, '1 day'::interval) AS gs
            WHERE EXTRACT(DOW FROM gs) = $3;`;
      const responseFechas = await connectionPostgres.query(fechas, [
        fecha_inicio,
        fecha_final,
        dia_repetible,
      ]);
      console.log(responseFechas.rows);

      /* Crear todos los eventos que se encuentrar en ese rango */
      try {
        if (responseFechas.rows.length === 0) {
          await connectionPostgres.query("ROLLBACK");
          return {
            statusCode: 400,
            data: "",
            message:
              "No se encontraron fechas en las que se repetirá el evento",
          };
        }

        let query = `INSERT INTO public."Evento" (fecha, id_equipo, descripcion, hora_inicio, hora_final, titulo, estado, Lugar, id_config) VALUES `;
        const values = [];
        const valueInserts = responseFechas.rows
          .map((fecha, index) => {
            console.log(fecha.gs);
            const offset = index * 8;
            values.push(
              fecha.gs,
              id_equipo,
              descripcion,
              hora_inicio,
              hora_final,
              titulo,
              lugar,
              id_config
            );
            return `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${
              offset + 4
            }, $${offset + 5}, $${offset + 6}, '${estados.activo}' , $${
              offset + 7
            },$${offset + 8})`;
          })
          .join(", ");

        query += valueInserts;
        const response = await connectionPostgres.query(query, values);
      } catch (e) {
        console.log("Error: ", e);
        await connectionPostgres.query("ROLLBACK");
        return {
          statusCode: 400,
          data: "",
          message: "Error en la creación de los eventos",
        };
      }
      await connectionPostgres.query("COMMIT");
      return {
        statusCode: 201,
        data: response.rows,
        message: "Configuración de evento creada correctamente",
      };
    } catch (e) {
      console.log("Error: ", e);
      await connectionPostgres.query("ROLLBACK");
      return {
        statusCode: 500,
        data: "",
        message: "Error al realizar petición",
      };
    }
  },

  async getTeamConfigEvent(id_equipo) {
    try {
      const query = `SELECT * FROM configevento WHERE id_equipo = $1`;
      const response = await connectionPostgres.query(query, [id_equipo]);
      return {
        statusCode: 200,
        data: response.rows,
        message: "",
      };
    } catch (e) {
      console.log("Error: ", e);
      return {
        statusCode: 500,
        data: "",
        message: "Error al realizar petición",
      };
    }
  },
  async deleteConfigEvent(id_config) {
    try {
      connectionPostgres.query("BEGIN");
      let query = `DELETE FROM public."configevento" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id_config]);
      query = `DELETE FROM public."Evento" WHERE id_config = $1 AND estado = 'Activo'`;
      const responsedelete = await connectionPostgres.query(query, [id_config]);
      connectionPostgres.query("COMMIT");
      return { statusCode: 200, message: "Se ha eliminado con éxito" };
    } catch (e) {
      connectionPostgres.query("ROLLBACK");
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
