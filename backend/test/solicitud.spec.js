const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const id_usuario = 34;
const id_club = 87;

describe("Test de Envio Solicitud", () => {
  it("Enviar solicitud y comprobar estado", async () => {
    const responseSolicitud = await api.post("/solicitud/send").send({
      id_usuario: id_usuario,
      id_club: id_club,
    });
    expect(responseSolicitud.statusCode).toBe(200);
    const responsestadoSolicitudes = await api
      .get("/solicitud/getEstado")
      .query({
        id_usuario: id_usuario,
        id_club: id_club,
      });
    expect(responsestadoSolicitudes.statusCode).toBe(200);
    expect(responsestadoSolicitudes.body.data[0].estado).toBe("Pendiente");
  });
});
describe("Actualizar Estado Solicitud", () => {
  it("Actualizar estado de solicitud", async () => {
    const estado = "Aceptada";
    const response = await api.patch("/solicitud").send({
      id_usuario: id_usuario,
      id_club: id_club,
      estado: estado,
    });
    expect(response.statusCode).toBe(200);
    const responseEstadoSolicitud = await api
      .get("/solicitud/getEstado")
      .query({
        id_usuario: id_usuario,
        id_club: id_club,
      });
    expect(responseEstadoSolicitud.body.data[0].estado).toBe(estado);
  });
});

describe("Obtener Solicitudes pendientes de un club", () => {
  it("Obtener Solicitudes", async () => {
    const response = await api.get("/solicitud/getPendientes").query({
      id_club: id_club,
    });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
