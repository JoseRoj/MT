const connectionPostgres = require("../database/db");
module.exports = {
  async AssignMiembro(id_usuario, equipos, rol, id_club, estado = "Aceptado") {
    try {
      await connectionPostgres.query("BEGIN"); // Inicia la transacción
      let query = `INSERT INTO public."Miembros" (id_usuario, id_equipo, rol) VALUES`;
      query += equipos.map((element) => `($1, ${element}, $2)`).join(",");
      let response = await connectionPostgres.query(query, [id_usuario, rol]);
      query = `UPDATE public."Solicitud" SET estado = $3 WHERE id_usuario = $1 AND id_club = $2;`;
      response = await connectionPostgres.query(query, [
        id_usuario,
        id_club,
        estado,
      ]);
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
};
