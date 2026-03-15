<template>
  <div class="container">

    <h2>Pedidos / Ventas</h2>

    <h3>Productos</h3>

<div
  v-for="producto in productos"
  :key="producto.id"
  class="product-card"
>
  <span>
    {{ producto.nombre }} - {{ producto.precio }}
  </span>

  <button
    class="btn btn-add"
    @click="agregarProducto(producto)"
  >
    Agregar
  </button>
</div>

    <hr>

    <h3>Carrito</h3>

<div
  v-for="item in carrito"
  :key="item.producto_id"
  class="cart-item"
>
  {{ item.nombre }} -
  Cantidad: {{ item.cantidad }}
  Precio: {{ item.precio_unitario }}

  <button
  class="btn btn-remove"
  @click="eliminarProducto(item)"
>
  X
</button>
</div>

    <h3 class="total">
  Total: {{ total }}
</h3>

    <button
  class="btn btn-finish"
  @click="finalizarVenta"
>
  Finalizar Venta
</button>

  </div>
</template>
<script setup>

import { ref, onMounted } from "vue"
import { getProductos, registrarPedido } from "../services/api"
import "../assets/styles/pedidos.css"

const productos = ref([])
const carrito = ref([])
const total = ref(0)

const usuario_id = Number(localStorage.getItem("user_id"))
const cliente_id = null

const loadProductos = async () => {
  productos.value = await getProductos()
}

onMounted(loadProductos)

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

const finalizarVenta = async () => {
  const pedido = {
    usuario_id: Number(usuario_id),
    cliente_id: cliente_id ? Number(cliente_id) : null,
    total: Number(total.value),
    detalles: carrito.value
  }

  try {
    console.log("Pedido enviado:", pedido)

    const res = await registrarPedido(pedido)

    console.log("Respuesta:", res)

    alert("Venta registrada")

    carrito.value = []
    total.value = 0

  } catch (error) {
    console.error("ERROR BACKEND:", error.response?.data)
    alert("Error: " + JSON.stringify(error.response?.data))
  }
}

</script>