const AsistenciaController = require("../controllers/asistenciaController");
module.exports = (app) => {
  // Confirmar Asistencia
  app.post("/asistencia", async (req, res) => {
    const { id_usuario, id_evento } = req.body;
    try {
      const response = await AsistenciaController.confirmAsistencia(id_usuario, id_evento);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
            message: response.message,
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Cancelar Asistencia
  app.delete("/asistencia", async (req, res) => {
    const { id_usuario, id_evento } = req.body;
    try {
      const response = await AsistenciaController.deleteAsistencia(id_usuario, id_evento);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
            message: "Asistencia cancelada con éxito",
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
