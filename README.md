# Control de Cargas

App web para trabajo **individual y personalizado** con cada alumno: estimar el **1RM** de los ejercicios básicos de fuerza, y controlar su carga de entrenamiento sesión a sesión para tocar zonas altas de fuerza máxima (%1RM) sin acumular fatiga de más, de cara a los partidos.

Los datos viven en la nube (**Supabase**), no en el navegador: el coach entra con email y contraseña, y cada alumno puede entrar desde **su propio celular** a ver su semana y cargar sus datos, sincronizado en tiempo real con lo que carga el coach.

## Qué hace

- **Login del coach**: acceso con email/contraseña (Supabase Auth). Cada coach ve únicamente sus propios atletas.
- **Atletas**: alta de cada alumno (nombre y apellido) con peso corporal, deporte y próximo partido.
- **Ejercicios**: catálogo con Sentadilla trasera, Sentadilla al cajón, Peso muerto (Despegue), Banco plano y Dominadas lastradas — más los que quieras agregar. Las dominadas se tratan como carga **relativa al peso corporal** (lastre agregado, puede ser negativo si se usa asistencia).
- **Estimar RM**: cargás peso × repeticiones de un test y calcula el 1RM estimado (fórmulas Epley, Brzycki, Lombardi o promedio, configurable en Ajustes).
- **Progresión por ejercicio (sobrecarga progresiva)**: en el perfil de cada alumno, cada ejercicio tiene su propia tabla con **todo el historial de peso × repeticiones sesión a sesión**, con la variación (▲/▼ kg) contra el registro anterior.
- **Planificación individual por sesión**:
  - El **RM cambia día a día**: antes de ir a la carga de trabajo, podés cargar un **chequeo del día** (una serie de aproximación) y la app recalcula al instante el peso sugerido para ese %1RM en base a cómo está el atleta *hoy*.
  - **Presets de sesión** (opcional): esquema de %1RM/series/reps reutilizable, se carga en la sesión de un alumno puntual.
  - Después de la serie de trabajo cargás lo que realmente levantó (peso × reps × RPE) y el sistema decide si conviene **actualizar el RM de referencia**.
  - Vista imprimible (🖨) para llevar la planilla al gimnasio.
- **Historial**: todos los registros de RM por atleta/ejercicio (tests, chequeos del día, sesiones y autogestión) con gráfico de progresión.
- **Modo Jugador**: cada alumno entra desde **su propio celular** con el link `?jugador` (ver más abajo), sin login — solo toca su nombre (y un PIN opcional). Ahí puede:
  - ver **su semana** (sesiones del coach, con el %1RM de cada ejercicio),
  - **+ Registrar**: cargar cualquier ejercicio por su cuenta, sin depender de que el coach le arme una sesión,
  - hacer su propio **chequeo del día** y cargar lo que realmente levantó (peso × reps × RPE),
  - ver **su progreso** semana a semana por ejercicio.
- **Gestión de bajas**: dar de baja a un atleta que dejó de entrenar (reversible, no borra nada) o eliminarlo permanentemente.
- **Ajustes**: fórmula de cálculo, cerrar sesión, y exportar/importar backup en JSON.

## Cómo entrar

- **Coach**: `https://<tu-usuario>.github.io/control-de-cargas/` → email y contraseña.
- **Atletas** (cada uno desde su propio celular, sin login): `https://<tu-usuario>.github.io/control-de-cargas/?jugador`

## Arquitectura (Supabase)

Todo el backend vive en un proyecto de Supabase (gratis):

- **Tablas** `athletes`, `exercises`, `records`, `templates`, `weeks`, `coach_settings` — protegidas con Row Level Security: cada fila pertenece a un `coach_id` y solo ese coach autenticado puede leerla o escribirla.
- **Funciones RPC** `player_list_athletes`, `player_get_state`, `player_add_record`, `player_update_week_item` — corren con privilegios elevados (`security definer`) pero verifican el PIN del atleta del lado del servidor y solo exponen/tocan los datos de ESE atleta puntual. Así el Modo Jugador funciona sin que el atleta tenga una cuenta.
- El esquema completo (tablas, RLS, funciones) está pensado para correrse una sola vez desde el SQL Editor de Supabase.
- La URL del proyecto y la clave pública (`anon`/`publishable`) están embebidas en `index.html` — es el modelo normal de Supabase: la clave pública es segura de exponer porque RLS es lo que realmente protege los datos, no el secreto de la clave.

### Alta de un coach nuevo

Como no hay pantalla de registro pública (a propósito, para no exponer altas de cuentas sin control), cada coach se crea a mano:

Supabase → **Authentication → Users → Add user** → cargar email + contraseña (tildar "Auto Confirm User" si aparece la opción). Con eso ya puede entrar por el login normal de la app.

## Notas

- Todo el cálculo de RM es aproximado (estimación submáxima), no reemplaza un test real de 1RM cuando sea seguro hacerlo.
- Conviene exportar un backup (Ajustes → Exportar) de tanto en tanto, aunque los datos vivan en la nube.
