const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Test de Categorias", () => {
  it("Obtener todas las categorias", async () => {
    const response = await api.get("/getCategorias").send({
      email: "joserojas@gmail.com",
      contrasena: "1234",
    });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
