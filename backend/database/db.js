const { Pool } = require("pg");

// TODO : Conneccion DataBase
const connectionPostgres = new Pool({
  connectionString: process.env.DB_CONNECTION_STRING,
  ssl: {
    rejectUnauthorized: false, // Para evitar errores de certificado SSL
  },
});

/*connectionPostgres
  .connect()
  .then(() => console.log("Conexión exitosa a PostgreSQL"))
  .catch((err) => console.error("Error de conexión a PostgreSQL:", err));*/
module.exports = connectionPostgres;
