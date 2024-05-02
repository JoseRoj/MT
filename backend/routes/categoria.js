const categoria = require("../controllers/categoriaController");

module.exports = (app) => {
  app.get("/getCategorias", async (req, res) => {
    try {
      const response = await categoria.getCategoria();
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
