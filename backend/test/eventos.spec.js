const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Test obtener Eventos de un equipo", () => {
  describe("Obtener Eventos de un equipo CON Eventos", () => {
    it("Obtener Todos los Eventos", async () => {
      const response = await api.get("/eventos").query({
        id_equipo: 24,
        estado: "Todos",
      });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
    });
    it("Obtener Eventos Activos", async () => {
      const response = await api.get("/eventos").query({
        id_equipo: 24,
        estado: "Activo",
      });
      for (res of response.body.data) {
        expect(res.evento.estado).toBe("Activo");
      }
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
    it("Obtener Eventos Terminados", async () => {
      const response = await api.get("/eventos").query({
        id_equipo: 24,
        estado: "Terminado",
      });
      for (res of response.body.data) {
        expect(res.evento.estado).toBe("Terminado");
      }
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
    });
  });
  describe("Obtener Eventos de un equipo SIN Eventos", () => {
    it("Obtener Eventos", async () => {
      const response = await api.get("/eventos").query({
        id_equipo: 1000000,
        estado: "Todos",
      });

      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBe(0);
    });
  });

  /*test("Autentificacion con credenciales Incorrectas", async () => {
    const response = await api.post("/login").send({
      email: "joseroja2s@gmail.com",
      contrasena: "12324",
    });
    expect(response.statusCode).toBe(401);
  });*/
});

describe("Test Crear Evento", () => {
  it("Crear solo 1 Evento", async () => {
    const response = await api.post("/eventos").send({
      fechas: ["2022-09-01"],
      id_equipo: 24,
      descripcion: "Evento de prueba",
      horaInicio: "10:00",
      horaFin: "12:00",
      titulo: "Evento de prueba",
    });
    expect(response.statusCode).toBe(201);
    expect(response.body.data).toBeInstanceOf(Object);
  });
  it("Crear varios Eventos", async () => {
    const response = await api.post("/eventos").send({
      fechas: ["2022-09-01", "2022-09-02", "2022-09-03"],
      id_equipo: 24,
      descripcion: "Evento de prueba",
      horaInicio: "10:00",
      horaFin: "12:00",
      titulo: "Evento de prueba",
    });
    expect(response.statusCode).toBe(201);
    expect(response.body.data).toBeInstanceOf(Object);
  });
});

afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
