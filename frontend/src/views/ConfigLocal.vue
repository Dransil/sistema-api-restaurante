<template>
  <div class="config-container">
    <h2 class="title">Configuración Local</h2>

    <div v-if="loading">Cargando...</div>

    <div v-else>
      <div v-if="esAdmin" class="form-card">
        <div class="form-group">
          <label>Nombre del Restaurante:</label>
          <input v-model="form.nombre_restaurante" />
        </div>

        <div class="form-group">
          <label>NIT:</label>
          <input v-model="form.nit" />
        </div>

        <div class="form-group">
          <label>Dirección:</label>
          <input v-model="form.direccion" />
        </div>

        <div class="form-group">
          <label>Teléfono:</label>
          <input v-model="form.telefono" />
        </div>

        <div class="form-group">
          <label>Ciudad:</label>
          <input v-model="form.ciudad" />
        </div>
        <div class="form-group">
          <label>Moneda:</label>
          <select v-model="form.moneda">
            <option value="">Seleccionar moneda</option>
            <option value="BOB">BOB - Boliviano (Bs)</option>
            <option value="USD">USD - Dólar ($)</option>
            <option value="EUR">EUR - Euro (€)</option>
            <option value="ARS">ARS - Peso Argentino</option>
            <option value="CLP">CLP - Peso Chileno</option>
            <option value="PEN">PEN - Sol Peruano</option>
          </select>
        </div>

        <div class="form-group">
          <label>Logo URL:</label>
          <input v-model="form.logo_url" />
        </div>

        <div class="buttons">
          <button class="btn-save" @click="guardarConfig" :disabled="saving">
            {{ saving ? "Guardando..." : "Guardar" }}
          </button>

          <button class="btn-cancel" @click="resetForm">Cancelar</button>
        </div>
      </div>

      <div v-if="config">
        <h3>Datos actuales:</h3>

        <div v-if="config.logo_url">
          <p><strong>Logo:</strong></p>
          <img :src="config.logo_url" class="logo-preview" />
        </div>

        <p><strong>Nombre:</strong> {{ config.nombre_restaurante }}</p>
        <p><strong>NIT:</strong> {{ config.nit }}</p>
        <p><strong>Dirección:</strong> {{ config.direccion }}</p>
        <p><strong>Teléfono:</strong> {{ config.telefono }}</p>
        <p><strong>Ciudad:</strong> {{ config.ciudad }}</p>
        <p><strong>Moneda:</strong> {{ config.moneda }}</p>
      </div>
    </div>
  </div>

  <div v-if="showModal" class="modal-overlay">
    <div class="modal-box">
      <p>{{ modalMessage }}</p>
      <button class="btn-save" @click="cerrarModal">Aceptar</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { getConfigLocal, saveConfigLocal } from "../services/api";

const config = ref(null);
const loading = ref(true);
const saving = ref(false);

const rol = Number(localStorage.getItem("rol_id"));
const esAdmin = rol === 1;

const form = ref({
  nombre_restaurante: "",
  nit: "",
  direccion: "",
  telefono: "",
  ciudad: "",
  moneda: "",
  logo_url: "",
});
const showModal = ref(false);
const modalMessage = ref("");
const loadConfig = async () => {
  try {
    const data = await getConfigLocal();

    if (data && data.length > 0) {
      config.value = data[0];

      form.value = {
        nombre_restaurante: data[0].nombre_restaurante || "",
        nit: data[0].nit || "",
        direccion: data[0].direccion || "",
        telefono: data[0].telefono || "",
        ciudad: data[0].ciudad || "",
        moneda: data[0].moneda || "",
        logo_url: data[0].logo_url || "",
      };

      if (data[0].logo_url) {
        localStorage.setItem("logo_url", data[0].logo_url);
      }
    } else {
      config.value = null;
    }
  } catch (err) {
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const guardarConfig = async () => {
  if (!form.value.nombre_restaurante) {
    abrirModal("El nombre es obligatorio");
    return;
  }
  if (!form.value.nit) {
    abrirModal("El NIT es obligatorio");
    return;
  }

  const dataToSend = {
    nombre_restaurante: form.value.nombre_restaurante,
    nit: form.value.nit,
    direccion: form.value.direccion,
    telefono: form.value.telefono,
    ciudad: form.value.ciudad,
    moneda: form.value.moneda,
    logo_url: form.value.logo_url,
  };

  saving.value = true;

  try {
    const res = await saveConfigLocal(dataToSend);
    abrirModal(res.mensaje || "Configuración guardada");

    await loadConfig();

    if (form.value.logo_url) {
      localStorage.setItem("logo_url", form.value.logo_url);

      setTimeout(() => {
        location.reload();
      }, 1500);
    }
  } catch (err) {
    console.error(err);
    abrirModal("Error al guardar");
  } finally {
    saving.value = false;
  }
};
const abrirModal = (mensaje) => {
  modalMessage.value = mensaje;
  showModal.value = true;
};

const cerrarModal = () => {
  showModal.value = false;
};
const resetForm = () => {
  if (config.value) {
    form.value = {
      nombre_restaurante: config.value.nombre_restaurante || "",
      nit: config.value.nit || "",
      direccion: config.value.direccion || "",
      telefono: config.value.telefono || "",
      ciudad: config.value.ciudad || "",
      moneda: config.value.moneda || "",
      logo_url: config.value.logo_url || "",
    };
  }
};

onMounted(loadConfig);
</script>
