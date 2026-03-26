<template>
  <div class="pedidos-container">
    <div class="pedidos-main">
      <div class="pedidos-left">
        <div class="pedidos-card">
          <h3>Datos del Cliente</h3>
          <div class="cliente-box">
            <input v-model="ci" placeholder="CI" @blur="buscarCliente" />
            <input v-model="razon_social" placeholder="Razón Social" />
          </div>

          <h3>Buscar Productos</h3>
          <div class="categorias">
            <button
              v-for="cat in categorias"
              :key="cat.id"
              @click="filtrarPorCategoria(cat.id)"
              :class="{ active: categoriaSeleccionada === cat.id }"
            >
              {{ cat.nombre }}
            </button>
            <button @click="mostrarTodos">Todos</button>
          </div>

          <input
            v-model="buscar"
            placeholder="Buscar producto..."
            class="buscador-producto"
          />
        </div>

        <div class="productos">
          <div
            v-for="producto in productosFiltrados"
            :key="producto.id"
            class="product-card"
            @click="agregarProducto(producto)"
            style="cursor: pointer"
          >
            <img
              v-if="producto.imagen_url"
              :src="`http://localhost:3000${producto.imagen_url}`"
              class="product-img"
            />
            <span>{{ producto.nombre }} - {{ producto.precio }}</span>
          </div>
        </div>

        <div class="pagination-container">
          <div class="pagination-info">
            Mostrando {{ startItem }}-{{ endItem }} de
            {{
              productos.filter((p) =>
                p.nombre.toLowerCase().includes(buscar.toLowerCase()),
              ).length
            }}
          </div>

          <div class="pagination">
            <button @click="prevPage" :disabled="currentPage === 1">‹</button>

            <button
              v-for="page in totalPages"
              :key="page"
              :class="{ active: page === currentPage }"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>

            <button @click="nextPage" :disabled="currentPage === totalPages">
              ›
            </button>
          </div>
        </div>
      </div>

      <div class="pedidos-right carrito">
        <h3>Carrito</h3>
        <table class="detalle-table">
          <tr>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Precio</th>
            <th>Subtotal</th>
            <th></th>
          </tr>
          <tr v-for="item in carrito" :key="item.producto_id">
            <td>{{ item.nombre }}</td>
            <td>
              <button @click="disminuirCantidad(item)">-</button>
              {{ item.cantidad }}
              <button @click="aumentarCantidad(item)">+</button>
            </td>
            <td>{{ item.precio_unitario }}</td>
            <td>{{ item.cantidad * item.precio_unitario }}</td>
            <td>
              <button class="btn btn-remove" @click="eliminarProducto(item)">
                X
              </button>
            </td>
          </tr>
        </table>

        <h3 class="total">Total: {{ total }}</h3>

        <div class="pago-box">
          <label>Cobrado:</label>
          <input type="number" v-model="cobrado" @input="calcularCambio" />
          <label>Cambio:</label>
          <input type="number" :value="cambio" disabled />
        </div>

        <button class="btn btn-finish" @click="finalizarVenta">
          Finalizar Venta
        </button>
      </div>
    </div>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-box">
        <h3>{{ modalTitle }}</h3>
        <p>{{ modalMessage }}</p>
        <button class="btn btn-finish" @click="cerrarModal">OK</button>
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
} from "../services/api";
import "../assets/styles/pedidos.css";

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

const currentPage = ref(1);
const productosPorPagina = 10;

watch(buscar, () => {
  currentPage.value = 1;
});

const aumentarCantidad = (item) => {
  const producto = productos.value.find((p) => p.id === item.producto_id);
  if (item.cantidad >= producto.stock) {
    abrirModal("Stock", "No hay más unidades disponibles");
    return;
  }
  item.cantidad++;
  total.value += item.precio_unitario;
};

const disminuirCantidad = (item) => {
  item.cantidad--;
  total.value -= item.precio_unitario;
  if (item.cantidad <= 0) {
    carrito.value = carrito.value.filter(
      (p) => p.producto_id !== item.producto_id,
    );
  }
};

const mostrarTodos = async () => {
  categoriaSeleccionada.value = null;
  currentPage.value = 1;
  await loadProductos();
};

const loadProductos = async () => {
  productos.value = await getProductos();
};

const loadCategorias = async () => {
  categorias.value = await getCategorias();
};

onMounted(() => {
  loadProductos();
  loadCategorias();
});

const filtrarPorCategoria = async (id) => {
  categoriaSeleccionada.value = id;
  currentPage.value = 1;
  try {
    const data = await getProductosByCategoria(id);
    productos.value = data;
  } catch (error) {
    productos.value = [];
    abrirModal("Info", "No hay productos en esta categoría");
  }
};

const productosFiltrados = computed(() => {
  const filtrados = productos.value.filter((p) =>
    p.nombre.toLowerCase().includes(buscar.value.toLowerCase()),
  );

  const start = (currentPage.value - 1) * productosPorPagina;
  const end = start + productosPorPagina;

  return filtrados.slice(start, end);
});

const totalPages = computed(() => {
  const filtradosLength = productos.value.filter((p) =>
    p.nombre.toLowerCase().includes(buscar.value.toLowerCase()),
  ).length;
  return Math.max(1, Math.ceil(filtradosLength / productosPorPagina));
});

const startItem = computed(
  () => (currentPage.value - 1) * productosPorPagina + 1,
);
const endItem = computed(() => {
  const end = currentPage.value * productosPorPagina;
  const filtradosLength = productos.value.filter((p) =>
    p.nombre.toLowerCase().includes(buscar.value.toLowerCase()),
  ).length;
  return end > filtradosLength ? filtradosLength : end;
});

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};
const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};
const goToPage = (page) => {
  currentPage.value = page;
};

const buscarCliente = async () => {
  if (!ci.value) return;
  try {
    const cliente = await getClienteByCI(ci.value);
    razon_social.value = cliente.razon_social;
    cliente_id.value = cliente.id;
  } catch {
    razon_social.value = "";
    cliente_id.value = null;
  }
};

const abrirModal = (titulo, mensaje) => {
  modalTitle.value = titulo;
  modalMessage.value = mensaje;
  showModal.value = true;
};
const cerrarModal = () => (showModal.value = false);

const agregarProducto = (producto) => {
  if (producto.stock <= 0) {
    abrirModal("Error", "Producto sin stock");
    return;
  }

  const existente = carrito.value.find(
    (item) => item.producto_id === producto.id,
  );
  if (existente) {
    if (existente.cantidad >= producto.stock) {
      abrirModal("Stock", "No hay más unidades disponibles");
      return;
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

const eliminarProducto = (item) => {
  total.value -= item.precio_unitario * item.cantidad;
  carrito.value = carrito.value.filter(
    (p) => p.producto_id !== item.producto_id,
  );
};

const calcularCambio = () => {
  cambio.value = cobrado.value - total.value;
};

const finalizarVenta = async () => {
  if (carrito.value.length === 0)
    return abrirModal("Error", "El carrito está vacío");
  if (cobrado.value <= 0)
    return abrirModal("Error", "Ingrese el monto cobrado");
  if (cobrado.value < total.value)
    return abrirModal("Error", "El monto es insuficiente");

  try {
    if (!cliente_id.value && razon_social.value) {
      const nuevoCliente = await addCliente({
        ci: ci.value,
        razon_social: razon_social.value,
      });
      cliente_id.value = nuevoCliente.id;
    }

    const pedido = {
      usuario_id,
      cliente_id: cliente_id.value,
      total: Number(total.value),
      detalles: carrito.value,
    };

    await registrarPedido(pedido);
    abrirModal("Éxito", "Venta registrada correctamente");

    carrito.value = [];
    total.value = 0;
    ci.value = "";
    razon_social.value = "";
    cliente_id.value = null;
    cobrado.value = 0;
    cambio.value = 0;
  } catch (error) {
    const mensaje = error.response?.data?.error || "Error registrando venta";
    abrirModal("Error", mensaje);
  }
};
</script>
