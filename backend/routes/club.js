const clubController = require("../controllers/clubController");
const express = require("express");

module.exports = (app) => {
  app.get("/club/getclubs", async (req, res) => {
    try {
      const {
        deportes,
        northeastLat,
        northeastLng,
        southwestLat,
        southwestLng,
      } = req.body;
      console.log(
        deportes,
        northeastLat,
        northeastLng,
        southwestLat,
        southwestLng
      );
      const response = await clubController.getClubs(
        deportes,
        northeastLat,
        northeastLng,
        southwestLat,
        southwestLng
      );
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

  app.get("/club/getclub", async (req, res) => {
    try {
      const { id } = req.query;
      const response = await clubController.getClub(id);
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
      id,
      nombre,
      descripcion,
      latitud,
      longitud,
      id_deporte,
      logo,
      correo,
      telefono,
      categorias,
      tipos,
      facebook,
      instagram,
      tiktok,
      id_usuario,
    } = req.body;
    try {
      const response = await clubController.createClub(
        id,
        nombre,
        descripcion,
        latitud,
        longitud,
        id_deporte,
        logo,
        correo,
        telefono,
        categorias,
        tipos,
        id_usuario,
        facebook,
        instagram,
        tiktok
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

  app.get("/club/getmiembros", async (req, res) => {
    const { id_club } = req.query;
    try {
      const response = await clubController.getMiembros(id_club);
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

  app.delete("/club/deletemiembro", async (req, res) => {
    const { id_club, id_usuario } = req.body;
    try {
      const response = await clubController.expulsarMiembros(
        id_club,
        id_usuario
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

  app.put("/club/editclub", async (req, res) => {
    const {
      id,
      nombre,
      descripcion,
      latitud,
      longitud,
      id_deporte,
      logo,
      correo,
      telefono,
      categorias,
      tipos,
      facebook,
      instagram,
      tiktok,
    } = req.body;
    try {
      const response = await clubController.editClub(
        id,
        nombre,
        descripcion,
        latitud,
        longitud,
        id_deporte,
        logo,
        correo,
        telefono,
        categorias,
        tipos,
        facebook,
        instagram,
        tiktok
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

  app.patch("/club/updateImage", async (req, res) => {
    const { id, imagen } = req.body;
    try {
      const response = await clubController.editImagenClub(id, imagen);
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
