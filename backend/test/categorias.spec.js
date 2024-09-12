const request = require("supertest");
const { app, server } = require("../app"); // Asegúrate de que `server` esté exportado correctamente
const api = request(app);
const connectionPostgres = require("../database/db");

test("Obtener todas las categorías", async () => {
  const response = await api
    .get("/getCategorias")
    .send({
      email: "joserojas@gmail.com",
      contrasena: "1234",
    })
    .set("Authorization", process.env.TOKEN);

  expect(response.statusCode).toBe(200);
  expect(response.body.data).toBeInstanceOf(Array);
  expect(response.body.data.length).toBeGreaterThan(0);
});

afterAll(async () => {
  connectionPostgres.end();
  server.close();
});
