const usuarioController = require("../controllers/usuariosController");

module.exports = (app) => {
  app.get("/usuarios/getUsuarios", async (req, res) => {
    try {
      const response = await usuarioController.getUsuarios();
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

  app.get("/usuarios/getUser", async (req, res) => {
    try {
      const response = await usuarioController.getUser(req.query.id);
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
  app.post("/usuarios/create", async (req, res) => {
    const {
      nombre,
      apellido1,
      apellido2,
      email,
      contrasena,
      telefono,
      fecha_nacimiento,
      genero,
    } = req.body;
    try {
      const response = await usuarioController.createUsuario(
        nombre,
        apellido1,
        apellido2,
        email,
        contrasena,
        telefono,
        fecha_nacimiento,
        genero
      );

      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(201).send({ message: response.message });
    } catch (error) {
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
