# Control de Cargas

App web para estimar el **1RM** (repetición máxima) de los ejercicios básicos de fuerza y controlar la carga de entrenamiento de tus atletas semana a semana, para que lleguen a los partidos con el estímulo justo y necesario.

Es un **único archivo HTML autocontenido** (sin backend, sin instalación): los datos se guardan en el navegador (`localStorage`). Se puede abrir directamente el `index.html` o publicarlo gratis con GitHub Pages.

## Qué hace

- **Atletas**: alta/baja de alumnos con peso corporal, deporte y próximo partido.
- **Ejercicios**: catálogo con Sentadilla trasera, Sentadilla al cajón, Peso muerto (Despegue), Banco plano y Dominadas lastradas — más los que quieras agregar. Las dominadas se tratan como carga **relativa al peso corporal** (lastre agregado, puede ser negativo si se usa asistencia).
- **Estimar RM**: cargás peso × repeticiones de un test y calcula el 1RM estimado (fórmulas Epley, Brzycki, Lombardi o promedio, configurable en Ajustes).
- **Planificación semanal**:
  - Armás una **plantilla** con el % de 1RM, series y repeticiones por ejercicio (una sola vez).
  - La **aplicás a todo el plantel** de una vez: cada atleta ve su propio peso sugerido en kg, calculado automáticamente a partir de su RM actual.
  - Después de la sesión cargás lo que realmente levantó (peso real × reps) y el sistema **recalcula el RM** y lo actualiza si corresponde — así la carga se va ajustando semana a semana.
  - Vista imprimible (🖨) para llevar la planilla al gimnasio.
- **Historial**: todos los registros de RM por atleta/ejercicio con gráfico de progresión.
- **Ajustes**: fórmula de cálculo, y **exportar/importar backup en JSON** (recomendado hacerlo seguido, ya que los datos viven solo en este navegador).

## Uso rápido

1. Abrí `index.html` en el navegador (doble clic, o subilo a GitHub Pages).
2. Cargá tus atletas en **Atletas**.
3. Corré un test de fuerza y guardalo en **Estimar RM** para tener el RM base de cada ejercicio.
4. En **Planificación → Plantillas**, armá la semana (ej: "Semana 1 — Base", Sentadilla 4×5 @75%) y aplicala a los atletas que corresponda.
5. Después del entrenamiento, en **Planificación → Semanas por atleta**, cargá lo realmente levantado — el RM se actualiza solo.

## Publicar con GitHub Pages (opcional)

Settings → Pages → Deploy from branch → `main` / `root`. Queda disponible en `https://<usuario>.github.io/control-de-cargas/`.

## Notas

- Todo el cálculo es aproximado (estimación submáxima), no reemplaza un test real de 1RM cuando sea seguro hacerlo.
- Los datos son locales al navegador — no hay login ni sincronización entre dispositivos en esta versión.
