<template>
  <div class="reportes-container">
    <h1>📊 Reportes</h1>

    <button class="reportes-button" @click="cargarResumen">
      Cargar resumen diario
    </button>

    <div v-if="resumen" class="reportes-cards">
      <div class="reportes-card">
        <h3>Ventas</h3>
        <p class="reportes-number">{{ resumen.ventas_cantidad }}</p>
      </div>

      <div class="reportes-card">
        <h3>Total dinero</h3>
        <p class="reportes-number">
          {{ formatCurrency(resumen.total_dinero) }}
        </p>
      </div>
    </div>

    <div class="reportes-section">
      <h2>🥇 Top productos</h2>
      <button class="reportes-button" @click="cargarTop">Cargar top</button>

      <div v-if="topProductos && topProductos.length" class="reportes-card">
        <ul>
          <li v-for="(p, index) in topProductos" :key="index">
            <strong>#{{ index + 1 }}</strong> - {{ p.nombre }} ({{
              p.total_unidades
            }}
            ventas)
          </li>
        </ul>
      </div>
    </div>

    <div class="reportes-section">
      <h2>📅 Ventas por rango</h2>
      <input type="date" v-model="inicio" />
      <input type="date" v-model="fin" />
      <button class="reportes-button" @click="cargarRango">Buscar</button>
    </div>

    <table v-if="ventas.length" class="reportes-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Fecha</th>
          <th>Total</th>
          <th>Cajero</th>
          <th>Cliente</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="v in ventas" :key="v.id">
          <td>{{ v.id }}</td>
          <td>{{ new Date(v.fecha_hora).toLocaleString() }}</td>
          <td>{{ formatCurrency(v.total) }}</td>
          <td>{{ v.cajero }}</td>
          <td>{{ v.cliente }}</td>
        </tr>
      </tbody>
    </table>

    <p v-if="ventas.length === 0 && inicio && fin" class="reportes-empty">
      No hay ventas en ese rango
    </p>

    <div class="reportes-section">
      <h2>💰 Reporte de Facturación</h2>
      <input type="date" v-model="inicioFact" />
      <input type="date" v-model="finFact" />
      <button class="reportes-button" @click="cargarFacturacion">
        Buscar facturas
      </button>

      <table v-if="facturas.length" class="reportes-table">
        <thead>
          <tr>
            <th>Nro Factura</th>
            <th>Fecha</th>
            <th>Cliente</th>
            <th>NIT/CI</th>
            <th>Total Factura</th>
            <th>Detalle</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="f in facturas" :key="f.factura_nro">
            <td>{{ f.factura_nro }}</td>
            <td>{{ new Date(f.fecha_hora).toLocaleString() }}</td>
            <td>{{ f.cliente }}</td>
            <td>{{ f.nit_ci }}</td>
            <td>{{ formatCurrency(f.total_factura) }}</td>
            <td>
              <button @click="verFacturaDetalle(f.factura_nro)">
                Ver detalle
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <p v-if="facturas.length === 0 && inicioFact && finFact">
        No hay facturas en ese rango
      </p>
    </div>

    <div v-if="facturaDetalle" class="modal">
      <div class="modal-content">
        <h3>Factura #{{ facturaDetalle.nro_factura }}</h3>
        <p>
          Cliente: {{ facturaDetalle.cliente_nombre }} ({{
            facturaDetalle.cliente_ci
          }})
        </p>
        <p>Cajero: {{ facturaDetalle.cajero }}</p>
        <p>Fecha: {{ new Date(facturaDetalle.fecha_hora).toLocaleString() }}</p>

        <table class="reportes-table">
          <thead>
            <tr>
              <th>Producto</th>
              <th>Cantidad</th>
              <th>Precio Unitario</th>
              <th>Subtotal</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in facturaDetalle.items" :key="item.producto">
              <td>{{ item.producto }}</td>
              <td>{{ item.cantidad }}</td>
              <td>{{ formatCurrency(item.precio_unitario) }}</td>
              <td>{{ formatCurrency(item.subtotal) }}</td>
            </tr>
          </tbody>
        </table>

        <p>
          <strong>Total: {{ formatCurrency(facturaDetalle.total) }}</strong>
        </p>
        <button class="reportes-button" @click="facturaDetalle = null">
          Cerrar
        </button>
      </div>
    </div>

    <div v-if="mostrarModal" class="modal">
      <div class="modal-content">
        <p>{{ mensajeModal }}</p>
        <button class="reportes-button" @click="mostrarModal = false">
          Cerrar
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import {
  getResumenDiario,
  getTopProductos,
  getVentasPorRango,
  getReporteFacturacion,
  getFacturaDetalle,
  getConfigLocal,
} from "../services/api";
import { getCurrencySymbol } from "../utils/currency";
import "../assets/styles/reportes.css";

export default {
  name: "Reportes",

  data() {
    return {
      resumen: null,
      topProductos: null,
      ventas: [],
      inicio: "",
      fin: "",

      facturas: [],
      inicioFact: "",
      finFact: "",
      facturaDetalle: null,

      mensajeModal: "",
      mostrarModal: false,

      config: null,
    };
  },

  mounted() {
    this.cargarConfig();
    this.cargarResumen();
    this.cargarTop();
    this.cargarRangoDiario();
    this.cargarFacturasDiario();
  },

  methods: {
    mostrarMensaje(msg) {
      this.mensajeModal = msg;
      this.mostrarModal = true;
    },

    formatCurrency(value) {
      if (!this.config || !this.config.moneda) return value.toFixed(2);
      const symbol = getCurrencySymbol(this.config.moneda);
      return `${symbol} ${Number(value).toFixed(2)}`;
    },

    async cargarConfig() {
      const data = await getConfigLocal();
      if (data.length > 0) this.config = data[0];
    },

    async cargarResumen() {
      this.resumen = await getResumenDiario();
    },

    async cargarTop() {
      this.topProductos = await getTopProductos();
    },

    async cargarRango() {
      if (!this.inicio || !this.fin) {
        this.mostrarMensaje("Selecciona ambas fechas");
        return;
      }
      this.ventas = await getVentasPorRango(this.inicio, this.fin);
    },

    async cargarFacturacion() {
      if (!this.inicioFact || !this.finFact) {
        this.mostrarMensaje("Selecciona ambas fechas para facturación");
        return;
      }
      this.facturas = await getReporteFacturacion(
        this.inicioFact,
        this.finFact,
      );
    },

    async verFacturaDetalle(id) {
      this.facturaDetalle = await getFacturaDetalle(id);
    },

    async cargarRangoDiario() {
      const hoy = new Date().toLocaleDateString("en-CA");
      this.inicio = hoy;
      this.fin = hoy;
      this.ventas = await getVentasPorRango(this.inicio, this.fin);
    },

    async cargarFacturasDiario() {
      const hoy = new Date().toLocaleDateString("en-CA");
      this.inicioFact = hoy;
      this.finFact = hoy;
      this.facturas = await getReporteFacturacion(
        this.inicioFact,
        this.finFact,
      );
    },
  },
};
</script>
