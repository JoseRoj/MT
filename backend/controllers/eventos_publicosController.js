const connectionPostgres = require("../database/db");

module.exports = {
  /*
     * Metodo para traer todos los eventos publicos en estado "True" que se encuentren entre los clubes que estan presentes  
     ? @
    */

  async getEventosPublicos(clubes, page) {
    try {
      console.log("Clubes", clubes);
      // Construimos una lista de placeholders dinámicamente para cada elemento
      const placeholders = clubes.map((_, index) => `$${index + 1}`).join(", ");
      const positionOfset = Number(page) * 2;
      console.log(clubes.length);
      var query = `   
        SELECT 
           *
        FROM 
            "EventosPublicos"
        WHERE 
            "EventosPublicos".club_id IN (${placeholders}) 
            AND "EventosPublicos".estado = true 
            AND "EventosPublicos".fecha_evento > CURRENT_DATE
        ORDER BY fecha_evento ASC
        OFFSET ${positionOfset} LIMIT 2
        ;`;

      const responseQueryEventos = await connectionPostgres.query(query, [...clubes]);
      console.log("Response :", responseQueryEventos.rows);
      return { statusCode: 200, data: responseQueryEventos.rows, message: "" };
    } catch (e) {
      console.log(e);
      return { statusCode: 500, message: "Error al realizar la solicitud" };
    }
  },

  async createEventoPublico(post) {
    try {
      var createQuery = `
      INSERT INTO "EventosPublicos" (fecha_publicacion, fecha_evento, estado, club_id, image) VALUES ($1, $2, $3, $4, $5) RETURNING id`;
      response = await connectionPostgres.query(createQuery, [post.fecha_publicacion, post.fecha_evento, post.estado, post.club_id, post.image]);
      console.log(response.rows[0].id);
      return { statusCode: 200, data: response.rows[0].id, message: "" };
    } catch (e) {
      return { statusCode: 500, message: "Error al realizar la solicitud" };
    }
  },

  async updateEventoPublico(post) {
    try {
      var updateQuery = `
      UPDATE INTO "EventosPublicos"
      SET fecha_publicacion = $1 , fecha_evento = $2, estado = $3, image = $4
      WHERE id = $5`;
      response = await connectionPostgres.query(updateQuery, [post.fecha_publicacion, post.fecha_evento, post.estado, post.image, post.id]);
      return { statusCode: 200, data: [], message: "Evento Actualizado" };
    } catch (e) {
      return { statusCode: 500, message: "Error al realizar la solicitud" };
    }
  },
};
/*INNER JOIN 
            "Club" ON "Club".id = "EventosPublicos".club_id*/
