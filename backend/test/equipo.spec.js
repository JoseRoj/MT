const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const idValido = 110;
const idEquipoValido = 88;
const idNotValid = 0;

describe("Test -  Equipos", () => {
  let idEquipo;
  describe("Test -  Obtener Equipos de un Club", () => {
    it("Obtener todos los equipos de un Club con equipos", async () => {
      const response = await api.get("/equipo/getEquipos").query({ id_club: idValido });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });

    it("Obtener un equipo no valido", async () => {
      const response = await api.get("/equipo/getEquipos").query({ id_club: idNotValid });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Object);
      expect(response.body.data.length).toBe(0);
    });
  });

  describe("Test - Obtener Equipos de un Usuario por Club", () => {
    it("Obtener todos los equipos de un usuario especifico", async () => {
      const response = await api.get("/equipo/getEquiposByUser").query({ id_usuario: 34, id_club: idValido });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });

  describe("Test - Crear Equipos", () => {
    it("Crear un equipo", async () => {
      const response = await api.post("/equipo/createEquipo").send({
        nombre: "Equipo de prueba",
        id_club: 111,
      });
      idEquipo = response.body.data;
      expect(response.statusCode).toBe(201);
    });
  });

  describe("Test - Eliminar Equipo", () => {
    it("Eliminar equipo existente", async () => {
      const response = await api.delete("/equipo/deleteEquipo").query({ id_equipo: idEquipo });
      expect(response.statusCode).toBe(200);
      expect(response.body.message).toBe("Equipo eliminado correctamente");
    });
    it("Eliminar equipo no existente", async () => {
      const response = await api.delete("/equipo/deleteEquipo").query({ id_equipo: idEquipo + 100000 });
      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe("Este equipo no existe");
    });
  });

  describe("Test - Obtener Estadisticas", () => {
    it("Obtener Estadisticas de un equipo", async () => {
      const response = await api.get("/equipo/stadistic").query({ fecha_inicio: "2024-08-22", id_equipo: 88, id_club: 110, fecha_final: "2024-08-31" });
      expect(response.statusCode).toBe(200);
      expect(response.body.data["eventos"].length).toBeGreaterThan(0);
      expect(response.body.data["userList"].length).toBeGreaterThan(0);
      expect(response.body.data["recurrentes"].length).toBeGreaterThan(0);
    });

    it("Obtener Estadisticas de un equipo no existente o sin estadisticas", async () => {
      const response = await api.get("/equipo/stadistic").query({ fecha_inicio: "2024-08-22", id_equipo: idEquipo, id_club: 110, fecha_final: "2024-08-31" });
      expect(response.statusCode).toBe(200);
      expect(response.body.data["eventos"].length).toBe(0);
      expect(response.body.data["userList"].length).toBe(0);
      expect(response.body.data["recurrentes"].length).toBe(0);
    });
  });

  describe("Test - Miembros Equipo", () => {
    it("Obtener Miembros del equipo", async () => {
      const response = await api.get("/equipo/miembros").query({ id_equipo: idEquipo });
      expect(response.statusCode).toBe(200);
    });
    it("Obtener equipos de un equipo si no existe o no tiene miembros", async () => {
      const response = await api.get("/equipo/miembros").query({ id_equipo: idEquipo + 100000 });
      expect(response.statusCode).toBe(200);
      expect(response.body.data.length).toBe(0);
    });
  });
});

afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
