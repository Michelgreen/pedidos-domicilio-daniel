# 🍔 ProntoBite Delivery - Aplicación de Pedidos de Comida a Domicilio

**Alumno:** Daniel Michel Cruz Verde  
**Materia:** Desarrollo Móvil Integral (Remedial del Segundo Parcial – SABER HACER)  
**Docente:** Dolores Abril Sánchez Camacho  
**Framework:** Flutter (Dart) + Firebase Cloud Firestore  

---

## 📋 Descripción del Proyecto

**ProntoBite Delivery** es una aplicación móvil y multiplataforma desarrollada desde cero con **Flutter**, integrada en tiempo real con **Firebase Cloud Firestore** como base de datos en la nube. Permite consultar el menú de platillos destacados, registrar pedidos de comida a domicilio con validación estricta de datos y visualizar/actualizar el estado de los pedidos en tiempo real.

---

## ✅ Cumplimiento de Requerimientos de la Rúbrica

### 1. Creación y configuración del proyecto (10%)
- Proyecto inicializado con `flutter create --org com.danielcruz pedidos_domicilio_daniel`.
- Estructura modular organizada en `lib/config`, `lib/models`, `lib/services` y `lib/screens`.
- Dependencias oficiales configuradas en `pubspec.yaml`: `firebase_core`, `cloud_firestore`, `firebase_auth`, `intl`.

### 2. Diseño de interfaces (10%)
- **Acceso (AuthScreen):** Registro e inicio de sesión con correo y contraseña mediante Firebase Authentication.
- **Pantalla Principal (`HomeScreen`):** Encabezado con estado de conexión en vivo, métricas en tiempo real (total de pedidos en BD, pedidos en curso y ventas totales) y catálogo interactivo de platillos.
- **Formulario de Registro (`FormularioPedidoScreen`):** Selección de platillo, control de cantidad, datos del cliente, teléfono, dirección, método de pago y cálculo automático de subtotal + envío.
- **Apartado de Visualización (`ListaPedidosScreen`):** Consulta en tiempo real, filtros por estado y controles según rol.\n- **Panel del restaurante:** Administración de pedidos, menú y clientes; su acceso se valida con la cuenta admin verificada.

### 3. Conexión a servicios en la nube (20%)
- Proyecto en Firebase Console: **`pedidos-domicilio-daniel`**.
- Base de datos NoSQL en la nube: **Cloud Firestore**, colección principal **`pedidos`**.

### 4. Registro y almacenamiento de información (20%)
- Escritura asíncrona mediante `FirebaseFirestore.instance.collection('pedidos').add(...)`.
- Lectura reactiva en vivo con `.snapshots()` que actualiza la interfaz instantáneamente al insertar o modificar documentos.

### 5. Validaciones y seguridad (10%)
- Validación en interfaz con `GlobalKey<FormState>`:
  - Prevención total de registros vacíos.
  - Nombre del cliente obligatorio (mínimo 4 caracteres).
  - Teléfono numérico obligatorio de exactamente 10 dígitos (`FilteringTextInputFormatter.digitsOnly`).
  - Dirección de entrega obligatoria (mínimo 10 caracteres).
- Validación en capa de servicio (`PedidoService`) y en servidor mediante reglas de seguridad de Firestore (`firestore.rules`).
- Protección de credenciales con soporte para `--dart-define` en [`firebase_options.dart`](lib/config/firebase_options.dart) y exclusión de archivos sensibles (`.env`, `*.jks`, `key.properties`) en `.gitignore`.

### 6. Control de versiones (10%)
- Repositorio Git estructurado con historial de commits descriptivos para cada etapa del desarrollo.

### 7. Despliegue y distribución (20%)
- **Compilación Android (`.apk`):**
  ```bash
  flutter build apk --release
  ```
  El archivo instalable se genera en `build/app/outputs/flutter-apk/app-release.apk` (también automatizado mediante GitHub Actions en `.github/workflows/build_and_deploy.yml`).
- **Compilación Web / PWA (para URL de evaluación e instalación en iPhone):**
  ```bash
  flutter build web --release
  ```
  La carpeta `build/web` se despliega en Firebase Hosting para obtener la URL pública e instalarla en iOS desde Safari (*Compartir -> Agregar a pantalla de inicio*).

---

## 🛠️ Procedimiento de Compilación y Ejecución

1. **Clonar el repositorio e instalar dependencias:**
   ```bash
   git clone <URL_DEL_REPOSITORIO_GITHUB>
   cd pedidos_domicilio_daniel
   flutter pub get
   ```
2. **Ejecutar en modo desarrollo:**
   ```bash
   flutter run -d chrome
   ```
3. **Generar versión compilada para Web (URL e iPhone PWA):**
   ```bash
   flutter build web --release
   ```
4. **Generar archivo instalable APK (Android):**
   ```bash
   flutter build apk --release
   ```

## Configuración de Firebase requerida

- Registra la app Android con paquete com.danielcruz.pedidos_domicilio_daniel y configura Android y Web en el proyecto Firebase.
- Ejecuta dart pub global activate flutterfire_cli y después flutterfire configure --project=pedidos-domicilio-daniel --platforms=android,web --out=lib/config/firebase_options.dart para generar opciones correctas por plataforma.
- Habilita Correo/contraseña en Authentication. Crea y verifica desde Firebase Console la cuenta michelcv.ti23@utsjr.edu.mx; el código no contiene contraseña de administrador.
- Despliega las reglas revisadas con firebase deploy --only firestore:rules --project pedidos-domicilio-daniel.
- El workflow compila y sube artefactos a GitHub Actions; Hosting se publica por separado. firebase.json ya apunta a build/web y asocia las reglas de Firestore.
