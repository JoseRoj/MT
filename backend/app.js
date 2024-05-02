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
require("./routes")(app);

//Server
app.set("port", 3002);
app.listen(app.get("port"), () => {
  console.log("Server on port", app.get("port"));
});
