<template>
  <div class="pedidos-container">

    <div class="pedidos-main">

      <!-- LADO IZQUIERDO: DATOS DEL CLIENTE Y PRODUCTOS -->
      <div class="pedidos-left">

        <!-- DATOS DEL CLIENTE Y BUSCADOR -->
        <div class="pedidos-card">
          <h3>Datos del Cliente</h3>
          <div class="cliente-box">
            <input v-model="ci" placeholder="CI" @blur="buscarCliente" />
            <input v-model="razon_social" placeholder="Razón Social" />
          </div>

          <h3>Buscar Productos</h3>
          <input
            v-model="buscar"
            placeholder="Buscar producto..."
            class="buscador-producto"
          />
        </div>

        <!-- PRODUCTOS -->
        <div class="productos">
          <div
            v-for="producto in productosFiltrados"
            :key="producto.id"
            class="product-card"
          >
            <img
              v-if="producto.imagen_url"
              :src="`http://localhost:3000${producto.imagen_url}`"
              class="product-img"
            />
            <span>{{ producto.nombre }} - {{ producto.precio }}</span>
            <button class="btn btn-add" @click="agregarProducto(producto)">
              Agregar
            </button>
          </div>
        </div>

      </div>

      <!-- LADO DERECHO: CARRITO -->
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
            <td>{{ item.cantidad }}</td>
            <td>{{ item.precio_unitario }}</td>
            <td>{{ item.cantidad * item.precio_unitario }}</td>
            <td>
              <button class="btn btn-remove" @click="eliminarProducto(item)">X</button>
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

        <button class="btn btn-finish" @click="finalizarVenta">Finalizar Venta</button>
      </div>

    </div>

  </div>
</template>
<script setup>

import { ref, onMounted, computed } from "vue"
import { getProductos, registrarPedido, getClienteByCI, addCliente 
} from "../services/api"
import "../assets/styles/pedidos.css"


const productos = ref([])
const carrito = ref([])
const total = ref(0)
const buscar = ref("")
const cobrado = ref(0)
const cambio = ref(0)

const ci = ref("")
const razon_social = ref("")
const cliente_id = ref(null)

const usuario_id = Number(localStorage.getItem("user_id"))


const loadProductos = async () => {
  productos.value = await getProductos()
  console.log(productos.value)
}

onMounted(loadProductos)

const productosFiltrados = computed(() => {
  return productos.value.filter(p =>
    p.nombre.toLowerCase().includes(buscar.value.toLowerCase())
  )
})
const buscarCliente = async () => {

  if (!ci.value) return

  try {

    const cliente = await getClienteByCI(ci.value)

    razon_social.value = cliente.razon_social
    cliente_id.value = cliente.id

  } catch (error) {

    razon_social.value = ""
    cliente_id.value = null

  }

}

const agregarProducto = (producto) => {

  const existente = carrito.value.find(
    item => item.producto_id === producto.id
  )

  if (existente) {
    existente.cantidad++
  } else {
    carrito.value.push({
      producto_id: producto.id,
      nombre: producto.nombre,
      cantidad: 1,
      precio_unitario: Number(producto.precio)
    })
  }

  total.value += Number(producto.precio)
}

const eliminarProducto = (item) => {

  total.value -= item.precio_unitario * item.cantidad

  carrito.value = carrito.value.filter(
    p => p.producto_id !== item.producto_id
  )
}

const calcularCambio = () => {
  cambio.value = cobrado.value - total.value
}

const finalizarVenta = async () => {

  try {

    // Si el cliente no existe lo crea
    if (!cliente_id.value && razon_social.value) {

      const nuevoCliente = await addCliente({
        ci: ci.value,
        razon_social: razon_social.value
      })

      cliente_id.value = nuevoCliente.id
    }

    const pedido = {

      usuario_id: usuario_id,
      cliente_id: cliente_id.value,
      total: Number(total.value),
      detalles: carrito.value

    }

    console.log("Pedido enviado:", pedido)

    await registrarPedido(pedido)

    alert("Venta registrada")

    carrito.value = []
    total.value = 0
    ci.value = ""
    razon_social.value = ""
    cliente_id.value = null
    cobrado.value = 0
cambio.value = 0

  } catch (error) {

    console.error("ERROR BACKEND:", error.response?.data)
    alert("Error registrando venta")

  }

}

</script>