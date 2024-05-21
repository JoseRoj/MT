const solicitudController = require("../controllers/solicitudController");

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
};
