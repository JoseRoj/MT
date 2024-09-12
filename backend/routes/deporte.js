const deportes = require("../controllers/deporteController");
const verifyToken = require("../middleware/auth");

module.exports = (app) => {
  /* Función para obtener todos los datos */
  app.get("/getDeportes", verifyToken, async (req, res) => {
    try {
      const response = await deportes.getDeportes();
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
