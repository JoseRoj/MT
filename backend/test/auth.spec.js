const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Test de Authentificacion", () => {
  test("Autentificacion con credenciales Correctas", async () => {
    const response = await api.post("/login").send({
      email: "joserojas@gmail.com",
      contrasena: "1234",
    });
    expect(response.statusCode).toBe(200);
  });
  test("Autentificacion con credenciales Incorrectas", async () => {
    const response = await api.post("/login").send({
      email: "joseroja2s@gmail.com",
      contrasena: "12324",
    });
    expect(response.statusCode).toBe(401);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
