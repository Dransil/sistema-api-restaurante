<template>
  <div class="reportes-container">

    <!-- Encabezado -->
    <div class="reportes-header">
      <div>
        <h2 class="title">Reportes y Estadísticas</h2>
        <p class="subtitle">Panel de control de ventas</p>
      </div>
    </div>

    <!-- ── Tarjetas resumen diario ── -->
    <div class="resumen-grid">
      <div class="resumen-card card-ventas">
        <div class="resumen-icon"><i class="fas fa-receipt"></i></div>
        <div class="resumen-info">
          <p class="resumen-label">Ventas Hoy</p>
          <h3 class="resumen-valor">{{ resumenDiario.ventas_cantidad ?? '—' }}</h3>
        </div>
      </div>
      <div class="resumen-card card-dinero">
        <div class="resumen-icon"><i class="fas fa-coins"></i></div>
        <div class="resumen-info">
          <p class="resumen-label">Total Recaudado</p>
          <h3 class="resumen-valor">{{ moneda }} {{ Number(resumenDiario.total_dinero ?? 0).toFixed(2) }}</h3>
        </div>
      </div>
      <div class="resumen-card card-top">
        <div class="resumen-icon"><i class="fas fa-star"></i></div>
        <div class="resumen-info">
          <p class="resumen-label">Producto Top</p>
          <h3 class="resumen-valor">{{ topProductos[0]?.nombre ?? '—' }}</h3>
        </div>
      </div>
    </div>

    <!-- ── Filtro por rango ── -->
    <div class="filtro-card">
      <h5 class="section-title">Filtrar por Rango de Fechas</h5>
      <div class="filtro-row">
        <div class="filtro-field">
          <label class="form-label">Desde</label>
          <input type="date" class="form-control" v-model="fechaInicio" />
        </div>
        <div class="filtro-field">
          <label class="form-label">Hasta</label>
          <input type="date" class="form-control" v-model="fechaFin" />
        </div>
        <button class="btn btn-primary btn-buscar" @click="buscarReportes" :disabled="loadingRango">
          <i class="fas fa-search me-1"></i>
          {{ loadingRango ? 'Buscando...' : 'Buscar' }}
        </button>
      </div>
    </div>

    <!-- ── Gráficos ── -->
    <div class="charts-grid">

      <!-- Gráfico barras: ventas por rango -->
      <div class="chart-card">
        <h5 class="section-title">Ventas por Fecha</h5>
        <div class="chart-wrapper">
          <canvas ref="barChartRef"></canvas>
        </div>
        <p v-if="!ventasRango.length && !loadingRango" class="chart-empty">
          Selecciona un rango de fechas para ver el gráfico
        </p>
      </div>

      <!-- Gráfico dona: top productos -->
      <div class="chart-card">
        <h5 class="section-title">Top 5 Productos Más Vendidos</h5>
        <div class="chart-wrapper">
          <canvas ref="donutChartRef"></canvas>
        </div>
        <p v-if="!topProductos.length" class="chart-empty">Sin datos disponibles</p>
      </div>

    </div>

    <!-- ── Tabla ventas por rango ── -->
    <div class="table-card" v-if="ventasRango.length">
      <div class="table-header">
        <h5 class="section-title mb-0">Detalle de Ventas</h5>
        <span class="badge bg-primary rounded-pill">{{ ventasRango.length }} registros</span>
      </div>
      <div class="table-wrapper">
        <table class="reporte-table">
          <thead>
            <tr>
              <th>#</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Cajero</th>
              <th class="text-end">Total</th>
              <th class="text-center">Factura</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="venta in ventasRango" :key="venta.id">
              <td>{{ venta.id }}</td>
              <td>{{ formatFecha(venta.fecha_hora) }}</td>
              <td>{{ venta.cliente }}</td>
              <td>{{ venta.cajero }}</td>
              <td class="text-end fw-bold">{{ moneda }} {{ Number(venta.total).toFixed(2) }}</td>
              <td class="text-center">
                <button class="btn btn-outline-primary btn-sm" @click="verFactura(venta.id)">
                  <i class="fas fa-eye"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ── MODAL FACTURA DETALLE ── -->
    <Teleport to="body">
      <div v-if="showFacturaModal" class="modal-overlay" @click.self="closeFacturaModal">
        <div class="modal-content factura-modal">

          <div class="modal-header-custom">
            <h5 class="mb-0 fw-bold">
              <i class="fas fa-file-invoice me-2"></i>Factura #{{ facturaDetalle?.nro_factura }}
            </h5>
            <button class="modal-close-btn" @click="closeFacturaModal">
              <i class="fas fa-times"></i>
            </button>
          </div>

          <div class="modal-body-custom" v-if="facturaDetalle">
            <div class="factura-meta">
              <div class="meta-row">
                <span class="meta-label"><i class="fas fa-calendar me-1"></i> Fecha</span>
                <span>{{ formatFecha(facturaDetalle.fecha_hora) }}</span>
              </div>
              <div class="meta-row">
                <span class="meta-label"><i class="fas fa-user me-1"></i> Cliente</span>
                <span>{{ facturaDetalle.cliente_nombre }}</span>
              </div>
              <div class="meta-row">
                <span class="meta-label"><i class="fas fa-id-card me-1"></i> CI/NIT</span>
                <span>{{ facturaDetalle.cliente_ci }}</span>
              </div>
              <div class="meta-row">
                <span class="meta-label"><i class="fas fa-user-tie me-1"></i> Cajero</span>
                <span>{{ facturaDetalle.cajero }}</span>
              </div>
            </div>

            <table class="table table-sm mt-3">
              <thead class="table-light">
                <tr>
                  <th>Producto</th>
                  <th class="text-center">Cant.</th>
                  <th class="text-end">Precio</th>
                  <th class="text-end">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in facturaDetalle.items" :key="item.producto">
                  <td>{{ item.producto }}</td>
                  <td class="text-center">{{ item.cantidad }}</td>
                  <td class="text-end">{{ moneda }} {{ Number(item.precio_unitario).toFixed(2) }}</td>
                  <td class="text-end fw-bold">{{ moneda }} {{ Number(item.subtotal).toFixed(2) }}</td>
                </tr>
              </tbody>
            </table>

            <div class="factura-total">
              <span>Total</span>
              <span class="total-amount">{{ moneda }} {{ Number(facturaDetalle.total).toFixed(2) }}</span>
            </div>
          </div>

          <div class="modal-footer-custom">
            <button class="btn btn-outline-secondary" @click="closeFacturaModal">Cerrar</button>
          </div>

        </div>
      </div>
    </Teleport>

    <!-- ── MODAL MENSAJE ── -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
        <div class="modal-content message-modal">
          <i class="fas fa-exclamation-circle modal-icon text-danger"></i>
          <p>{{ modalMessage }}</p>
          <button class="btn btn-primary px-4" @click="closeModal">Entendido</button>
        </div>
      </div>
    </Teleport>

  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import {
  getResumenDiario,
  getTopProductos,
  getVentasPorRango,
  getFacturaDetalle,
  getConfigLocal,
} from "../services/api";
import Chart from "chart.js/auto";
import "../assets/styles/reportes.css";
// ─── Config ───────────────────────────────────────────
const moneda = ref("");

const loadConfig = async () => {
  try {
    const configData = await getConfigLocal();
    if (Array.isArray(configData) && configData.length > 0) {
      moneda.value = configData[0].moneda || "";
    } else if (configData && typeof configData === "object") {
      moneda.value = configData.moneda || "";
    }
  } catch (err) {
    console.error("Error cargando config:", err);
  }
};

// ─── Estado ───────────────────────────────────────────
const resumenDiario   = ref({});
const topProductos    = ref([]);
const ventasRango     = ref([]);
const fechaInicio     = ref("");
const fechaFin        = ref("");
const loadingRango    = ref(false);
const facturaDetalle  = ref(null);
const showFacturaModal = ref(false);
const showModal       = ref(false);
const modalMessage    = ref("");

// ─── Charts refs ─────────────────────────────────────
const barChartRef   = ref(null);
const donutChartRef = ref(null);
let barChartInstance   = null;
let donutChartInstance = null;

// ─── Modal mensaje ────────────────────────────────────
const openModal  = (msg) => { modalMessage.value = msg; showModal.value = true; };
const closeModal = ()    => { showModal.value = false; };

// ─── Factura modal ────────────────────────────────────
const verFactura = async (id) => {
  try {
    facturaDetalle.value = await getFacturaDetalle(id);
    showFacturaModal.value = true;
  } catch {
    openModal("Error al cargar la factura");
  }
};
const closeFacturaModal = () => { showFacturaModal.value = false; facturaDetalle.value = null; };

// ─── Helpers ──────────────────────────────────────────
const formatFecha = (fecha) => {
  if (!fecha) return "—";
  return new Date(fecha).toLocaleString("es-BO", {
    day: "2-digit", month: "2-digit", year: "numeric",
    hour: "2-digit", minute: "2-digit",
  });
};

// ─── Gráfico dona (top productos) ────────────────────
const renderDonutChart = () => {
  if (!donutChartRef.value || !topProductos.value.length) return;
  if (donutChartInstance) donutChartInstance.destroy();

  donutChartInstance = new Chart(donutChartRef.value, {
    type: "doughnut",
    data: {
      labels: topProductos.value.map((p) => p.nombre),
      datasets: [{
        data: topProductos.value.map((p) => Number(p.total_unidades)),
        backgroundColor: ["#4e73df", "#f6ad55", "#48bb78", "#fc8181", "#76e4f7"],
        borderWidth: 2,
        borderColor: "#fff",
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: { position: "bottom", labels: { padding: 16, font: { size: 12 } } },
      },
    },
  });
};

// ─── Gráfico barras (ventas por rango) ───────────────
const renderBarChart = () => {
  if (!barChartRef.value || !ventasRango.value.length) return;
  if (barChartInstance) barChartInstance.destroy();

  // Agrupar por fecha
  const grouped = {};
  ventasRango.value.forEach((v) => {
    const fecha = new Date(v.fecha_hora).toLocaleDateString("es-BO");
    grouped[fecha] = (grouped[fecha] || 0) + Number(v.total);
  });

  barChartInstance = new Chart(barChartRef.value, {
    type: "bar",
    data: {
      labels: Object.keys(grouped),
      datasets: [{
        label: `Total (${moneda.value})`,
        data: Object.values(grouped),
        backgroundColor: "rgba(78, 115, 223, 0.7)",
        borderColor: "#4e73df",
        borderWidth: 2,
        borderRadius: 6,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, grid: { color: "#f0f0f0" } },
        x: { grid: { display: false } },
      },
    },
  });
};

// ─── Buscar por rango ─────────────────────────────────
const buscarReportes = async () => {
  if (!fechaInicio.value || !fechaFin.value) {
    openModal("Selecciona un rango de fechas"); return;
  }
  loadingRango.value = true;
  try {
    ventasRango.value = await getVentasPorRango(fechaInicio.value, fechaFin.value);
    await nextTick();
    renderBarChart();
  } catch {
    openModal("Error al cargar ventas por rango");
  } finally {
    loadingRango.value = false;
  }
};

// ─── Carga inicial ────────────────────────────────────
onMounted(async () => {
  await loadConfig();
  try {
    resumenDiario.value = await getResumenDiario();
  } catch { console.error("Error resumen diario"); }
  try {
    topProductos.value = await getTopProductos();
    await nextTick();
    renderDonutChart();
  } catch { console.error("Error top productos"); }
});
</script>

