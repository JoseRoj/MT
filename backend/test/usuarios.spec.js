const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const user = {
  id: Math.floor(Math.random() * 1000) + 1,
  nombre: "Nombre",
  apellido1: "Apellido1",
  apellido2: "Apellido2",
  email: "pruebauser@gmail.com",
  contrasena: "1234",
  telefono: "987654321",
  fecha_nacimiento: "2021-01-01",
  genero: "Masculino",
  imagen: "",
};

const id_usuario_admin = 33;
const id_club = 87;
const id_usuario_no_admin = 34;
const id_usuario_no_club = 35;
/*
describe("Test Crear Usuario", () => {
  it("Crear un usuario", async () => {
    const response = await api.post("/usuarios/create").send(user);
  });
  it("Crear un usuario con datos invalidos", async () => {
    const response = await api
      .post("/usuarios/create")
      .send({ ...user, nombre: "" });
    expect(response.statusCode).toBe(400);
  });
});
*/
describe("Test Obtener Usuarios", () => {
  it("Obtener usuario valido", async () => {
    const response = await api
      .get("/usuarios/getUser")
      .query({ id: id_usuario_admin });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Object);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
  it("Obtener un usuario no valido", async () => {
    const response = await api.get("/usuarios/getUser").query({ id: 0 });
    expect(response.statusCode).toBe(400);
    expect(response.body.message).toBe("Usuario no encontrado");
  });
});

describe("Test Obtener Rol Administrador", () => {
  it("Obtener rol de un administrador", async () => {
    const response = await api
      .get("/usuarios/rol")
      .query({ id_usuario: id_usuario_admin, id_club: id_club });
    console.log(response.body);
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBe("Administrador");
  });

  it("Obtener rol de una persona que no es administrador", async () => {
    const response = await api
      .get("/usuarios/rol")
      .query({ id_usuario: id_usuario_no_admin, id_club: id_club });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBe("");
    expect(response.body.message).toBe("No existe información");
  });
});
// TODO: Realizar este caso mas en profundidad que traiga todos los clibes a los que esta un usuario

describe("Test ClubesUser", () => {
  it("Obtener clubes de un usuario", async () => {
    const response = await api
      .get("/usuarios/getclubesUser")
      .query({ id_usuario: id_usuario_admin });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
  it("Obtener clubes de un usuario que no tiene", async () => {
    const response = await api
      .get("/usuarios/getclubesUser")
      .query({ id_usuario: id_usuario_no_club });
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBe(0);
  });
});
afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
