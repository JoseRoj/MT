const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const id_club = 111; // Club Tenis
const rol = "Deportista";

const user = {
  nombre: "Kristo",
  apellido1: "Chandia",
  apellido2: "Garcia",
  email: "kristo@gmail.com",
  contrasena: "1234",
  telefono: "987654321",
  fecha_nacimiento: "2021-01-01",
  genero: "Masculino",
  imagen: "",
};

describe("Test Secuencia - Solicitud - Miembro", () => {
  let id_usuario;

  it("Enviar solicitud y comprobar estado", async () => {
    const responseUser = await api.post("/usuarios/create").send(user);
    id_usuario = Number(responseUser.body.data.user.id);
    console.log("Response User", responseUser.body);
    const responseSolicitud = await api.post("/solicitud/send").send({
      id_usuario: id_usuario,
      id_club: id_club,
    });
    expect(responseSolicitud.statusCode).toBe(201);
    const responsestadoSolicitudes = await api.get("/solicitud/getEstado").query({
      id_usuario: id_usuario,
      id_club: id_club,
    });
    expect(responsestadoSolicitudes.statusCode).toBe(200);
    expect(responsestadoSolicitudes.body.data[0].estado).toBe("Pendiente");
  });

  it("Obtener Solicitudes", async () => {
    const response = await api.get("/solicitud/getPendientes").query({
      id_club: id_club,
    });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
  });

  it("Aceptar al usuario y agregarlo a un equipo del club", async () => {
    const response = await api.post("/miembro/assignMiembro").send({
      id_club: id_club,
      equipos: [96],
      id_usuario: id_usuario,
      rol: rol,
    });
    expect(response.statusCode).toBe(200);
    expect(response.body.message).toBe("Solicitud aceptada con éxito");
  });

  it("Eliminar miembro del Equipo", async () => {
    const response = await api.delete("/miembro/deleteMiembroEquipo").send({
      id_equipo: 96,
      id_usuario: id_usuario,
    });
    expect(response.statusCode).toBe(200);
    expect(response.body.message).toBe("Miembro eliminado con éxito");
  });
});

afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
/*
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
*/
