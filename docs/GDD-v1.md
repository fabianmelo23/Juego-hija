# Casa de Gatos — Diseño de Juego (Versión 1)

Documento vivo. Define qué se construye primero y qué se deja para después.
Público: un juego 2D pixel art para una niña de 11 años a la que le gustan los gatos.

---

## 1. Fantasía central

**Eres una cuidadora de gatos.**  
Llegas a una casita sencilla con un jardín. Tu trabajo (y tu alegría) es cuidar gatos, decorar su hogar y completar encargos sencillos.

Si algo no refuerza “cuidar gatos + hacer un hogar bonito”, no entra en la Versión 1.

---

## 2. Nombre provisional

**Casa de Gatos**

Fácil de decir, claro para ella, y no promete un mundo enorme que aún no existe.  
El nombre final se puede cambiar cuando el prototipo ya se sienta bien.

---

## 3. Experiencia objetivo (los primeros 5 minutos)

1. Aparece en la casita.
2. Conoce a su primer gatito (elige nombre).
3. Lo alimenta y le da cariño.
4. Coloca una cama y un juguete en la habitación.
5. Completa una misión corta y recibe una recompensa pequeña.
6. El gato reacciona (duerme, juega, ronronea).

Eso ya debe sentirse como *su* juego.

---

## 4. Loop de juego (el corazón)

Ciclo que se repite y se siente bien:

```
Observar al gato → Cuidarlo → Decorar / mejorar → Cumplir misión → Recompensa → Nuevo cuidado
```

- **Observar:** el gato tiene necesidades visibles (hambre, energía, humor).
- **Cuidar:** alimentar, acariciar, jugar, dejar dormir.
- **Decorar:** colocar muebles en una habitación.
- **Misión:** objetivo corto con recompensa (objeto, moneda, mueble).
- **Progresar:** más afecto del gato, casa más linda, nuevas tareas.

---

## 5. Alcance de la Versión 1 (MVP)

### Incluye

| Sistema | Qué hace exactamente |
|---|---|
| Mapa pequeño | Interior de casa (1 habitación) + jardín exterior pequeño |
| Jugadora | Personaje 2D que camina, interactúa y coloca muebles |
| Gatos | 1 gato al inicio; hasta 3 en total en V1 |
| Necesidades | Hambre, Energía, Felicidad (3 barras simples) |
| Cuidado | Comer, jugar, acariciar, dormir |
| Decoración | Colocar / guardar muebles en una cuadrícula |
| Inventario simple | Comida, juguetes, muebles |
| Moneda | **Huellitas** (decidido) |
| Controles | 100% táctiles (móvil primero) |
| Misiones | 8–12 encargos cortos con tutorial implícito |
| Guardado | Guardar y cargar progreso local en el teléfono |
| Arte | Pixel art, cámara con seguimiento suave |
| Audio | Música suave + pocos sonidos (maullido, colocar mueble, premio) |

### No incluye en V1 (aunque suene tentador)

- Construir habitaciones nuevas desde cero
- Granja completa (cultivos, estaciones, riego)
- Mundo abierto / varios biomas
- Multijugador
- Combate
- Diálogos largos o historia compleja
- Crafting profundo
- Personalización facial avanzada del avatar

Esas ideas no se descartan: se guardan para V2+ cuando el núcleo ya enganche.

---

## 6. Personajes

### Jugadora
- Niña / joven cuidadora (avatar simple, pixel art).
- Controles táctiles: tap-to-move, tocar para interactuar, botones grandes para inventario y muebles.

### Gatos (V1)

Cada gato tiene:
- Nombre (elegido por la jugadora)
- Color / patrón distinto
- Personalidad simple (afecta animaciones y frases cortas, no IA compleja)
- 3 necesidades: Hambre, Energía, Felicidad

Propuesta inicial:

1. **Gato 1 (inicio):** curioso, sociable — tutorial perfecto.
2. **Gato 2 (desbloqueo temprano):** tímido / dormilón.
3. **Gato 3 (recompensa de misiones):** juguetón / travieso.

---

## 7. Sistemas detallados

### 7.1 Necesidades del gato

| Necesidad | Baja cuando… | Se recupera con… | Si está muy baja… |
|---|---|---|---|
| Hambre | Pasa el tiempo | Comida | Maulla, busca a la jugadora |
| Energía | Jugar / estar activo | Dormir en cama | Se tumba, se niega a jugar |
| Felicidad | Aburrimiento / hambre | Acariciar, jugar, casa bonita | Está triste, menos interacciones “felices” |

Regla de diseño: **nunca castigar con fail states duros.**  
Un gato triste o hambriento pide ayuda; no “pierdes” el juego.

### 7.2 Decoración (sandbox contenido, pensada para dedo)

- Una habitación con cuadrícula **grande y legible** (pocos tiles, no mapa denso).
- Modo construcción: elegir mueble → vista previa fantasma → tocar casilla para colocar.
- Botones grandes: **Colocar / Girar / Guardar / Cancelar**.
- Evitar precisión de “pixel perfecto” con el dedo: la cuadrícula encaja sola (snap).
- Muebles bloquean paso o no, según tipo (cama sí / alfombra no).
- Lista V1 de muebles: cama, plato, árbol rascador, juguete, maceta, alfombra, mesa pequeña, lámpara.

Meta emocional: que ella diga “esta es *mi* habitación de gatos”.

Nota de diseño: en celular pequeño, decorar es más difícil que en tablet/PC. Por eso la V1 usa **una sola habitación**, casillas grandes y pocos muebles a la vez.

### 7.3 Misiones (dirección sin ahogar)

Estructura de una misión:
- Título corto
- Objetivo claro (1 acción)
- Recompensa visible
- Texto breve y cálido (sin párrafos largos)

Ejemplos V1:
1. Ponle nombre a tu gato.
2. Dale de comer.
3. Coloca una cama.
4. Acaricia a tu gato.
5. Compra un juguete en el baúl/tienda simple.
6. Haz que tu gato duerma.
7. Sube la felicidad a “contento”.
8. Da la bienvenida al segundo gato.
9. Decora con 5 muebles distintos.
10. Completa un día de cuidados (rutina).

### 7.4 Economía simple

- Moneda: **Huellitas** (icono de huella de gato).
- Se ganan con misiones y cuidados diarios.
- Se gastan en comida y muebles.
- Precios bajos al inicio para que decorar se sienta inmediato.

Evitar tiendas complejas, rarezas, anuncios o compras dentro de la app en V1.

### 7.5 Día / tiempo (ligero)

- Ciclo día → tarde → noche muy simple (cambio de luz / color).
- De noche los gatos tienen más sueño.
- No hay muerte por tiempo ni pérdida de progreso.

---

## 8. Controles táctiles (móvil primero)

Decisión de producto: **ella juega en celular**, no en PC. Todo se diseña para el dedo desde el día 1.

### Movimiento (recomendado)
- **Tocar el suelo / camino → la jugadora camina hasta ahí** (tap-to-move).
- Más simple para 11 años que un joystick virtual permanente.
- Joystick virtual solo si en pruebas el tap-to-move se siente raro.

### Interacción
- **Tocar un gato / objeto** → se selecciona y aparecen 2–4 acciones grandes (Alimentar, Acariciar, Jugar, Dormir).
- Botones de acción en la parte inferior de la pantalla (zona del pulgar).
- Tamaño mínimo de toque generoso (aprox. 48–56 dp o más).

### Cámara
- Sigue a la jugadora con suavidad.
- Zoom fijo pensado para pantalla de teléfono (nada que pellizcar en V1).
- El mapa V1 debe caber “cómodo” en un celular: casa + jardín compactos.

### Orientación
- **Vertical (portrait)** por defecto: es como ella ya usa el teléfono.
- Horizontal se evalúa después; no complicar V1 con las dos.

---

## 9. Interfaz (para 11 años + celular)

Principios:
- Pocos botones a la vez (máximo 4 acciones visibles).
- Iconos claros + texto corto y grande.
- Barras de necesidades al seleccionar un gato.
- Inventario a pantalla completa o media pantalla, celdas grandes.
- Confirmaciones suaves (“¿Colocar aquí?”) con botones enormes.
- Sin menús anidados profundos.
- HUD que no tape la cara de los gatos.

Pantallas V1:
1. Título / Continuar / Nueva partida
2. Juego (HUD mínimo + acciones inferiores)
3. Inventario
4. Modo colocar muebles
5. Panel de misión
6. Pausa / guardar

---

## 10. Arte y audio

### Pixel art
- Tileset base: **16×16** escalado nítido (nearest neighbor) para verse claro en móvil.
- Paleta limitada y cálida (madera, crema, verdes suaves, acentos coral/salmón — no púrpura genérico).
- Animaciones prioritarias: caminar jugadora, idle/caminar/comer/dormir/jugar del gato.
- Sprites y muebles deben leerse bien en pantallas pequeñas: siluetas claras, poco detalle fino.

### Audio
- 1 tema loop tranquilo para casa/jardín.
- SFX: paso suave, maullido, colocar, premio misión, toque UI.
- Respeta el silencio del teléfono: música suave y fácil de bajar/apagar.

---

## 11. Tecnología

**Motor:** Godot 4  
**Lenguaje:** GDScript  
**Plataforma objetivo V1:** **Celular (Android primero)**  
**Controles:** táctiles únicamente en la experiencia objetivo  
**Distribución familiar V1:** instalar el juego en su teléfono (APK / instalación directa), no hace falta tienda pública al inicio.

### Por qué Android primero
- En familia suele ser más simple probar e instalar builds.
- Si su teléfono es iPhone, hay que planear cuenta de desarrollador / TestFlight; es más fricción. Confirmar marca del teléfono.

### Desarrollo diario
- Se prototipa en el editor de Godot (emulando toques).
- Cada hito importante se exporta a su celular para probar *de verdad* con el dedo.

### Estructura de proyecto propuesta

```
casa-de-gatos/
├── docs/
│   └── GDD-v1.md
├── assets/
│   ├── art/
│   ├── audio/
│   └── fonts/
├── scenes/
│   ├── main_menu/
│   ├── world/
│   ├── player/
│   ├── cats/
│   ├── furniture/
│   └── ui/
├── scripts/
│   ├── player/
│   ├── cats/
│   ├── systems/      # necesidades, misiones, inventario, guardado
│   └── ui/
└── README.md
```

---

## 12. Hitos de desarrollo

### Hito 0 — Esqueleto móvil
- Proyecto Godot creado (viewport vertical)
- Tap-to-move en mapa placeholder
- Cámara suave + colisiones básicas
- Botones UI táctiles de prueba

### Hito 1 — Primer gato vivo
- Gato con 3 necesidades
- Alimentar / acariciar / dormir con botones grandes
- Feedback visual claro en pantalla chica

### Hito 2 — Decoración
- Inventario + colocar 4–5 muebles con snap a cuadrícula
- Guardar layout de la habitación

### Hito 3 — Misiones + economía
- 8 misiones encadenadas suaves
- Huellitas y tienda mínima

### Hito 4 — Pulido jugable para ella
- 2.º y 3.er gato
- Arte más limpio, sonido, guardado robusto
- Export a su celular + sesión de prueba con tu hija

---

## 13. Criterio de éxito de la V1

La Versión 1 está “lista” cuando tu hija puede, **sola en su celular**, sin que le expliques mucho:

1. Cuidar al menos un gato un rato.
2. Decorar la habitación a su gusto.
3. Completar varias misiones.
4. Querer volver mañana a “ver cómo están”.

Si eso ocurre, el juego ya ganó. El resto es expansión.

---

## 14. Decisiones cerradas

| Tema | Decisión |
|---|---|
| Fantasía | Cuidadora de gatos |
| Moneda | **Huellitas** |
| Plataforma V1 | **Celular primero** (Android preferido) |
| Orientación | Vertical |
| Movimiento | Tap-to-move |

## 15. Decisiones pendientes

1. ¿Su teléfono es **Android o iPhone**? (cambia cómo se instala para probar)
2. ¿La jugadora se parece a tu hija o es un personaje inventado?
3. Primer prototipo: ¿placeholders para jugar pronto, o arte pixel desde el día 1?

Defaults si no hay preferencia fuerte:
- Personaje inventado (más libre y menos presión).
- Placeholders primero (llegar antes a sus manos).
