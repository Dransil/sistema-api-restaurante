<template>
  <div>
    <h2>Categorías</h2>

    <form @submit.prevent="addCategory">
      <input v-model="newCategory" placeholder="Nueva categoría" />
      <button type="submit">Agregar</button>
    </form>

    <ul>
      <li v-for="(cat, index) in categories" :key="index">
        {{ cat }}
        <button @click="removeCategory(index)">Eliminar</button>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      newCategory: "",
      categories: []
    };
  },
  methods: {
    addCategory() {
      if (this.newCategory) {
        this.categories.push(this.newCategory);
        this.newCategory = "";
      }
    },
    removeCategory(index) {
      this.categories.splice(index, 1);
    }
  }
};
</script>