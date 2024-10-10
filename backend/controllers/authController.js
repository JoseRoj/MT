const config = require("../config/config");
const connectionPostgres = require("../database/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

module.exports = {
  /* Authenticacion de Usuario
    ? @param email - email del usuario
    ? @param contrasena - contraseña del usuario
  */
  async login(email, contrasena) {
    try {
      let query = `SELECT * FROM public."Usuarios" WHERE email = $1`;
      const response = await connectionPostgres.query(query, [email]);

      //console.log(bcrypt.compareSync(contrasena, response.rows[0].contrasena));
      if (response.rowCount > 0 && (contrasena == response.rows[0].contrasena) == true) {
        // Verify email and password
        const jwtoken = jwt.sign(
          {
            // token with data
            usuario: {
              id: response.rows[0].id,
              nombre: response.rows[0].nombre ?? "",
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
              telefono: response.rows[0].telefono,
              fecha_nacimiento: response.rows[0].fecha_nacimiento,
              apellido1: response.rows[0].apellido1 ?? "",
              genero: response.rows[0].genero,
              apellido2: response.rows[0].apellido2 ?? "",
              imagen: response.rows[0].imagen ?? "",
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
    } finally {
      //await connectionPostgres.end();
    }
  },

  /* Actualización Token Firebase de Usuario
    ? @param id_usuario - id del usuario
    ? @param tokenfb - nuevo token del dispositivo
  */
  async updateToken(id_usuario, tokenfb) {
    try {
      let query = `UPDATE public."Usuarios" SET tokenfb = $1 WHERE id = $2`;
      const response = await connectionPostgres.query(query, [tokenfb, id_usuario]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch (error) {
      console.log("Error: ", error);
      return { statusCode: 500, error: "Error al realizar petición" };
    }
  },
};
