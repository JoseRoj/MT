const express = require("express");
const morgan = require("morgan");
const cors = require("cors");
const path = require("path");
const routes = require("./routes/index"); // Ruta al archivo index.js de las rutas
const config = require("./config/config");
const app = express();
const { finishEvents } = require("./controllers/eventosController");
const cron = require("node-cron");
const admin = require("firebase-admin");
//const { initializeApp } = require("firebase-admin/app");
const { initializeApp, applicationDefault } = require("firebase-admin/app");

const serviceAccount = require("../backend/utils/clubconnect-5bd71-firebase-adminsdk-vz3iv-4fe7a6549e.json");

initializeApp({
  credential: applicationDefault(), //  admin.credential.cert(serviceAccount),
  projectID: "clubconnect-5bd71",
});
// middleware
//Middlewares
app.use(morgan("tiny"));
app.use(cors());
app.use(express.json());

// Routes
require("./routes")(app);

cron.schedule("18 * * * *", async () => {
  console.log("Running a task every minute");
  await finishEvents();
});
//Server
const port = 3002; // Usa un puerto diferente para pruebas

app.set("port", port);
const server = app.listen(app.get("port"), () => {
  console.log("Server on port", app.get("port"));
});
/** Que cada noche se marquen como terminados donde la fecha sea menor a la actual **/

module.exports = { app, server };
