const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const id_club = 87;
describe("Test de Obtener Equipos de un Club", () => {
  it("Obtener todos los equipos de un club especifico", async () => {
    const response = await api
      .get("/equipo/getEquipos")
      .query({ id_club: id_club });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
  it("Obtener un equipo no valido", async () => {
    const response = await api.get("/equipo/getEquipos").query({ id_club: 1 });

    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Object);
    expect(response.body.data.length).toBe(0);
  });
});

// TODO: GETEQUIPBYUSER
describe("Test de Obtener Equipos de un Usuario", () => {
  it("Obtener todos los equipos de un usuario especifico", async () => {
    const response = await api
      .get("/equipo/getEquiposByUser")
      .query({ id_usuario: 34, id_club: id_club });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  }); /*
  it("Obtener un usuario no valido", async () => {
    const response = await api
      .get("/equipo/getEquiposUsuario")
      .query({ id_usuario: 1 });

    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Object);
    expect(response.body.data.length).toBe(0);
  });*/
});

describe("Test de Crear Equipos", () => {
  it("Crear un equipo", async () => {
    const response = await api.post("/equipo/createEquipo").send({
      nombre: "Equipo de prueba",
      id_club: id_club,
    });
    expect(response.statusCode).toBe(201);
  });
  it("Crear un equipo con datos invalidos", async () => {
    const response = await api.post("/equipo/createEquipo").send({
      nombre: "",
      id_club: 1,
    });
    expect(response.statusCode).toBe(500);
  });
});
// TODO: GETEQUIPBYID

afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
