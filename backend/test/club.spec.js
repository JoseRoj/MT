const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const club = {
  nombre: "Club Test",
  descripcion: "Agregando un Club de Testing",
  latitud: 0,
  longitud: 0,
  id_deporte: 1,
  logo: "",
  correo: "corretest@gmail.com",
  telefono: "987654321",
  categorias: [1, 2],
  tipos: [1, 2],
  id_usuario: 34,
};

const clubEdit = {
  nombre: "Nueva Prueba",
  descripcion: "Nueva Descricion",
  latitud: 90,
  longitud: 180,
  id_deporte: 2,
  logo: "ASFDSDOSIJIO232",
  correo: "nuevocorre@gmail.com",
  telefono: "976543765",
  categorias: [1, 2, 3],
  tipos: [1, 2, 3],
  facebook: "https://Nuevoclub.com",
  instagram: "https://Nuevoclub.com",
  tiktok: "https://Nuevoclub.com",
};

const deportes = [1, 2, 3, 4];
const coordenada = -73.020855858922 - 73.05304236710072;

const idValido = 110;

describe("Test Clubes", () => {
  let idClub;

  describe("Test - Obtener Clubes con filtros ( Deportes , Coordenadas ) ", () => {
    it("Obtener todos los Clubes", async () => {
      const response = await api.get("/club/getclubs").send({
        deportes: deportes,
        northeastLat: -36.80786306470817,
        northeastLng: -73.020855858922,
        southwestLat: -36.84922148848782,
        southwestLng: -73.05304236710072,
      });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });
  describe("Test - Crear Club", () => {
    it("Crear un club", async () => {
      const response = await api.post("/club").send(club);
      idClub = response.body.data;
      expect(response.statusCode).toBe(200);
    });
    it("Crear un club con un correo o nombre ya existente", async () => {
      const response = await api.post("/club").send({
        ...club,
      });
      expect(response.statusCode).toBe(400);
    });
  });
  describe("Test - Obtener informacion Club", () => {
    it("Obtener un Club Válido", async () => {
      const response = await api.get("/club/getclub").query({ id: idClub });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Object);
    });
    it("Obtener un Club Invalido", async () => {
      const response = await api.get("/club/getclub").query({ id: 0 });
      expect(response.statusCode).toBe(400);
    });
  });

  describe("Test - Obtener Miembros Club", () => {
    it("Obtener Miembros de un Club", async () => {
      const response = await api.get("/club/getmiembros").query({ id_club: idValido });
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });

  describe("Test - Editar Informacion Club", () => {
    it("Editar Informacion del Club", async () => {
      const response = await api.put("/club/editClub").send({ ...clubEdit, id: idClub });
      expect(response.statusCode).toBe(200);
      expect(response.body.message).toBe("Club actualizado con éxito");
    });
  });
  // TODO : GETmiembros
});

afterAll(() => {
  connectionPostgres.end();
  server.close();
});
