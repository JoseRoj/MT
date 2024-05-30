const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const id_club = 87;
const id_usuario = 34;
const rol = "Deportista";

describe("Test de Miembros", () => {
  it("Asignar miembro a un club", async () => {
    const response = await api.post("/miembro/assignMiembro").send({
      id_club: id_club,
      equipos: [24],
      id_usuario: id_usuario,
      rol: rol,
    });
    expect(response.statusCode).toBe(200);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
