const MiembrosController = require("../controllers/miembrosController");
module.exports = (app) => {
  app.post("/miembro/assignMiembro", async (req, res) => {
    const { id_usuario, equipos, rol, id_club } = req.body;
    try {
      const response = await MiembrosController.AssignMiembro(
        id_usuario,
        equipos,
        rol,
        id_club
      );
      return response.statusCode === 500
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

  // TODO: TEASTEAR
  app.post("/miembro/addMiembroEquipo", async (req, res) => {
    const { id_usuario, id_equipo, rol } = req.body;
    try {
      const response = await MiembrosController.AddMiembrotoEquipo(
        id_usuario,
        id_equipo,
        rol
      );
      return response.statusCode == 400
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

  // TODO: TESTEAR
  app.delete("/miembro/deleteMiembroEquipo", async (req, res) => {
    const { id_usuario, id_equipo } = req.body;
    try {
      const response = await MiembrosController.deleteMiembro(
        id_usuario,
        id_equipo
      );
      return response.statusCode == 400
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
};
