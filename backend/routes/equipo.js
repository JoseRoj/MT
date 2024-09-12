const equipo = require("../controllers/equipoController");

module.exports = (app) => {
  // Obtener los Equipos de un club
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

  // ? NO TESTEABLE - NO SE USA
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

  // Obtener equipos de un Usuario
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

  // ? NO TESTEABLE - NO SE USA
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

  // Crear Equipo
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

  // Eliminar Equipo
  app.delete("/equipo/deleteEquipo", async (req, res) => {
    const { id_equipo } = req.query;
    try {
      const response = await equipo.deleteEquipo(id_equipo);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
            message: response.message,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener estadisticas del equipo
  app.get("/equipo/stadistic", async (req, res) => {
    const { fecha_inicio, fecha_final, id_club, id_equipo } = req.query;
    try {
      const response = await equipo.stadisticTeams(fecha_inicio, fecha_final, id_club, id_equipo);

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

  // Obtener los miembros de un equipo
  app.get("/equipo/miembros", async (req, res) => {
    const { id_equipo } = req.query;
    try {
      const response = await equipo.miembrosEquipo(id_equipo);
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
};
