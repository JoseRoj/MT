const clubController = require("../controllers/clubController");
const express = require("express");

module.exports = (app) => {
  app.get("/club/getclubs", async (req, res) => {
    try {
      const response = await clubController.getClubs();
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.get("/club/getclub", async (req, res) => {
    try {
      const response = await clubController.getClub(req.query.id);
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({
            data: response.data,
          });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });

  app.post("/club", async (req, res) => {
    const {
      nombre,
      descripcion,
      latitud,
      longitud,
      id_deporte,
      logo,
      correo,
      telefono,
      categorias,
    } = req.body;

    console.log("Categorias: ", categorias);

    try {
      const response = await clubController.createClub(
        nombre,
        descripcion,
        latitud,
        longitud,
        id_deporte,
        logo,
        correo,
        telefono,
        categorias
      );
      return response.statusCode === 400
        ? res.status(400).send({ message: response.message })
        : response.statusCode === 500
        ? res.status(500).send({ message: response.message })
        : res.status(200).send({ message: response.message });
    } catch (error) {
      console.log("Error: ", error);
      res.status(500).send({ message: "Error interno del servidor" });
    }
  });
};
