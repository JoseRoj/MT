const connectionPostgres = require("../database/db");
const estado = {
  Pendiente: "Pendiente",
  Aceptado: "Aceptada",
  Rechazado: "Rechazada",
};
module.exports = {
  /*
    * Enviar Solicitud de unión a un Club 
    ? @param id_usuario - id del usuario que envía la solicitud
    ? @param id_club - id del club al que se envía la solicitud 
  */
  async sendSolicitud(id_usuario, id_club) {
    try {
      let query = `INSERT INTO public."Solicitud" (id_usuario, id_club, estado) VALUES ($1, $2, $3)
          ON CONFLICT (id_usuario, id_club) 
          DO UPDATE SET estado = EXCLUDED.estado`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
        estado.Pendiente,
      ]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  /*
    * Obtener Estado de la solictud de unión a un Club
    ? @param id_usuario - id del usuario que envía la solicitud
    ? @param id_club - id del club al que se envía la solicitud
  */
  async getEstadoSolicitud(id_usuario, id_club) {
    try {
      /** Comprobar si es el admin */
      let query = `SELECT COUNT (*) FROM "Administra" WHERE id_usuario = $1 AND id_club = $2;`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
      ]);
      if (response.rows[0].count > 0) {
        return {
          statusCode: 200,
          data: "Admin",
          message: "Eres Administrador del club",
        };
      }

      query = `SELECT "Solicitud".estado
            FROM public."Solicitud"
            WHERE "Solicitud".id_usuario = $1 AND "Solicitud".id_club = $2;`;
      response = await connectionPostgres.query(query, [id_usuario, id_club]);
      if (response.rows.length === 0) {
        return { statusCode: 200, data: "", message: "" };
      } else {
        return { statusCode: 200, data: response.rows, message: "" };
      }
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  /*
    * Obtener solicitudes pendientes de un Club
    ? @param id_club - id del club al que se envía la solicitud
  */
  async getSolicitudesPendientes(id_club) {
    try {
      let query = `SELECT "Usuarios".* , "Solicitud".estado, "Solicitud".fecha AS fecha_solicitud
            FROM public."Solicitud"
            JOIN public."Usuarios" ON "Solicitud".id_usuario = "Usuarios".id
            WHERE "Solicitud".id_club = $1 AND "Solicitud".estado = $2;`;
      const response = await connectionPostgres.query(query, [
        id_club,
        estado.Pendiente,
      ]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  /*
    * Actualizar de estado la solicitud de unión a un Club
    ? @param id_usuario - id del usuario que envía la solicitud
    ? @param id_club - id del club al que se envía la solicitud
    ? @param estado - estado de la solicitud
  */
  async updateSolicitud(id_usuario, id_club, estado) {
    try {
      let query = `UPDATE public."Solicitud" SET estado = $3 WHERE id_usuario = $1 AND id_club = $2;`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
        estado,
      ]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  /*
    * Actualizar de estado la solicitud de unión a un Club
    ? @param id_usuario - id del usuario que envía la solicitud
    ? @param id_club - id del club al que se envía la solicitud
  */

  async deleteSolicitud(id_usuario, id_club) {
    try {
      let query = `DELETE FROM public."Solicitud" WHERE id_usuario = $1 AND id_club = $2;`;
      const response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
      ]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
