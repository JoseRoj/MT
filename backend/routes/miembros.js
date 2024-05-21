const MiembrosController = require("../controllers/miembros");
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
};
