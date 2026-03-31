# sistema-api-restaurante

Descripción

Este proyecto es una aplicación web desarrollada para la gestión de un restaurante. Permite administrar productos, clientes, pedidos y configuraciones del local, además de generar facturas en PDF.

#Tecnologías utilizadas

-Frontend
Vue.js
Vite
Bootstrap
-Backend
Node.js
Express
-Base de Datos
PostgreSQL

#Instalación y ejecución
1. Clonar el repositorio
git clone <URL_DEL_REPOSITORIO>
2. Backend
cd backend
npm install
npm start
3. Frontend
cd frontend
npm install
npm run dev

#Funcionalidades principales
1. Autenticación de usuarios
2. Gestión de usuarios y roles
3.  Gestión de productos
4.   Registro de pedidos
5.    Gestión de clientes
6.Generación de facturas en PDF
7. Configuración del restaurante (nombre, logo, moneda, etc.)
8. Reportes (solo administrador)

#Roles del sistema
-Administrador
Acceso completo al sistema
Gestión de usuarios, reportes y configuración
-Cajero
Gestión de pedidos, clientes, productos y categorias

#Notas
El sistema permite configurar dinámicamente el logo del restaurante.
Las facturas se generan automáticamente en formato PDF al finalizar una venta.
