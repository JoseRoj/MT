const { Pool } = require("pg");
const cron = require("node-cron");

// TODO : Conneccion DataBase
const connectionPostgres = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // Para evitar errores de certificado SSL
  },
});

(async () => {
  try {
    await connectionPostgres.connect();
    console.log("Conexión exitosa a la base de datos.");
  } catch (err) {
    console.error("Error al conectar a la base de datos:", err);
  }
})();

module.exports = connectionPostgres;
