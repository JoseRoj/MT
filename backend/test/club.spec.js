const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const club = {
  id: Math.floor(Math.random() * 1000) + 1,
  nombre: "Club de prueba",
  descripcion: "Club de prueba",
  latitud: 0,
  longitud: 0,
  id_deporte: 1,
  logo: "",
  correo: "correopueba@gmail.com",
  telefono: "987654321",
  categorias: [1, 2],
  tipos: [1, 2],
  id_usuario: 34,
};

const deportes = [1, 2, 3, 4];

describe("Test Obtener Clubes", () => {
  it("Obtener todos los clubes", async () => {
    const response = await api.get("/club/getclubs").send({ deportes });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
  describe("Test Crear Club", () => {
    it("Crear un club", async () => {
      const response = await api.post("/club").send(club);
      expect(response.statusCode).toBe(200);
    });
    it("Crear un club con datos invalidos", async () => {
      const response = await api.post("/club").send({
        ...club,
        nombre: "",
        id: Math.floor(Math.random() * 10000),
      });
      expect(response.statusCode).toBe(400);
    });
  });

  it("Obtener un club valido", async () => {
    const response = await api.get("/club/getclub").query({ id: club.id });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Object);
  });
  it("Obtener un club invalido", async () => {
    const response = await api.get("/club/getclub").query({ id: 0 });
    expect(response.statusCode).toBe(400);
  });

  // TODO : GETmiembros
});

afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
