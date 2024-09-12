const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const user = {
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

const id_club = 110;
const id_equipo = 88;

const id_usuario_admin = 33;
const id_usuario_no_admin = 34;

const id_usuario_no_club = 1;
/*

*/
describe("Test - Usuarios", () => {
  let id_usuario;

  describe("Crear Usuario", () => {
    it("Crear un usuario", async () => {
      const response = await api.post("/usuarios/create").send(user);
      id_usuario = response.body.data;
      expect(response.statusCode).toBe(201);
    });

    it("Crear un usuario con datos invalidos", async () => {
      const response = await api.post("/usuarios/create").send({ ...user, nombre: "" });
      expect(response.statusCode).toBe(400);
    });
  });

  describe("Obtener Usuarios", () => {
    it("Obtener usuario valido", async () => {
      const response = await api.get("/usuarios/getUser").query({ id: id_usuario });
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

  describe("Test Rol de un Usuario", () => {
    it("Obtener rol de un administrador", async () => {
      const response = await api.get("/usuarios/rol").query({ id_usuario: id_usuario_admin, id_club: id_club, id_equipo: id_equipo });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBe("Administrador");
    });
    it("Obtener rol de un Deportista", async () => {
      const response = await api.get("/usuarios/rol").query({ id_usuario: id_usuario_no_admin, id_club: id_club, id_equipo: id_equipo });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBe("Deportista");
    });

    it("Obtener rol de una persona que no pertenece al equipo", async () => {
      const response = await api.get("/usuarios/rol").query({ id_usuario: id_usuario_no_admin, id_club: id_club });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBe("");
      expect(response.body.message).toBe("No existe información");
    });
  });

  // TODO: Realizar este caso mas en profundidad que traiga todos los clibes a los que esta un usuario

  describe("Test Obtener los clubes de un Usuario", () => {
    it("Obtener clubes de un usuario", async () => {
      const response = await api.get("/usuarios/getclubesUser").query({ id_usuario: id_usuario_admin });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
    it("Obtener clubes de un usuario que no tiene o no existe el usuario", async () => {
      const response = await api.get("/usuarios/getclubesUser").query({ id_usuario: id_usuario_no_club });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBe(0);
    });
  });

  describe("Test Estadisticas de un Usuario", () => {
    it("Obtener Estadisticas de un usuario con estadisticas", async () => {
      const response = await api.get("/usuarios/stadistic").query({ id_usuario: id_usuario_no_admin, id_equipo: id_equipo });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
    it("Obtener Estadisticas de un usuario que no tiene o no existe el usuario", async () => {
      const response = await api.get("/usuarios/stadistic").query({ id_usuario: id_usuario_no_club, id_equipo: id_equipo });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBe(0);
      expect(response.body.message).toBe("Estadísticas no encontradas");
    });
  });
});

afterAll(async () => {
  await connectionPostgres.end();
  server.close();
});
