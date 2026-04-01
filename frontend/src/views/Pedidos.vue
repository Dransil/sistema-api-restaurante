<template>
  <div class="pedidos-container">
    <div class="pedidos-main">

      <!-- ── COLUMNA IZQUIERDA: Productos ── -->
      <div class="pedidos-left">
        <div class="pedidos-card">
          <h5 class="section-title">Datos del Cliente</h5>
          <div class="cliente-box">
            <input v-model="ci" class="form-control" placeholder="CI" />
            <input v-model="razon_social" class="form-control" placeholder="Razón Social" />
          </div>

          <h5 class="section-title mt-3">Categorías</h5>
          <div class="categorias">
            <button class="btn btn-sm" :class="categoriaSeleccionada === null ? 'btn-primary' : 'btn-outline-secondary'"
              @click="mostrarTodos">Todos</button>
            <button v-for="cat in categorias" :key="cat.id" class="btn btn-sm"
              :class="categoriaSeleccionada === cat.id ? 'btn-primary' : 'btn-outline-secondary'"
              @click="filtrarPorCategoria(cat.id)">{{ cat.nombre }}</button>
          </div>

          <input v-model="buscar" placeholder="Buscar producto..." class="form-control buscador-producto mt-3" />
        </div>

        <!-- Grid de productos -->
        <div class="productos">
          <div v-for="producto in productosFiltrados" :key="producto.id" class="product-card"
            @click="agregarProducto(producto)">
            <img v-if="producto.imagen_url" :src="`http://localhost:3000${producto.imagen_url}`" class="product-img" />
            <div v-else class="product-img-placeholder">
              <i class="fas fa-utensils"></i>
            </div>
            <div class="product-info">
              <span class="product-name">{{ producto.nombre }}</span>
              <span class="product-price">{{ moneda }} {{ Number(producto.precio).toFixed(2) }}</span>
              <span class="stock-badge" :class="{
                'badge-available': producto.stock > 5,
                'badge-low': producto.stock > 0 && producto.stock <= 5,
                'badge-out': producto.stock === 0
              }">
                {{ producto.stock === 0 ? 'Agotado' : `Stock: ${producto.stock}` }}
              </span>
            </div>
          </div>
        </div>

        <!-- Paginación -->
        <div class="pagination-container">
          <div class="pagination-info">
            Mostrando {{ startItem }}-{{ endItem }} de {{ totalFiltrados }}
          </div>
          <div class="pagination">
            <button class="page-btn" @click="prevPage" :disabled="currentPage === 1">‹</button>
            <button v-for="page in totalPages" :key="page" class="page-btn" :class="{ active: page === currentPage }"
              @click="goToPage(page)">{{ page }}</button>
            <button class="page-btn" @click="nextPage" :disabled="currentPage === totalPages">›</button>
          </div>
        </div>
      </div>

      <!-- ── COLUMNA DERECHA: Carrito ── -->
      <div class="pedidos-right">
        <div class="carrito-header">
          <h5 class="section-title mb-0">
            <i class="fas fa-shopping-cart me-2"></i>Carrito
          </h5>
          <span class="badge bg-primary rounded-pill">{{ carrito.length }} ítems</span>
        </div>

        <!-- Tabla carrito -->
        <div class="carrito-table-wrapper">
          <div v-if="carrito.length === 0" class="carrito-empty">
            <i class="fas fa-cart-plus fa-2x text-muted"></i>
            <p class="text-muted mt-2">El carrito está vacío</p>
          </div>

          <table v-else class="table table-sm detalle-table">
            <thead class="table-light">
              <tr>
                <th>Producto</th>
                <th class="text-center">Cant.</th>
                <th class="text-end">Precio</th>
                <th class="text-end">Subtotal</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in carrito" :key="item.producto_id">
                <td class="align-middle">{{ item.nombre }}</td>
                <td class="align-middle text-center">
                  <div class="cantidad-controls">
                    <button class="btn btn-outline-secondary btn-xs" @click="disminuirCantidad(item)">−</button>
                    <span class="cantidad-num">{{ item.cantidad }}</span>
                    <button class="btn btn-outline-secondary btn-xs" @click="aumentarCantidad(item)">+</button>
                  </div>
                </td>
                <td class="align-middle text-end">{{ moneda }} {{ Number(item.precio_unitario).toFixed(2) }}</td>
                <td class="align-middle text-end fw-bold">{{ moneda }} {{ (item.cantidad *
                  item.precio_unitario).toFixed(2) }}</td>
                <td class="align-middle text-center">
                  <button class="btn btn-outline-danger btn-xs" @click="eliminarProducto(item)">
                    <i class="fas fa-trash-alt"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Total y cobro -->
        <div class="carrito-footer">
          <div class="total-row">
            <span class="total-label">Total</span>
            <span class="total-value">{{ moneda }} {{ Number(total).toFixed(2) }}</span>
          </div>

          <div class="pago-box">
            <div class="pago-field">
              <label class="form-label">Cobrado</label>
              <div class="input-group input-group-sm">
                <span class="input-group-text">{{ moneda }}</span>
                <input type="number" class="form-control" v-model="cobrado" @input="calcularCambio" />
              </div>
            </div>
            <div class="pago-field">
              <label class="form-label">Cambio</label>
              <div class="input-group input-group-sm">
                <span class="input-group-text">{{ moneda }}</span>
                <input type="number" class="form-control" :value="Number(cambio).toFixed(2)"
                  :class="cambio < 0 ? 'text-danger' : 'text-success'" disabled />
              </div>
            </div>
          </div>

          <button class="btn btn-success w-100 btn-finalizar" @click="finalizarVenta">
            <i class="fas fa-check-circle me-2"></i> Finalizar Venta
          </button>
        </div>
      </div>
    </div>

    <!-- ── MODAL MENSAJE ── -->
    <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-content message-modal">
        <i class="modal-icon fas"
          :class="modalTitle === 'Éxito' ? 'fa-check-circle text-success' : 'fa-exclamation-circle text-danger'"></i>
        <h5 class="fw-bold mt-2">{{ modalTitle }}</h5>
        <p class="text-muted">{{ modalMessage }}</p>
        <button class="btn btn-primary px-4" @click="cerrarModal">Entendido</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from "vue";
import {
  getProductos,
  registrarPedido,
  getClienteByCI,
  addCliente,
  getCategorias,
  getProductosByCategoria,
  getConfigLocal,
} from "../services/api";
import "../assets/styles/pedidos.css";

import { PDFDocument, rgb, StandardFonts } from "pdf-lib";

// ─── Moneda desde config ─────────────────────────────
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

// ─── Estado ──────────────────────────────────────────
const productos = ref([]);
const carrito = ref([]);
const total = ref(0);
const buscar = ref("");
const cobrado = ref(0);
const cambio = ref(0);
const categorias = ref([]);
const categoriaSeleccionada = ref(null);
const ci = ref("");
const razon_social = ref("");
const cliente_id = ref(null);
const showModal = ref(false);
const modalTitle = ref("");
const modalMessage = ref("");
const usuario_id = Number(localStorage.getItem("user_id"));

// ─── Paginación ──────────────────────────────────────
const currentPage = ref(1);
const productosPorPagina = 10;

watch(buscar, () => { currentPage.value = 1; });

// ─── Cliente por CI ──────────────────────────────────
watch(ci, async (newCi) => {
  if (!newCi) { razon_social.value = ""; cliente_id.value = null; return; }
  try {
    const cliente = await getClienteByCI(newCi);
    razon_social.value = cliente.razon_social;
    cliente_id.value = cliente.id;
  } catch {
    razon_social.value = "";
    cliente_id.value = null;
  }
});

// ─── Carga datos ─────────────────────────────────────
const loadProductos = async () => { productos.value = await getProductos(); };
const loadCategorias = async () => { categorias.value = await getCategorias(); };

onMounted(() => {
  loadConfig();
  loadProductos();
  loadCategorias();
});

// ─── Filtros y paginación ────────────────────────────
const filtrarPorCategoria = async (id) => {
  categoriaSeleccionada.value = id;
  currentPage.value = 1;
  try {
    productos.value = await getProductosByCategoria(id);
  } catch {
    productos.value = [];
    abrirModal("Info", "No hay productos en esta categoría");
  }
};

const mostrarTodos = async () => {
  categoriaSeleccionada.value = null;
  currentPage.value = 1;
  await loadProductos();
};

const productosFiltrados = computed(() => {
  const filtrados = productos.value.filter((p) =>
    p.nombre.toLowerCase().includes(buscar.value.toLowerCase())
  );
  const start = (currentPage.value - 1) * productosPorPagina;
  return filtrados.slice(start, start + productosPorPagina);
});

const totalFiltrados = computed(() =>
  productos.value.filter((p) =>
    p.nombre.toLowerCase().includes(buscar.value.toLowerCase())
  ).length
);

const totalPages = computed(() =>
  Math.max(1, Math.ceil(totalFiltrados.value / productosPorPagina))
);

const startItem = computed(() => (currentPage.value - 1) * productosPorPagina + 1);
const endItem = computed(() => Math.min(currentPage.value * productosPorPagina, totalFiltrados.value));

const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const goToPage = (page) => { currentPage.value = page; };

// ─── Carrito ─────────────────────────────────────────
const agregarProducto = (producto) => {
  if (producto.stock <= 0) { abrirModal("Error", "Producto sin stock"); return; }
  const existente = carrito.value.find((i) => i.producto_id === producto.id);
  if (existente) {
    if (existente.cantidad >= producto.stock) {
      abrirModal("Stock", "No hay más unidades disponibles"); return;
    }
    existente.cantidad++;
  } else {
    carrito.value.push({
      producto_id: producto.id,
      nombre: producto.nombre,
      cantidad: 1,
      precio_unitario: Number(producto.precio),
    });
  }
  total.value += Number(producto.precio);
};

const aumentarCantidad = (item) => {
  const producto = productos.value.find((p) => p.id === item.producto_id);
  if (item.cantidad >= producto.stock) {
    abrirModal("Stock", "No hay más unidades disponibles"); return;
  }
  item.cantidad++;
  total.value += item.precio_unitario;
};

const disminuirCantidad = (item) => {
  item.cantidad--;
  total.value -= item.precio_unitario;
  if (item.cantidad <= 0) {
    carrito.value = carrito.value.filter((p) => p.producto_id !== item.producto_id);
  }
};

const eliminarProducto = (item) => {
  total.value -= item.precio_unitario * item.cantidad;
  carrito.value = carrito.value.filter((p) => p.producto_id !== item.producto_id);
};

const calcularCambio = () => { cambio.value = cobrado.value - total.value; };

// ─── Modal ───────────────────────────────────────────
const abrirModal = (titulo, mensaje) => { modalTitle.value = titulo; modalMessage.value = mensaje; showModal.value = true; };
const cerrarModal = () => { showModal.value = false; };

// ─── PDF ─────────────────────────────────────────────
const generarFacturaPDF = async ({ cliente, ci, total, carrito }) => {
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage([600, 750]);
  const { width, height } = page.getSize();
  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

  let y = height - 50;

  page.drawRectangle({ x: 0, y: y - 25, width, height: 40, color: rgb(0.9, 0.9, 0.9) });
  page.drawText("Factura de Venta", { x: width / 2 - 60, y: y - 10, size: 18, font });
  y -= 60;

  page.drawText(`Cliente: ${cliente || "N/A"}`, { x: 50, y, size: 12, font });
  y -= 20;
  page.drawText(`CI: ${ci || "N/A"}`, { x: 50, y, size: 12, font });
  y -= 30;

  const columnWidths = [200, 70, 100, 100];
  const rowHeight = 25;

  const drawCell = (text, x, y, w, h, isHeader = false, bgColor = null) => {
    if (bgColor) page.drawRectangle({ x, y: y - h, width: w, height: h, color: bgColor });
    page.drawRectangle({ x, y: y - h, width: w, height: h, borderColor: rgb(0, 0, 0), borderWidth: 1 });
    page.drawText(text, { x: x + 5, y: y - h / 2 - 5, size: 12, font });
  };

  let x = 50;
  ["Producto", "Cantidad", "Precio Unitario", "Subtotal"].forEach((h, i) => {
    drawCell(h, x, y, columnWidths[i], rowHeight, true, rgb(0.8, 0.8, 0.8));
    x += columnWidths[i];
  });
  y -= rowHeight;

  carrito.forEach((item, index) => {
    x = 50;
    const bgColor = index % 2 === 0 ? rgb(0.95, 0.95, 0.95) : null;
    [
      item.nombre,
      item.cantidad.toString(),
      `${moneda.value} ${item.precio_unitario.toFixed(2)}`,
      `${moneda.value} ${(item.cantidad * item.precio_unitario).toFixed(2)}`,
    ].forEach((val, i) => {
      drawCell(val, x, y, columnWidths[i], rowHeight, false, bgColor);
      x += columnWidths[i];
    });
    y -= rowHeight;
  });

  page.drawRectangle({ x: 50, y: y - rowHeight, width: columnWidths.reduce((a, b) => a + b, 0), height: rowHeight, color: rgb(0.9, 0.9, 0.9) });
  page.drawText(`Total: ${moneda.value} ${total.toFixed(2)}`, { x: 380, y: y - 15, size: 14, font });
  y -= rowHeight + 20;
  page.drawText("¡Gracias por su compra!", { x: 200, y, size: 12, font });

  const blob = new Blob([await pdfDoc.save()], { type: "application/pdf" });
  window.open(URL.createObjectURL(blob), "_blank");
};

// ─── Finalizar venta ─────────────────────────────────
const finalizarVenta = async () => {
  if (carrito.value.length === 0) return abrirModal("Error", "El carrito está vacío");
  if (cobrado.value <= 0) return abrirModal("Error", "Ingrese el monto cobrado");
  if (cobrado.value < total.value) return abrirModal("Error", "El monto es insuficiente");

  try {
    if (!cliente_id.value && razon_social.value) {
      const nuevoCliente = await addCliente({ ci: ci.value, razon_social: razon_social.value });
      cliente_id.value = nuevoCliente.id;
    }

    await registrarPedido({
      usuario_id,
      cliente_id: cliente_id.value,
      total: Number(total.value),
      detalles: carrito.value,
    });

    generarFacturaPDF({ cliente: razon_social.value, ci: ci.value, total: total.value, carrito: [...carrito.value] });

    abrirModal("Éxito", "Venta registrada correctamente");

    carrito.value = [];
    total.value = 0;
    ci.value = "";
    razon_social.value = "";
    cliente_id.value = null;
    cobrado.value = 0;
    cambio.value = 0;
  } catch (error) {
    abrirModal("Error", error.response?.data?.error || "Error registrando venta");
  }
};
</script>