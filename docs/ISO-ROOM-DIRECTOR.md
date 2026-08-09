# Casa de Gatos — Dirección de Diseño Isométrico

**Rol:** Dirección creativa / diseño ejecutivo  
**Decisión de producto:** el espacio principal pasa a **habitación isométrica** (estilo Habbo / simulación cozy), no top-down.  
**Fantasía intacta:** cuidadora de gatos + hogar bonito + misiones + Huellitas.

---

## 1. Visión (una frase)

Un **cuarto isométrico vivo** que tu hija puede transformar piso a piso, pared a pared y mueble a mueble, mientras cuida a sus gatos dentro de ese espacio.

---

## 2. Decisiones ejecutivas (cerradas)

| Tema | Decisión |
|---|---|
| Perspectiva | Isométrica 2:1 (diamante clásico) |
| Plataforma | Android vertical |
| Arte | Pixel art isométrico (placeholders → assets finales ítem a ítem) |
| Tamaño de tile | **64×32 px** (base) |
| Habitación V1 | **8×8 tiles** jugables |
| Cámara | Fija / leve seguimiento, sin rotar el mundo |
| Colocación | Snap a grid + altura de capa |
| Lo que NO hacemos aún | Mundo abierto, varias casas, granja, multiplayer |

**Por qué 8×8:** en celular se lee claro; decorar no se vuelve un laberinto de precisión.

---

## 3. Capas del cuarto (orden de pintura / depth)

De atrás-abajo hacia adelante-arriba:

1. **Shell** — piso base + dos paredes (norte / oeste en iso)
2. **Surface** — alfombras / acabados de piso
3. **Openings** — ventana, puerta (recortes o overlays en pared)
4. **Furniture low** — plato, alfombra gruesa, juguete en suelo
5. **Furniture mid** — cama, mesa, rascador, sillón
6. **Furniture tall** — estantería, árbol, lámpara de pie
7. **Wall decor** — cuadros, reloj, estante de pared
8. **Lighting FX** — luz de techo, brillos, noche/día
9. **Characters** — jugadora + gatos (siempre encima del mueble que pisan, con sort correcto)

---

## 4. Catálogo maestro — todo lo modificable

Cada ítem tiene: **ID · Nombre · Categoría · Huella (tiles) · Capa · Variantes · Estado**

### A. Shell del cuarto (el “continente”)

| # | ID | Nombre | Qué se modifica | Prioridad |
|---|---|---|---|---|
| 01 | `floor_base` | Piso base | Material/color del piso completo | **P0 — ahora** |
| 02 | `wall_left` | Pared izquierda (oeste) | Color / material | P0 |
| 03 | `wall_right` | Pared derecha (norte) | Color / material | P0 |
| 04 | `wallpaper` | Papel tapiz | Patrón sobre paredes | P1 |
| 05 | `trim` | Zócalo / moldura | Detalle inferior de pared | P2 |
| 06 | `ceiling` | Techo (opcional V1) | Color / vigas | P2 |

### B. Aberturas

| # | ID | Nombre | Notas |
|---|---|---|---|
| 07 | `window_small` | Ventana pequeña | Luz día/noche |
| 08 | `window_wide` | Ventana ancha | Variante premium |
| 09 | `door_wood` | Puerta | Salida simbólica (aún sin otro mapa) |
| 10 | `curtain` | Cortina | Overlay de ventana |

### C. Iluminación

| # | ID | Nombre | Notas |
|---|---|---|---|
| 11 | `light_ceiling` | Lámpara de techo | Cambia mood del cuarto |
| 12 | `lamp_floor` | Lámpara de pie | 1×1, luz local |
| 13 | `lamp_table` | Lámpara de mesa | Requiere superficie |
| 14 | `string_lights` | Luces colgantes | Decorativo |

### D. Acabados de piso

| # | ID | Nombre | Huella |
|---|---|---|---|
| 15 | `rug_small` | Alfombra chica | 2×2 |
| 16 | `rug_round` | Alfombra redonda | 2×2 |
| 17 | `rug_runner` | Alfombra larga | 1×3 |
| 18 | `mat_cat` | Tapete de gato | 1×1 |

### E. Mobiliario felino (núcleo del juego)

| # | ID | Nombre | Huella | Gameplay |
|---|---|---|---|---|
| 19 | `bed_cat` | Cama de gato | 2×2 | Dormir |
| 20 | `bowl_food` | Plato comida | 1×1 | Comer |
| 21 | `bowl_water` | Plato agua | 1×1 | (V1.1) |
| 22 | `scratcher` | Rascador | 1×2 | Jugar / felicidad |
| 23 | `cat_tree` | Árbol rascador | 2×2 | Jugar |
| 24 | `toy_ball` | Pelota | 1×1 | Jugar |
| 25 | `toy_mouse` | Ratón de juguete | 1×1 | Jugar |
| 26 | `cat_house` | Casita | 2×2 | Dormir / esconderse |

### F. Mobiliario de hogar

| # | ID | Nombre | Huella |
|---|---|---|---|
| 27 | `table_low` | Mesa baja | 2×2 |
| 28 | `shelf` | Estantería | 1×2 |
| 29 | `plant_pot` | Maceta | 1×1 |
| 30 | `plant_tall` | Planta alta | 1×1 |
| 31 | `cushion` | Cojín | 1×1 |
| 32 | `basket` | Cesta | 1×1 |

### G. Decoración de pared

| # | ID | Nombre |
|---|---|---|
| 33 | `frame_photo` | Marco foto |
| 34 | `frame_art` | Cuadro |
| 35 | `wall_shelf` | Repisa |
| 36 | `clock` | Reloj |

### H. Ambientes (presets de mood, no objetos sueltos)

| # | ID | Nombre | Qué cambia |
|---|---|---|---|
| 37 | `mood_day` | Día | Luz ventana + techo suave |
| 38 | `mood_evening` | Tarde | Naranja cálido |
| 39 | `mood_night` | Noche | Azul + lámparas |

---

## 5. Orden de creación (ítem a ítem)

Trabajamos **uno por uno**. No se salta de categoría sin cerrar el shell.

### Fase P0 — Habitación existe
1. **01 `floor_base`** ✅ hecho (3 variantes de piso)  
2. **02 `wall_left`** ✅ hecho (crema / rubor / salvia)  
3. **03 `wall_right`** ✅ hecho (crema / rubor / salvia) — **shell P0 cerrado**  
4. Validación visual en celular (APK)

### Fase P1 — Habitación respira
5. **07 `window_small`** ✅ hecho (Día / Tarde / Noche + mood de fondo)  
6. **11 `light_ceiling`** ✅ hecho (Cálida / Rosa / Apagada + mood combinado)  
7. **04 `wallpaper`** ✅ hecho (Ninguno / Puntos / Rayas)  
8. **15 `rug_small`** ✅ hecho (Ninguna / Rubor / Salvia / Cielo) — **P1 cerrado**

### Fase P2 — Habitación jugable con gatos
9. **19 `bed_cat`** ✅ hecho (Ninguna / Crema / Rubor / Menta)  
10. **20 `bowl_food`** ✅ hecho (Ninguno / Lleno / Medio / Vacío)  
11. **22 `scratcher`** ✅ hecho (Ninguno / Madera / Rubor / Menta)  
12. **24 `toy_ball`** ✅ hecho (Ninguna / Roja / Cielo / Sol)  
13. **Migrar Miel + cuidados** ✅ hecho (Cuidar / misiones / tienda golosina)  
14. **Colocación libre en grid iso** ✅ hecho (tocar piso para mover + guardado)

### Fase P3 — Personalidad del espacio
15–36 según demanda de tu hija / misiones / tienda

---

## 6. Pipeline de cada ítem (cómo lo creo yo)

Para **cada** ID:

1. **Spec** — nombre, huella, capa, colisión, si bloquea paso  
2. **Arte** — PNG pixel art isométrico (o placeholder diamante fiel a medida)  
3. **Escena Godot** — nodo con `footprint`, `anchor`, `sort_y`  
4. **Registro en catálogo** — aparece en Mochila/Tienda cuando toque  
5. **Prueba** — se coloca, se guarda, se ve bien en 8×8  
6. **Commit** — queda versionado

Regla de calidad: si un ítem no se entiende a **64×32 / footprint**, no entra.

---

## 7. Spec técnico rápido

```
Tile: 64×32 px
screen_x = (x - y) * 32
screen_y = (x + y) * 16

Room: 8×8
Origen visual: centrado en viewport vertical 720×1280
```

**Estados de un tile de piso:** `wood_light` · `wood_warm` · `pastel_blue` (variantes del #01)

---

## 8. Qué pasa con el prototipo actual

No se tira a la basura:
- Cuidados, misiones, Huellitas y tienda **se conservan como sistemas**
- El mapa top-down queda como referencia legacy
- El nuevo escenario principal será el **cuarto isométrico**

---

## 9. Criterio de éxito de esta fase visual

Tu hija abre el APK y dice algo cercano a:

> “Se ve como un cuartito de verdad… quiero cambiar el piso / la ventana / la cama.”

Hasta que el shell (piso + 2 paredes) no esté sólido, no avanzamos a 20 muebles a medias.

---

## 10. Siguiente acción inmediata

Pulir arte de paredes/muebles, más superficies apilables, y animaciones de Miel.
