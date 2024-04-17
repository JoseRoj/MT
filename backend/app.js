const express = require("express");
const morgan = require("morgan");
const cors = require("cors");
const path = require("path");
const { Client } = require("pg");
const routes = require("./routes/index"); // Ruta al archivo index.js de las rutas
const config = require("./config/config");

const app = express();

// middleware
//Middlewares
app.use(morgan("tiny"));
app.use(cors());
app.use(express.json());

// Routes
routes(app);

// Connection to postgresSQL

// TODO : Conneccion DataBase
const connectionPostgres = new Client({
  connectionString: config.development.connectString,
  ssl: {
    rejectUnauthorized: false, // Para evitar errores de certificado SSL
  },
});

// Establecer la conexión
connectionPostgres.connect((err) => {
  if (err) {
    console.error("Error al conectar a la base de datos:", err);
    return;
  }
  console.log("Conexión exitosa con la base de datos postgres.");
});

const createTableQuery = `
  CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100) UNIQUE
  )
`;

//Server
app.set("port", 3000);
app.listen(app.get("port"), () => {
  console.log("Server on port", app.get("port"));
});
