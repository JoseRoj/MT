const AsistenciaController = require("../controllers/asistenciaController");
module.exports = (app) => {
  app.post("/asistencia", async (req, res) => {
    const { id_usuario, id_evento } = req.body;
    try {
      const response = await AsistenciaController.confirmAsistencia(
        id_usuario,
        id_evento
      );
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(201).send({
            data: response.data,
            message: "Asistencia confirmada correctamente",
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.delete("/asistencia", async (req, res) => {
    const { id_usuario, id_evento } = req.body;
    try {
      const response = await AsistenciaController.deleteAsistencia(
        id_usuario,
        id_evento
      );
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
            message: "Asistencia eliminada correctamente",
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
