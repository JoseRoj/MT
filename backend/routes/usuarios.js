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
      const response = await usuarioController.getUsuario(req.query.id);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("error: ", error);

      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
  app.post("/usuarios/create", async (req, res) => {
    const {
      id,
      nombre,
      apellido1,
      apellido2,
      email,
      contrasena,
      telefono,
      fecha_nacimiento,
      genero,
      imagen,
    } = req.body;
    try {
      const response = await usuarioController.createUsuario(
        id,
        nombre,
        apellido1,
        apellido2,
        email,
        contrasena,
        telefono,
        fecha_nacimiento,
        genero,
        imagen
      );

      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(201).send({ message: response.message });
    } catch (error) {
      console.log("error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
  app.get("/usuarios/rol", async (req, res) => {
    try {
      const { id_usuario, id_club, id_equipo } = req.query;
      const response = await usuarioController.getRolClub(
        id_usuario,
        id_club,
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
    } catch (error) {
      console.log("error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.get("/usuarios/getclubesUser", async (req, res) => {
    try {
      const { id_usuario } = req.query;
      const response = await usuarioController.getClubesUser(id_usuario);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
