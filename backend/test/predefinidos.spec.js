const request = require("supertest");
const { app, server } = require("../app"); // Asegúrate de que `server` esté exportado correctamente
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Obtener Valores Predefinidos en la BD", () => {
  it("Obtener Tipos de Clubes", async () => {
    const response = await api.get("/getTipos").send().set("Authorization", process.env.TOKEN);
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBe(3);
  });
  it("Obtener Categorias predefinidas", async () => {
    const response = await api.get("/getCategorias").set("Authorization", process.env.TOKEN);
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
  it("Obtener todos los Deportes predefinidos", async () => {
    const response = await api.get("/getDeportes").send().set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data.length).toBeGreaterThan(0);
  });
});

afterAll(() => {
  connectionPostgres.end();
  server.close();
});
