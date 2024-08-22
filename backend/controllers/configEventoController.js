const connectionPostgres = require("../database/db");
const eventosController = require("./eventosController");
const estados = {
  activo: "Activo",
  finalizado: "Finalizado",
  todos: "Todos",
};
const sameDate = (date1, date2) => {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  );
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
    connectionPostgres.query("BEGIN");
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

      /* Obtener las fechas en las que se repetirá el evento */
      const fechas = `SELECT gs::date 
            FROM generate_series($1::date, $2::date, '1 day'::interval) AS gs
            WHERE EXTRACT(DOW FROM gs) = $3`;
      const responseFechas = await connectionPostgres.query(fechas, [
        fecha_inicio,
        fecha_final,
        dia_repetible,
      ]);
      console.log(responseFechas.rows);

      /* Crear todos los eventos que se encuentrar en ese rango */
      try {
        if (responseFechas.rows.length === 0) {
          connectionPostgres.query("ROLLBACK");
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
        connectionPostgres.query("ROLLBACK");
        return {
          statusCode: 400,
          data: "",
          message: "Error en la creación de los eventos",
        };
      }
      connectionPostgres.query("COMMIT");
      return {
        statusCode: 201,
        data: response.rows,
        message: "Configuración de evento creada correctamente",
      };
    } catch (e) {
      console.log("Error: ", e);
      connectionPostgres.query("ROLLBACK");
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

  async editConfigEvento(
    id,
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
    try {
      console.log("Editando configuración");
      connectionPostgres.query("BEGIN");
      const id_config = id;
      console.log(id_config);
      /* Obtener las fechas de incio y final de los eventos concurrentes */
      const queryFechas = `SELECT fecha_inicio, fecha_final, dia_repetible FROM public."configevento" WHERE id = $1`;
      const responseFechas = await connectionPostgres.query(queryFechas, [
        id_config,
      ]);
      /* Si la fecha de inicio y final no cambian */
      if (
        sameDate(
          new Date(responseFechas.rows[0].fecha_inicio),
          new Date(fecha_inicio)
        ) &&
        sameDate(
          new Date(responseFechas.rows[0].fecha_final),
          new Date(fecha_final)
        ) &&
        dia_repetible == responseFechas.rows[0].dia_repetible
      ) {
        console.log("No cambio nada!");
        /* Si las fechas no cambiaron se actualiza la configuración */
        const query = `UPDATE public."configevento" SET hora_inicio = $1, hora_final = $2, id_equipo = $3, descripcion = $4, lugar = $5, titulo = $6, dia_repetible = $7 WHERE id = $8`;
        const response = await connectionPostgres.query(query, [
          hora_inicio,
          hora_final,
          id_equipo,
          descripcion,
          lugar,
          titulo,
          dia_repetible,
          id_config,
        ]);
        /*Editar los eventos que se encuentran en ese rango con el id_config*/
        const queryEventos = `UPDATE public."Evento" SET descripcion = $1, hora_inicio = $2, hora_final = $3, titulo = $4, Lugar = $5 WHERE id_config = $6 AND estado = 'Activo'`;
        const responseEventos = await connectionPostgres.query(queryEventos, [
          descripcion,
          hora_inicio,
          hora_final,
          titulo,
          lugar,
          id_config,
        ]);
        connectionPostgres.query("COMMIT");
        return { statusCode: 200, message: "Se ha editado con éxito" };
      } else {
        console.log("Algo cambio");

        /* Pero si la fecha de inicio o final cambian */
        /* Se eliminan los eventos que se encuentran en ese rango con el id_config y que se ecneuntren activos */
        const queryDelete = `DELETE FROM public."Evento" WHERE id_config = $1 AND estado = 'Activo'`;
        const responseDelete = await connectionPostgres.query(queryDelete, [
          id_config,
        ]);

        /* Editar configuracion del evento */
        const queryUpdate = `UPDATE public."configevento" SET fecha_inicio = $1, fecha_final = $2, hora_inicio = $3, hora_final = $4, id_equipo = $5, descripcion = $6, lugar = $7, titulo = $8, dia_repetible = $9 WHERE id = $10`;
        const responseUpdateConfig = await connectionPostgres.query(
          queryUpdate,
          [
            fecha_inicio,
            fecha_final,
            hora_inicio,
            hora_final,
            id_equipo,
            descripcion,
            lugar,
            titulo,
            dia_repetible,
            id_config,
          ]
        );

        /* Obtener las fechas en las que se repetirá el evento */
        const fechas = `SELECT gs::date 
          FROM generate_series($1::date, $2::date, '1 day'::interval) AS gs
          WHERE EXTRACT(DOW FROM gs) = $3`;
        const responseFechas = await connectionPostgres.query(fechas, [
          fecha_inicio,
          fecha_final,
          dia_repetible,
        ]);

        /* Crear todos los eventos que se encuentrar en ese rango */
        try {
          if (responseFechas.rows.length === 0) {
            connectionPostgres.query("ROLLBACK");
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
          connectionPostgres.query("ROLLBACK");
          return {
            statusCode: 400,
            data: "",
            message: "Error en la creación de los eventos",
          };
        }
        return { statusCode: 200, message: "Se ha editado con éxito" };
      }
    } catch (e) {
      connectionPostgres.query("ROLLBACK");
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
