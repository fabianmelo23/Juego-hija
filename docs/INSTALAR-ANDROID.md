# Instalar Casa de Gatos en tu celular Android

Este es un APK de **prueba (debug)** para que veas el juego pronto.
No es de Play Store.

## 1) Consigue el archivo

Archivo: **`CasaDeGatos.apk`**

En Cursor (agente en la nube) suele estar en los **artifacts** del run.  
También se genera en la carpeta del proyecto: `build/CasaDeGatos.apk`.

Pásalo a tu celular (WhatsApp, Drive, cable USB, etc.).

## 2) Permite instalar apps

En tu Android:

1. Abre **Ajustes**
2. Busca **Instalar apps desconocidas** / **Fuentes desconocidas**
3. Actívalo para Chrome, Files, Drive o la app con la que abras el APK

(El nombre exacto cambia según la marca del teléfono.)

## 3) Instala

1. Abre el archivo `CasaDeGatos.apk`
2. Pulsa **Instalar**
3. Abre **Casa de Gatos**

## 4) Qué puedes probar ya

- Caminar tocando el suelo
- Cuidar a **Miel** (Comer / Mimos / Jugar / Dormir)
- **Mochila** → colocar muebles en la casa
- **Misión** y **Tienda** con Huellitas

## Notas importantes

- Es un prototipo con **placeholders** (formas de color), no pixel art final.
- Cada vez que hagamos cambios grandes, generaremos un APK nuevo.
- Si al reinstalar dice conflicto de firma, desinstala la versión anterior y vuelve a instalar.

## Para volver a generar el APK (entorno de desarrollo)

```bash
bash tools/build_android_apk.sh
```
