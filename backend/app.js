const express = require("express");
const morgan = require("morgan");
const cors = require("cors");
const path = require("path");
const routes = require("./routes/index"); // Ruta al archivo index.js de las rutas
const config = require("./config/config");
const app = express();
const { finishEvents } = require("./controllers/eventosController");
const cron = require("node-cron");

const { initializeApp, applicationDefault } = require("firebase-admin/app");

initializeApp({
  credential: applicationDefault(),
  projectID: "clubconnect-5bd71",
});
// middleware
//Middlewares
app.use(morgan("tiny"));
app.use(cors());
app.use(express.json());

// Routes
require("./routes")(app);

cron.schedule("0 4 * * *", async () => {
  console.log("Running a task every minute");
  await finishEvents();
});
//Server
app.set("port", 3002);
const server = app.listen(app.get("port"), () => {
  console.log("Server on port", app.get("port"));
});
/** Que cada noche se marquen como terminados donde la fecha sea menor a la actual **/

module.exports = { app, server };
