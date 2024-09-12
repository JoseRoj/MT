const tipo = require("../controllers/tipoController");

module.exports = (app) => {
  // Obtener los diferentes tipo que puede tener un Club
  app.get("/getTipos", async (req, res) => {
    try {
      const response = await tipo.getTipo();
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
