const auth = require("../controllers/authController");
module.exports = (app) => {
  app.post("/login", async (req, res) => {
    try {
      const { email, contrasena } = req.body;
      const response = await auth.login(email, contrasena);
      return response.statusCode === 401
        ? res
            .status(401)
            .send({ message: response.message, data: response.data })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor " });
      //return { statusCode: 500, error: "Error interno del servidor " + error }
    }
  });

  //TODO : TESTEAR
  app.patch("/token", async (req, res) => {
    try {
      const { id_usuario, tokenfb } = req.body;
      const response = await auth.updateToken(id_usuario, tokenfb);
      response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor " });
      //return { statusCode: 500, error: "Error interno del servidor " + error }
    }
  });
};
