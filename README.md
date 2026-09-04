# Control de Cargas

App web para trabajo **individual y personalizado** con cada alumno: estimar el **1RM** de los ejercicios básicos de fuerza, y controlar su carga de entrenamiento sesión a sesión para tocar zonas altas de fuerza máxima (%1RM) sin acumular fatiga de más, de cara a los partidos.

Es un **único archivo HTML autocontenido** (sin backend, sin instalación): los datos se guardan en el navegador (`localStorage`). Se puede abrir directamente el `index.html` o publicarlo gratis con GitHub Pages.

## Qué hace

- **Atletas**: alta de cada alumno (nombre y apellido) con peso corporal, deporte y próximo partido. Cada atleta tiene su propia sección — no hay nada compartido entre alumnos.
- **Ejercicios**: catálogo con Sentadilla trasera, Sentadilla al cajón, Peso muerto (Despegue), Banco plano y Dominadas lastradas — más los que quieras agregar. Las dominadas se tratan como carga **relativa al peso corporal** (lastre agregado, puede ser negativo si se usa asistencia).
- **Estimar RM**: cargás peso × repeticiones de un test y calcula el 1RM estimado (fórmulas Epley, Brzycki, Lombardi o promedio, configurable en Ajustes).
- **Progresión por ejercicio (sobrecarga progresiva)**: en el perfil de cada alumno, cada ejercicio tiene su propia tabla con **todo el historial de peso × repeticiones sesión a sesión**, con la variación (▲/▼ kg) contra el registro anterior — para ver de un vistazo cómo va evolucionando la carga.
- **Planificación individual por sesión**:
  - El **RM cambia día a día**: antes de ir a la carga de trabajo, podés cargar un **chequeo del día** (una serie de aproximación) y la app recalcula al instante el peso sugerido para ese %1RM en base a cómo está el atleta *hoy*, no a un test de hace semanas — así se toca fuerza máxima real sin pasarse de rosca.
  - **Presets de sesión** (opcional): guardás un esquema de %1RM/series/reps reutilizable (ej. "Fuerza máxima — baja fatiga") para no tener que tipearlo cada vez; se carga en la sesión de un alumno puntual, nunca se aplica a otros automáticamente.
  - Después de la serie de trabajo cargás lo que realmente levantó (peso × reps × RPE) y el sistema decide si conviene **actualizar el RM de referencia**.
  - Vista imprimible (🖨) para llevar la planilla al gimnasio.
- **Historial**: todos los registros de RM por atleta/ejercicio (tests, chequeos del día y sesiones) con gráfico de progresión.
- **Modo Jugador**: desde el mismo dispositivo (la tablet/PC del gimnasio), cada alumno toca su nombre y entra a su propia vista — sin ver ni tocar datos de otros atletas. Ahí puede:
  - ver **su semana** (sesiones anteriores y la actual, con el %1RM de cada ejercicio),
  - hacer su propio **chequeo del día** y cargar lo que realmente levantó (peso × reps × RPE),
  - ver **su progreso** semana a semana por ejercicio.
  Cada atleta puede tener un PIN propio (opcional, se configura al editarlo). Volver de Modo Jugador al panel del coach puede protegerse con un PIN del coach (Ajustes).
- **Ajustes**: fórmula de cálculo, PIN del coach, y **exportar/importar backup en JSON** (recomendado hacerlo seguido, ya que los datos viven solo en este navegador).

## Uso rápido

1. Abrí `index.html` en el navegador (doble clic, o subilo a GitHub Pages).
2. Cargá a tu alumno en **Atletas** (nombre, apellido, peso corporal).
3. Corré un test de fuerza y guardalo en **Estimar RM** para tener el RM de referencia de cada ejercicio.
4. En **Planificación → Sesiones del atleta**, creá una sesión para ese alumno (podés partir de un preset de %1RM/series/reps o armarla en blanco).
5. Antes de la serie de trabajo, hacé el **chequeo del día** — la app ajusta el peso sugerido a cómo está hoy.
6. Después de entrenar, cargá lo realmente levantado (peso × reps × RPE): queda guardado en la progresión de ese ejercicio y, si corresponde, actualiza el RM de referencia.
7. Si querés que el alumno cargue sus propios datos, tocá **Modo Jugador** en el menú — el alumno entra con su nombre (y su PIN, si le pusiste uno) desde el mismo dispositivo.

## Publicar con GitHub Pages (opcional)

Settings → Pages → Deploy from branch → `main` / `root`. Queda disponible en `https://<usuario>.github.io/control-de-cargas/`.

## Notas

- Todo el cálculo es aproximado (estimación submáxima), no reemplaza un test real de 1RM cuando sea seguro hacerlo.
- Los datos son locales al navegador — no hay login ni sincronización entre dispositivos en esta versión.
