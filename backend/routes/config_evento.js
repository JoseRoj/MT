const configEventoController = require("../controllers/configEventoController");
module.exports = (app) => {
  app.post("/configEvento", async (req, res) => {
    const {
      fecha_inicio,
      fecha_final,
      hora_inicio,
      hora_final,
      id_equipo,
      descripcion,
      lugar,
      titulo,
      dia_repetible,
    } = req.body;
    const response = await configEventoController.addConfigEvent(
      fecha_inicio,
      fecha_final,
      hora_inicio,
      hora_final,
      id_equipo,
      descripcion,
      lugar,
      titulo,
      dia_repetible
    );
    return response.statusCode === 400
      ? res.status(400).send({ message: response.message })
      : response.statusCode === 500
      ? res.status(500).send({ message: response.message })
      : res.status(201).send({
          data: response.data,
          message: response.message,
        });
  }),
    app.get("/configEventos", async (req, res) => {
      const { id_equipo } = req.query;
      const response = await configEventoController.getTeamConfigEvent(
        id_equipo
      );
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
            message: response.message,
          });
    });

  app.delete("/configEvento", async (req, res) => {
    const { id_config } = req.query;
    const response = await configEventoController.deleteConfigEvent(id_config);
    return response.statusCode === 400
      ? res.status(400).send({ message: response.message })
      : response.statusCode === 500
      ? res.status(500).send({ message: response.message })
      : res.status(200).send({
          data: response.data,
          message: response.message,
        });
  });
};
