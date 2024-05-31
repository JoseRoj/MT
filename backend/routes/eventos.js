const EventosController = require("../controllers/eventosController");
module.exports = (app) => {
  app.get("/eventos", async (req, res) => {
    try {
      const { id_equipo, estado } = req.query;
      const response = await EventosController.getEventos(id_equipo, estado);
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

  app.post("/eventos", async (req, res) => {
    console.log("req.body");
    const { fechas, id_equipo, descripcion, horaInicio, horaFin, titulo } =
      req.body;
    try {
      const response = await EventosController.createEvento(
        fechas,
        id_equipo,
        descripcion,
        horaInicio,
        horaFin,
        titulo
      );
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(201).send({
            data: response.data,
            message: "Evento creado correctamente",
          });
    } catch (e) {
      console.log("Error: ", e);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
