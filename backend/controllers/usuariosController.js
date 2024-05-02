const connectionPostgres = require("../database/db");

module.exports = {
  async getUsuarios() {
    try {
      let query = `SELECT * FROM public."Usuarios"`;
      const response = await connectionPostgres.query(query);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async getUsuario(id) {
    try {
      let query = `SELECT * FROM public."Usuarios" WHERE id = $1`;
      const response = await connectionPostgres.query(query, [id]);
      return { statusCode: 200, data: response.rows, message: "" };
    } catch {
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },

  async createUsuario(
    nombre,
    apellido1,
    apellido2,
    email,
    contrasena,
    telefono,
    fecha_nacimiento,
    genero
  ) {
    try {
      //* Primero se debe comprobar que el usuario no exista;
      let query = `SELECT COUNT(*) AS cantidad_usuarios
            FROM public."Usuarios"
            WHERE email = $1`;
      let response = await connectionPostgres.query(query, [email]);
      console.log("value : ", response.rows[0].cantidad_usuarios);
      if (response.rows[0].cantidad_usuarios > 0) {
        return { statusCode: 400, message: "Usuario existente" };
      }
      console.log("response:", response);
      //* Query para insertar el usuario
      let query1 = `INSERT INTO public."Usuarios" (nombre, apellido1, apellido2, email, telefono, contrasena, fecha_nacimiento, genero) VALUES ($1, $2, $3, $4, $5, $6, $7, $8);`;
      response = await connectionPostgres.query(query1, [
        nombre,
        apellido1,
        apellido2,
        email,
        telefono,
        contrasena,
        fecha_nacimiento,
        genero,
      ]);
      return { statusCode: 201, message: "Usuario creado con éxito" };
    } catch (error) {
      console.log("error: ", error);
      return { statusCode: 500, message: "Error al realizar petición" };
    }
  },
};
