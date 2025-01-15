const solicitudController = require("../controllers/solicitudController");
const connectionPostgres = require("../database/db");

const { getMessaging } = require("firebase-admin/messaging");
module.exports = (app) => {
  // Enviar Solicitud a un club
  app.post("/solicitud/send", async (req, res) => {
    const { id_usuario, id_club } = req.body;
    try {
      const response = await solicitudController.sendSolicitud(id_usuario, id_club);
      if (response.statusCode === 200) {
        //* -- ENVIAR NOTIFICACION A TODOS LOS MIMEBORS DEL EQUIPO -- /

        //* Obtener todos los token de los usuarios del equipo **/
        try {
          let query = `SELECT "Usuarios".tokenfb
            FROM public."Usuarios"
            JOIN public."Administra" ON "Administra".id_usuario = "Usuarios".id AND "Administra".id_club = $1
            `;

          const responsetokens = await connectionPostgres.query(query, [id_club]);
          const registrationTokens = responsetokens.rows.map((token) => {
            return token.tokenfb;
          });
          console.log("TK", responsetokens.rows[0].tokenfb);
          //* Obtener nombre del club y del Equipo **/
          query = `SELECT "Club".nombre AS club 
            FROM public."Club"
            WHERE "Club".id = $1`;
          const response2 = await connectionPostgres.query(query, [id_club]);

          const message = {
            notification: {
              title: `Solicitud de unión`,
              body: `Revisa las Solicitudes de ${response2.rows[0].club}`,
            },

            tokens: registrationTokens,
          };
          const notification = await getMessaging().sendEachForMulticast(message);
          console.log("Successfully sent message:", notification);
          return res.status(200).send({
            data: response.data,
          });
        } catch (e) {
          console.log("Error: ", e);
          return res.status(201).send({ data: response.data, message: response.message });
        }
      }

      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener estado de una solicitud
  app.get("/solicitud/getEstado", async (req, res) => {
    const { id_usuario, id_club } = req.query;
    try {
      const response = await solicitudController.getEstadoSolicitud(id_usuario, id_club);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener estado de una solicitud
  app.delete("/solicitud", async (req, res) => {
    const { id_usuario, id_club } = req.query;
    try {
      const response = await solicitudController.deleteSolicitud(id_usuario, id_club);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.get("/solicitud/getPendientes", async (req, res) => {
    const { id_club } = req.query;
    try {
      const response = await solicitudController.getSolicitudesPendientes(id_club);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.patch("/solicitud", async (req, res) => {
    const { id_usuario, id_club, estado } = req.body;
    try {
      const response = await solicitudController.updateSolicitud(id_usuario, id_club, estado);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // ? NO TEST - NO SE USA
  app.post("/send", async (req, res) => {
    const tokenreceived = req.body.token;
    // This registration token comes from the client FCM SDKs.
    const registrationToken = [
      "cZxeU_khQFyd3kzMsmoQGk:APA91bHUcHFRjQ0wbN_ByxOPMS4n9rwiB-SrlDbxJ9OF45Or_EBVGJRqzMfYuK8Nv82eCThqvulL40nNk1gRwvzS7TRfFEGyMeX5KhDNKbJoFJaoPxL5i2lAbSF-Wj6SN4Z6Pjfo01VE",
      "fZIIEQSJR1Wh9E2VlRgwyd:APA91bF9qEHOgErmU2rK7lin5u1_Rv2Ed-sBYkLamvALA_Dg-7FKLLlEDPFTjZB4mcFMPzNqNPKhcHXL3YlF0OszagO03CyXsojd2n_YuY3zCVscxV103lxxmrp7Wgsyo3nYh5oMjWxs",
    ];
    const message = {
      data: {
        route: "/home/0/club/87/equipos/24",
      },
      tokens: registrationToken,
    };

    // Send a message to the device corresponding to the provided
    // registration token.
    getMessaging()
      .sendEachForMulticast(message)
      .then((response) => {
        res.status(200).send({
          message: "Mensaje enviado",
          token: registrationToken,
        });
        // Response is a message ID string.
        console.log("Successfully sent message:", tokenreceived);
      })
      .catch((error) => {
        res.status(500).send({ message: "Error al enviar mensaje" });
        console.log("Error sending message:", error);
      });
  });
};
