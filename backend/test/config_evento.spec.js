const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");

const configEventoRecurrente = {
  fecha_inicio: "2024-10-01 00:00:00.000",
  fecha_final: "2024-10-15 00:00:00.000",
  hora_inicio: "10:30:00",
  hora_final: "13:00:00",
  id_equipo: 96,
  titulo: "Evento Prueba",
  descripcion: "Evento de prueba de configuracion",
  lugar: "Gimnasio Municipal",
  dia_repetible: 2, // cada martes.
};

describe("Test - Eventos Recurrentes", () => {
  let id_config;
  describe("Test - Crear Eventos Recurrentes", () => {
    it("Crear Evento Recurrentes en fechas validas", async () => {
      const response = await api.post("/configEvento").send(configEventoRecurrente).set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
      id_config = response.body.data;
      expect(response.statusCode).toBe(201);
      expect(response.body.message).toBe("Configuración de evento creada con éxito");
    });
    it("Crear Evento Recurrentes en fechas sin opcion de crear Eventos", async () => {
      const response = await api
        .post("/configEvento")
        .send({ ...configEventoRecurrente, fecha_inicio: "2024-10-03 00:00:00.000", fecha_final: "2024-10-06 00:00:00.000" })
        .set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe("No se encontraron fechas en las que se repetirá el evento");
    });
  });
  describe("Test -  Obtener Configuración Evento Recurrente", () => {
    it("Obtener Eventos Recurrentes y comprobar que esta la configuracion creada", async () => {
      const response = await api.get("/configEventos").query({ id_equipo: 96 }).set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
      // Comprobar que se encuentra el evento creado
      console.log("Resp", response.body.data);
      const event = response.body.data.find((item) => item.id === id_config);

      expect(event.id).toBe(id_config);
      expect(response.statusCode).toBe(200);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });

  describe("Test -  Eliminar Configuración Evento Recurrente", () => {
    it("Eliminar Configuración Evento Recurrente ", async () => {
      const response = await api.delete("/configEvento").query({ id_config: id_config }).set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
      expect(response.statusCode).toBe(200);
      expect(response.body.message).toBe("Se ha eliminado con éxito");
    });
    it("Eliminar Configuración y Ocurre un error", async () => {
      const response = await api.delete("/configEvento").query({ id_config: id_config }).set("Authorization", process.env.TOKEN); // Establece el encabezado Authorization
      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe("No se logró eliminar esta Configuración");
    });
  });
});
afterAll(() => {
  connectionPostgres.end();
  server.close();
});
