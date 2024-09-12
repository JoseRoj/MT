const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Test de Deportes", () => {
  it("Obtener todos los deportes", async () => {
    const response = await api.get("/getDeportes").send().set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
