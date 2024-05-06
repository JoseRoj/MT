const config = require("../config/config");
const connectionPostgres = require("../database/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

module.exports = {
  async login(email, contrasena) {
    try {
      let query = `SELECT * FROM public."Usuarios" WHERE email = $1`;
      const response = await connectionPostgres.query(query, [email]);

      //console.log(bcrypt.compareSync(contrasena, response.rows[0].contrasena));
      if (
        response.rowCount > 0 &&
        (contrasena == response.rows[0].contrasena) == true
      ) {
        // Verify email and password
        const jwtoken = jwt.sign(
          {
            // token with data
            usuario: {
              id: response.rows[0].id,
              nombre: response.rows[0].nombre,
              email: response.rows[0].email,
            },
          },
          config.development.configToken.SEED,
          { expiresIn: config.development.configToken.expiration }
        );
        //jwt.sign({ _id: datos._id, nombre: datos.nombre , email: datos.email}, 'password');
        return {
          statuscode: 200,
          data: {
            user: {
              id: response.rows[0].id,
              nombre: response.rows[0].nombre,
              email: response.rows[0].email,
            },
            token: jwtoken,
          },
        };
      } else {
        return {
          statusCode: 401,
          error: "El usuario o constraseña incorrecta",
        };
      }
    } catch (error) {
      console.log("Error: ", error);
      return { statusCode: 500, error: "Error al realizar petición" };
    }
  },
};
