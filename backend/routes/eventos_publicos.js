const eventosPublicosController = require("../controllers/eventos_publicosController");
const express = require("express");

module.exports = (app) => {
  // Crear configuracion y eventos en la fecha dada
  app.get("/publicos", async (req, res) => {
    const { clubes, page } = req.body;
    console.log("C", typeof clubes, page);
    const response = await eventosPublicosController.getEventosPublicos(clubes, page);
    return response.statusCode === 400
      ? res.status(400).send({ message: response.message })
      : response.statusCode === 500
      ? res.status(500).send({ message: response.message })
      : res.status(201).send({
          data: response.data,
          message: response.message,
        });
  });
};
