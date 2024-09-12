const { Pool } = require("pg");
const cron = require("node-cron");

// TODO : Conneccion DataBase
const connectionPostgres = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // Para evitar errores de certificado SSL
  },
});

module.exports = connectionPostgres;
