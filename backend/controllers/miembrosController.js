const connectionPostgres = require("../database/db");
module.exports = {
  // Aceptar solicitud y asignar miembro a algun equipo
  async AssignMiembro(id_usuario, equipos, rol, id_club, estado = "Aceptado") {
    try {
      await connectionPostgres.query("BEGIN"); // Inicia la transacción

      let query = `INSERT INTO public."Miembros" (id_usuario, id_equipo, rol) VALUES`;
      query += equipos.map((element) => `($1, ${element}, $2)`).join(",");
      let response = await connectionPostgres.query(query, [id_usuario, rol]);
      console.log("Response: ", response);

      // Comprobar que se haya enviado la solicitud anteriormente
      query = `UPDATE public."Solicitud" SET estado = $3 WHERE id_usuario = $1 AND id_club = $2;`;
      response = await connectionPostgres.query(query, [id_usuario, id_club, estado]);
      console.log("Response: ", response);
      if (response.rowCount === 0) {
        await connectionPostgres.query("ROLLBACK"); // Revierte la transacción
        return { statusCode: 400, message: "No se pudo asignar" };
      }
      await connectionPostgres.query("COMMIT"); // Confirma la transacción
      return {
        statusCode: 200,
        data: response.rows,
        message: "Solicitud aceptada con éxito",
      };
    } catch (e) {
      await connectionPostgres.query("ROLLBACK"); // Revierte la transacción
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  // TODO : TESTEAR
  async AddMiembrotoEquipo(id_usuario, id_equipo, rol) {
    try {
      let query = `INSERT INTO public."Miembros" (id_usuario, id_equipo, rol) VALUES ($1, $2, $3)`;
      const response = await connectionPostgres.query(query, [id_usuario, id_equipo, rol]);
      return {
        statusCode: 200,
        message: "Miembro asignado correctamente",
      };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  // Eliminar usuario del equipo
  async deleteMiembro(id_usuario, id_equipo) {
    try {
      let query = `DELETE FROM public."Miembros" WHERE id_usuario = $1 AND id_equipo = $2`;
      const response = await connectionPostgres.query(query, [id_usuario, id_equipo]);
      if (response.rowCount === 0) {
        return { statusCode: 400, message: "No se pudo eliminar" };
      }
      return {
        statusCode: 200,
        message: "Miembro eliminado con éxito",
      };
    } catch (e) {
      console.log("Error: ", e);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
