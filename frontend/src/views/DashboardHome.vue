<template>
  <div class="dashboard-wrapper p-4">
    
    <div v-if="loading" class="d-flex flex-column justify-content-center align-items-center loader-container">
      <div class="spinner-grow text-primary" role="status"></div>
      <p class="mt-3 text-muted fw-bold">Sincronizando con {{ infoNegocio.nombre_restaurante || 'el servidor' }}...</p>
    </div>

    <div v-else class="animate-fade-in">
      
      <header class="restaurant-header shadow-sm mb-5 bg-white">
        <div class="row align-items-center p-4">
          <div class="col-auto">
            <div class="logo-wrapper shadow-sm">
              <img v-if="infoNegocio.logo_url" :src="infoNegocio.logo_url" alt="Logo" class="logo-img" />
              <i v-else class="fas fa-utensils text-light-gray fa-2x"></i>
            </div>
          </div>
          <div class="col mt-3 mt-md-0">
            <h1 class="display-6 fw-bold text-dark mb-1">{{ infoNegocio.nombre_restaurante }}</h1>
            <div class="d-flex flex-wrap gap-2 mt-2">
              <span class="info-tag"><i class="fas fa-file-alt"></i> NIT: {{ infoNegocio.nit }}</span>
              <span class="info-tag"><i class="fas fa-map-marker-alt"></i> {{ infoNegocio.ciudad }}</span>
              <span class="info-tag"><i class="fas fa-phone"></i> {{ infoNegocio.telefono }}</span>
              <span class="info-tag currency"><i class="fas fa-coins"></i> {{ infoNegocio.moneda }}</span>
            </div>
          </div>
          <div class="col-md-3 text-md-end d-none d-md-block border-start ps-4">
            <p class="small text-uppercase text-muted fw-bold mb-1">Ubicación Actual</p>
            <p class="m-0 text-secondary fw-medium">{{ infoNegocio.direccion }}</p>
          </div>
        </div>
      </header>

      <div class="row g-4">
        
        <div class="col-12 col-md-4">
          <div class="metric-card bg-gradient-blue" @click="goTo('/dashboard/users')">
            <div class="card-body p-4">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <h3 class="display-5 fw-bold m-0">{{ totalUsuarios }}</h3>
                  <p class="text-uppercase small fw-bold opacity-75">Personal / Usuarios</p>
                </div>
                <div class="metric-icon"><i class="fas fa-user-tie"></i></div>
              </div>
              <div class="card-footer-action mt-3">
                Gestionar equipo <i class="fas fa-arrow-right"></i>
              </div>
            </div>
          </div>
        </div>

        <div class="col-12 col-md-4">
          <div class="metric-card bg-gradient-orange" @click="goTo('/dashboard/products')">
            <div class="card-body p-4">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <h3 class="display-5 fw-bold m-0">{{ totalProductos }}</h3>
                  <p class="text-uppercase small fw-bold opacity-75">Productos en Menú</p>
                </div>
                <div class="metric-icon"><i class="fas fa-hamburger"></i></div>
              </div>
              <div class="card-footer-action mt-3">
                Ver inventario <i class="fas fa-arrow-right"></i>
              </div>
            </div>
          </div>
        </div>

        <div class="col-12 col-md-4">
          <div class="metric-card bg-gradient-green" @click="goTo('/dashboard/clientes')">
            <div class="card-body p-4">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <h3 class="display-5 fw-bold m-0">{{ totalClientes }}</h3>
                  <p class="text-uppercase small fw-bold opacity-75">Clientes Fieles</p>
                </div>
                <div class="metric-icon"><i class="fas fa-users"></i></div>
              </div>
              <div class="card-footer-action mt-3">
                Base de datos <i class="fas fa-arrow-right"></i>
              </div>
            </div>
          </div>
        </div>

      </div>

      <div class="welcome-banner mt-5 p-5 text-white rounded-4 shadow">
        <div class="row align-items-center">
          <div class="col-md-8">
            <h2 class="fw-bold">¡Hola de nuevo, {{ infoNegocio.nombre_restaurante }}!</h2>
            <p class="lead opacity-75">Hoy es un gran día para optimizar tus ventas. Revisa tus reportes para ver el rendimiento de hoy.</p>
            <button class="btn btn-light text-primary fw-bold mt-3 px-4 py-2" @click="goTo('/dashboard/reportes')">
              <i class="fas fa-chart-pie me-2"></i> Ver Reportes de hoy
            </button>
          </div>
          <div class="col-md-4 text-center d-none d-md-block">
            <i class="fas fa-rocket fa-6x opacity-25"></i>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { getConfigLocal, getUsuarios, getProductos, getClientes } from "../services/api";

const router = useRouter();
const loading = ref(true);
const totalUsuarios = ref(0);
const totalProductos = ref(0);
const totalClientes = ref(0);

const infoNegocio = reactive({
  nombre_restaurante: '',
  nit: '',
  direccion: '',
  telefono: '',
  ciudad: '',
  moneda: '',
  logo_url: ''
});

const goTo = (ruta) => router.push(ruta);

const initDashboard = async () => {
  loading.value = true;
  try {
    const configData = await getConfigLocal();
    console.log("configData recibido:", configData); // Para verificar la estructura

    if (Array.isArray(configData) && configData.length > 0) {
      Object.assign(infoNegocio, configData[0]);
    } else if (configData && typeof configData === 'object' && !Array.isArray(configData)) {
      // Por si acaso retorna directamente un objeto (no un array)
      Object.assign(infoNegocio, configData);
    }

    // 2. Estadísticas en paralelo para mayor velocidad
    const [u, p, c] = await Promise.all([
      getUsuarios(),
      getProductos(),
      getClientes()
    ]);

    totalUsuarios.value = u?.length || 0;
    totalProductos.value = Array.isArray(p) ? p.length : (p?.rows?.length || 0);
    totalClientes.value = c?.length || 0;

  } catch (err) {
    console.error("Error al cargar el dashboard:", err);
  } finally {
    setTimeout(() => { loading.value = false; }, 400);
  }
};

onMounted(initDashboard);
</script>

<style scoped>
/* Contenedor Principal */
.dashboard-wrapper {
  background-color: #f4f6f9;
  min-height: 100vh;
}

/* Loader */
.loader-container {
  height: 80vh;
}

/* Header Estilo */
.restaurant-header {
  border-radius: 20px;
  border-bottom: 5px solid #e9ecef;
}

.logo-wrapper {
  width: 100px;
  height: 100px;
  background: #f8f9fa;
  border-radius: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 4px solid #fff;
}

.logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.info-tag {
  background: #f1f3f5;
  color: #495057;
  padding: 5px 14px;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 600;
}

.info-tag.currency {
  background: #e7f5ff;
  color: #1c7ed6;
}

/* Metric Cards */
.metric-card {
  color: white;
  border-radius: 24px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.165, 0.84, 0.44, 1);
  border: none;
  position: relative;
  overflow: hidden;
}

.metric-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 15px 35px rgba(0,0,0,0.15) !important;
}

.metric-icon {
  font-size: 2.5rem;
  opacity: 0.3;
}

.card-footer-action {
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  opacity: 0.8;
}

/* Colores de las tarjetas */
.bg-gradient-blue { background: linear-gradient(135deg, #4e73df 0%, #224abe 100%); }
.bg-gradient-orange { background: linear-gradient(135deg, #f6ad55 0%, #ed8936 100%); }
.bg-gradient-green { background: linear-gradient(135deg, #48bb78 0%, #2f855a 100%); }

/* Banner */
.welcome-banner {
  background: linear-gradient(135deg, #2d3436 0%, #000000 100%);
  border: none;
}

/* Animación */
.animate-fade-in {
  animation: fadeIn 0.6s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>