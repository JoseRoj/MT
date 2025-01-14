const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Test de Tipos de clubes", () => {
  it("Obtener todos los tipos de clubes", async () => {
    const response = await api.get("/getTipos").send();
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBe(3);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
