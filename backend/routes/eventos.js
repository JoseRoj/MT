const routes = require(".");
const EventosController = require("../controllers/eventosController");
const connectionPostgres = require("../database/db");
const { getMessaging } = require("firebase-admin/messaging");

module.exports = (app) => {
  // Obtener Eventos
  app.get("/eventos", async (req, res) => {
    try {
      const { id_equipo, estado, initialDate, month, year } = req.query;
      const response = await EventosController.getEventos(id_equipo, estado, initialDate, month, year);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
  /*
  app.get("/evento", async (req, res) => {
    try {
      const { id_evento } = req.query;
      const response = await EventosController.getEvento(id_evento);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });*/

  // Crear Evento
  app.post("/eventos", async (req, res) => {
    console.log("req.body");
    const { fechas, id_equipo, descripcion, horaInicio, horaFin, titulo, lugar, id_club } = req.body;
    try {
      const response = await EventosController.createEvento(fechas, id_equipo, descripcion, horaInicio, horaFin, titulo, lugar);
      if (response.statusCode === 201) {
        //* -- ENVIAR NOTIFICACION A TODOS LOS MIMEBORS DEL EQUIPO -- /

        //* Obtener todos los token de los usuarios del equipo **/
        try {
          let query = `SELECT "Usuarios".tokenfb FROM public."Usuarios"
        JOIN public."Miembros" ON "Usuarios".id = "Miembros".id_usuario
        WHERE "Miembros".id_equipo = $1 AND "Usuarios".tokenfb IS NOT NULL;`;

          const responsetokens = await connectionPostgres.query(query, [id_equipo]);

          const registrationTokens = responsetokens.rows.map((token) => {
            return token.tokenfb;
          });
          console.log("TK", registrationTokens);
          //* Obtener nombre del club y del Equipo **/
          query = `SELECT "Club".nombre AS club, "Equipo".nombre AS equipo FROM public."Club"
        JOIN public."Equipo" ON "Club".id = "Equipo".id_club
        WHERE "Equipo".id = $2 AND "Club".id = $1`;
          const response2 = await connectionPostgres.query(query, [id_club, id_equipo]);

          if (fechas.length == 1) {
            const fecha = new Date(fechas);

            // Obtener los componentes de la fecha
            const dia = String(fecha.getDate()).padStart(2, "0"); // Obtener el día y asegurarse que tenga 2 dígitos
            const mes = String(fecha.getMonth() + 1).padStart(2, "0"); // Obtener el mes (0-11) y sumar 1
            const anio = fecha.getFullYear(); // Obtener el año

            // Formatear la fecha como 'dd/mm/yyyy'
            const fechaFormateada = `${dia}/${mes}/${anio}`;
            const message = {
              notification: {
                title: `Se ha creado un nuevo evento en ${response2.rows[0].equipo}`,
                body: `Nuevo evento creado para el ${fechaFormateada}: ${titulo}`,
              },
              data: {
                route: `/home/0/club/${id_club}/equipos/${id_equipo}`,
              },
              tokens: registrationTokens,
            };
            const notification = await getMessaging().sendEachForMulticast(message);
            return res.status(201).send({ message: "" });
          } else {
            const message = {
              notification: {
                title: `Se han creado eventos en ${response2.rows[0].equipo}`,
                body: `Revisa en ClubConnect los eventos creados`,
              },
              data: {
                route: `/home/0/club/${id_club}/equipos/${id_equipo}`,
              },
              token: registrationTokens,
            };
            const notification = await getMessaging().sendEachForMulticast(message);
            console.log("Successfully sent message:", notification);
            return res.status(201).send({ data: response.data, message: response.message });
          }
        } catch (e) {
          console.log("Error: ", e);
          return res.status(201).send({ data: response.data, message: response.message });
        }
        /*try {
          const registrationToken =
            "f13hdD14RCyx_L5mgQgeBG:APA91bE2V5HDXV-VZxhdo2zXT7ae3j-vV66Rl1zgFlIcLhvFMvGISrX6Bug8Hn8VxWMj5BRGO29QyzLIsWl7NjJcAVDEPVmdy9Jdk4b_wP9T2hXFxwNQBMrkySjC_N4ySiYvq_W7iYvx";
         
          console.log("Successfully sent message:", notification);
          return res.status(201).send({ message: response.message });
        } catch (e) {
          console.log("Error: ", e);
          return res.status(201).send({ message: response.message });
        }*/
      }
      return response.statusCode === 400 ? res.status(400).send({ message: response.message }) : res.status(500).send({ message: response.message });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.delete("/eventos", async (req, res) => {
    const { id_evento } = req.body;
    try {
      const response = await EventosController.deleteEvento(id_evento);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({ message: response.message });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Actualizar eventos
  app.put("/eventos", async (req, res) => {
    const { id_evento, fecha, descripcion, horaInicio, horaFin, titulo, lugar, asistentes } = req.body;
    try {
      const response = await EventosController.editEvento(id_evento, fecha, descripcion, horaInicio, horaFin, titulo, lugar, asistentes);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({ message: response.message });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Finalizar o Activar un evento
  app.patch("/eventos/estado", async (req, res) => {
    const { id_evento, estado } = req.body;
    console.log("id_evento: ", id_evento);
    console.log("estado: ", estado);
    try {
      const response = await EventosController.updateEstado(id_evento, estado);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({ message: response.message });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
