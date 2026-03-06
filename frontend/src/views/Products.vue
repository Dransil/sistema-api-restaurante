<template>
  <div>
    <h2>Productos</h2>

    <form @submit.prevent="addProduct">
      <input v-model="name" placeholder="Nombre del producto" />
      <input v-model="price" type="number" placeholder="Precio" />
      <button type="submit">Agregar</button>
    </form>

    <ul>
      <li v-for="product in products" :key="product.id">
        {{ product.nombre }} - ${{ product.precio }}
      </li>
    </ul>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      name: "",
      price: "",
      products: []
    };
  },

  mounted() {
    this.getProducts();
  },

  methods: {
    async getProducts() {
      try {
        const res = await axios.get("http://localhost:3000/productos");
        this.products = res.data; // guarda los productos reales
      } catch (error) {
        console.log(error);
      }
    },

    addProduct() {
      if (this.name && this.price) {
        this.products.push({
          nombre: this.name,
          precio: this.price
        });
        this.name = "";
        this.price = "";
      }
    },

    removeProduct(index) {
      this.products.splice(index, 1);
    }
  }
};
</script>