const fs = require("fs");
const path = require("path");
const cron = require("node-cron");

/** Que cada noche se marquen como terminados donde la fecha sea menor a la actual **/

cron.schedule("56 * * * *", () => {
  console.log("running every minute to 1 from 5");
});

function realizarTareaDiaria() {
  // Aquí va la lógica de la función que deseas ejecutar cada día
  console.log("Tarea diaria realizada");
  // Por ejemplo, podrías enviar correos, limpiar bases de datos, etc.
}

module.exports = (app) => {
  app.get("/api", (_req, res) => {
    res.status(200).send({
      data: "Welcome Node PostgreSQL API v1",
    });
  });

  fs.readdirSync(__dirname)
    .filter((file) => file !== "index.js" && file.endsWith(".js"))
    .forEach((file) => {
      const route = require(path.join(__dirname, file));
      route(app);
    });
};
