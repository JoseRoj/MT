const solicitudController = require("../controllers/solicitudController");
const { getMessaging } = require("firebase-admin/messaging");
module.exports = (app) => {
  app.post("/solicitud/send", async (req, res) => {
    const { id_usuario, id_club } = req.body;
    try {
      const response = await solicitudController.sendSolicitud(
        id_usuario,
        id_club
      );
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

  app.get("/solicitud/getEstado", async (req, res) => {
    const { id_usuario, id_club } = req.query;
    try {
      const response = await solicitudController.getEstadoSolicitud(
        id_usuario,
        id_club
      );
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
      const response = await solicitudController.getSolicitudesPendientes(
        id_club
      );
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
      const response = await solicitudController.updateSolicitud(
        id_usuario,
        id_club,
        estado
      );
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
