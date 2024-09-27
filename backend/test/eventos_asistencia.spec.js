const request = require("supertest");
const { app, server } = require("../app");
const api = request(app);
const connectionPostgres = require("../database/db");
const estados = require("../global");
const event = {
  fechas: ["2024-09-30"],
  id_equipo: 88,
  descripcion: "Evento de prueba",
  horaInicio: "10:00",
  horaFin: "12:00",
  lugar: "Cancha Nueva",
  titulo: "Evento de prueba",
  id_club: 110,
};

const paremetersGetEventos = {
  id_equipo: 88,
  estado: "Activo",
  initialDate: "2024-09-01",
  month: 9,
  year: 2024,
};

const id_miembroEquipo = 34;
describe("Test Secuencia Evento - Asistencia ", () => {
  let idEvento;
  describe("Test Crear Evento", () => {
    it("Crear Evento Evento", async () => {
      const response = await api.post("/eventos").send(event);
      idEvento = response.body.data;
      console.log("idEvento ", idEvento);
      expect(response.statusCode).toBe(201);
    });

    describe("Test Asistencia", () => {
      it("Confirmar Asitencia a Evento", async () => {
        const response = await api.post("/asistencia").send({
          id_usuario: id_miembroEquipo,
          id_evento: idEvento,
        });
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe("Asistencia confirmada con éxito");
      });

      it("Cancelar Asitencia a Evento", async () => {
        const response = await api.delete("/asistencia").send({
          id_usuario: id_miembroEquipo,
          id_evento: idEvento,
        });
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe("Asistencia cancelada con éxito");
      });
    });

    describe("Test Actualizar estado evento", () => {
      it("Finalizar Evento", async () => {
        const response = await api.patch("/eventos/estado").send({
          id_evento: idEvento,
          estado: estados.finalizado,
        });
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe("Evento Actualizado");
      });

      it("Activar Evento", async () => {
        const response = await api.patch("/eventos/estado").send({
          id_evento: idEvento,
          estado: estados.activo,
        });
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe("Evento Actualizado");
      });
    });

    describe("Test Actualizar Información General de un Evento", () => {
      it("Actualizar Evento", async () => {
        const response = await api.put("/eventos").send({
          id_evento: idEvento,
          fecha: event.fechas[0],
          descripcion: event.descripcion,
          horaInicio: event.horaInicio,
          horaFin: event.horaFin,
          lugar: event.lugar,
          asistentes: [],
          titulo: "Editar Titulo",
        });
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe("Actualizado con éxito");
      });
    });

    describe("Test Obtener Eventos", () => {
      it("Obtener, Confirmar creación del eventos y edición del Evento", async () => {
        const response = await api.get("/eventos").query(paremetersGetEventos);
        const isEvent = response.body.data.find((event) => event.evento.id == idEvento);
        const exist = isEvent ? true : false;
        expect(true).toBe(exist);
        expect(response.body.data).toBeInstanceOf(Array);
        expect(response.body.data.length).toBeGreaterThan(0);
      }, 10000);

      it("Obtener eventos en una fecha sin registros", async () => {
        const response = await api.get("/eventos").query({ ...paremetersGetEventos, year: 2040 });
        expect(response.body.data).toBeInstanceOf(Array);
        expect(response.body.data.length).toBe(0);
      });
    });

    describe("Test Eliminar Evento", () => {
      it("Eliminar Evento", async () => {
        const response = await api.delete("/eventos").send({
          id_evento: idEvento,
        });
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe("Eliminado con éxito");
      });
    });
  });
});

afterAll(() => {
  connectionPostgres.end();
  server.close();
});
