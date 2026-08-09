# Casa de Gatos

Juego 2D pixel art para **Android**, pensado para una niña de 11 años a la que le gustan los gatos.

**Fantasía:** eres una cuidadora de gatos.  
**Moneda:** Huellitas.  
**Plataforma V1:** Android (vertical, táctil).  
**Arte inicial:** placeholders.  
**Avatar:** personaje inventado.

## Instalación (entorno de desarrollo)

Ya hay un instalador automático de Godot 4.3:

```bash
bash tools/install_godot.sh
```

Eso deja el comando `godot` listo e importa el proyecto.

Para abrir el prototipo:

```bash
godot --path .
```

O en Godot: **Import** → carpeta del proyecto → Play (F5).  
Haz clic/tocar el suelo para caminar.

## Estado actual

**Hito 0 listo:** mapa casa+jardín, tap-to-move, HUD táctil, Huellitas.  
Diseño: [`docs/GDD-v1.md`](docs/GDD-v1.md)

## Nota sobre el celular

La instalación en el teléfono Android de ella se hace con un archivo APK (más adelante).  
Desde aquí se prepara el juego; en el teléfono solo hay que permitir instalar e instalar el APK.
