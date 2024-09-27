const request = require("supertest");
const { Pool } = require("pg");
const { app, server } = require("../app"); // Asegúrate de que `server` esté exportado correctamente
const api = request(app);
const connectionPostgres = require("../database/db");

describe("Test de authentificacion", () => {
  test("Autenticación con credenciales correctas", async () => {
    const response = await api.post("/login").send({
      email: "joserojas@gmail.com",
      contrasena: "1234",
    });
    expect(response.statusCode).toBe(200);
  });

  test("Autenticación con credenciales incorrectas", async () => {
    const response = await api.post("/login").send({
      email: "joseroja2s@gmail.com",
      contrasena: "12324",
    });
    expect(response.statusCode).toBe(401);
  });
});

test("Test de actualizacion Token Firebase", async () => {
  const response = await api.patch("/token").send({
    id_usuario: 33,
    token_fb: "dse8_5uZThGzM163ya3Kzo:APA91bFhq1hpxH0zjrMRx182PMIg5BaxcjAl3mji9Gs1zHcLbLKhivZw53xpqqoIbH4wxm2uHYNkxUUzQ1sgiLyJUTP87XCHmZL3yBX4tCbbV-PfquR2qSKUgkiTkX1ZRYzxj1kThPvT",
  });
  expect(response.statusCode).toBe(200);
});

afterAll(() => {
  connectionPostgres.end();
  server.close(); // Llama a `done` cuando el servidor se haya cerrado
});
