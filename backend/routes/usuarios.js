const usuarioController = require("../controllers/usuariosController");

module.exports = (app) => {
  // ? NO TEST - NO SE USA
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
      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener inforamcion de un usuario
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

      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Testear la creacion de un usuario
  app.post("/usuarios/create", async (req, res) => {
    const { nombre, apellido1, apellido2, email, contrasena, telefono, fecha_nacimiento, genero, imagen } = req.body;
    try {
      const response = await usuarioController.createUsuario(nombre, apellido1, apellido2, email, contrasena, telefono, fecha_nacimiento, genero, imagen);

      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(201).send({ data: response.data, message: response.message });
    } catch (error) {
      console.log("error: ", error);
      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener Rol del usuario en un club y equipo determinado
  app.get("/usuarios/rol", async (req, res) => {
    try {
      const { id_usuario, id_club, id_equipo } = req.query;
      const response = await usuarioController.getRolClub(id_usuario, id_club, id_equipo);
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
      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener los clubes a los cuales esta asociado un usuario //
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
            message: response.message,
          });
    } catch (error) {
      console.log("error: ", error);
      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // ? NO TEST - NO SE USA
  app.patch("/usuarios/updateImage", async (req, res) => {
    const { id, imagen } = req.body;
    try {
      const response = await usuarioController.updateImage(id, imagen);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({ message: response.message });
    } catch (error) {
      console.log("error: ", error);
      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  // Obtener estadisticas del Usuario en un equipo respectivo
  app.get("/usuarios/stadistic", async (req, res) => {
    try {
      const { id_usuario, id_equipo } = req.query;
      const response = await usuarioController.getStadistic(id_usuario, id_equipo);
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

  app.put("/usuarios/update", async (req, res) => {
    try {
      const { nombre, apellido1, apellido2, email, telefono, fecha_nacimiento, genero, imagen, id } = req.body;

      const response = await usuarioController.updateUser(id, nombre, apellido1, apellido2, email, telefono, fecha_nacimiento, genero, imagen);
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
      return res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
