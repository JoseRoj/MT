const equipo = require("../controllers/equipoController");

module.exports = (app) => {
  app.get("/equipo/getEquipos", async (req, res) => {
    try {
      const { id_club } = req.query;
      const response = await equipo.getEquiposClub(id_club);
      return response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.get("/equipo/getEquipoById", async (req, res) => {
    const { id_usuario, id_club } = req.query;
    try {
      const response = await equipo.getEquipobyId(id_club);
      return response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.get("/equipo/getEquiposByUser", async (req, res) => {
    const { id_usuario, id_club } = req.query;
    try {
      const response = await equipo.getEquiposByUser(id_usuario, id_club);
      return response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.get("/equipo/getEquipo", async (req, res) => {
    const { id_equipo } = req.query;
    try {
      const response = await equipo.getEquipo(id_equipo);
      return response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.post("/equipo/createEquipo", async (req, res) => {
    const { nombre, id_club } = req.body;
    try {
      const response = await equipo.createEquipo(nombre, id_club);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(201).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
