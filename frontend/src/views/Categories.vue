```vue
<template>

  <div class="container">

    <h2 class="title">Categorías</h2>

  <form class="form" @submit.prevent="addCategory">

  <input
    v-model="newCategory"
    placeholder="Nueva categoría"
  />

  <button type="submit">
    Agregar
  </button>

</form>

    <div class="grid">

      <div class="card" v-for="cat in categories" :key="cat.id">

        <img
          v-if="cat.imagen_url"
          :src="`http://localhost:3000/uploads/${cat.imagen_url}`"
          class="product-img"
        />

        <h3>{{ cat.nombre }}</h3>

        <button
          class="delete-btn"
          @click="deleteCategory(cat.id)"
        >
          Eliminar
        </button>

      </div>

    </div>
    <ul>
      <li v-for="cat in categories" :key="cat.id">
        {{ cat.nombre }}
        <button @click="removeCategory(index)">Eliminar</button>

      </li>
    </ul>
  </div>

</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getCategorias, addCategoria, deleteCategoria } from '../services/api'
import "../assets/styles/categorias.css"

const newCategory = ref('')
const image = ref(null)
const categories = ref([])

const loadCategories = async () => {
  try {
    categories.value = await getCategorias()
  } catch (err) {
    console.error('Error cargando categorías:', err)
  }
}

onMounted(loadCategories)

const handleFileChange = (e) => {
  const file = e.target.files[0]

  if(!file) return

  if(
    file.type === "image/png" ||
    file.type === "image/jpeg" ||
    file.type === "image/jpg"
  ){
    image.value = file
  }else{
    alert("Solo se permiten imágenes JPG o PNG")
  }
}


const addCategory = async () => {

  if (!newCategory.value) {
    alert("Ingresa el nombre de la categoría")
    return
  }

  try {

    await addCategoria({
      nombre: newCategory.value
    })

    newCategory.value = ''

    await loadCategories()

  } catch (err) {

    console.error('Error agregando categoría:', err)

  }

}

const deleteCategory = async (id) => {

  if(!confirm("¿Eliminar categoría?")) return

  try {

    await deleteCategoria(id)

    await loadCategories()

  } catch (err) {

    console.error("Error eliminando categoría:", err)

  }

}
</script>
```
