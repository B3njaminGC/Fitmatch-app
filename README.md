# FitMatch App (Flutter)

Probador virtual de talles: cargás tu perfil una vez, la tienda te ordena las prendas
según tus medidas y podés ver cómo te quedan en un maniquí gris hecho a tu medida.

> Marcas, modelos y precios del catálogo son **datos de demostración** (`lib/catalog.dart`).

## ¿Necesito GitHub?

**No.** GitHub solo sirve si no querés instalar Flutter en tu PC.

### Opción A — En tu PC (sin GitHub)

1. Instalá [Flutter](https://docs.flutter.dev/get-started/install) y Android Studio (para el SDK de Android).
2. Verificá que todo esté bien: `flutter doctor`
3. Dentro de esta carpeta:

```
flutter create --platforms=android --project-name fitmatch_app .
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

(`flutter create .` solo agrega la carpeta `android/`; no pisa `lib/` ni `pubspec.yaml`.)

4. El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Pasalo al celular e instalalo
   (habilitá "instalar apps de orígenes desconocidos").

Para probar rápido con el celular conectado por USB: `flutter run`

### Opción B — Con GitHub (sin instalar nada)

Cada compilación deja el APK en la sección **Releases** del repo: lo descargás directo desde el celular.

1. Creá un repositorio y subí **todo el contenido de esta carpeta** (incluida `.github/`).
2. Entrá a la pestaña **Actions** → **Compilar APK** → **Run workflow** (también corre solo en cada push).
3. Cuando termine, abrí la ejecución y bajá el artefacto **fitmatch-apk** (.zip con el `.apk` adentro).

## Qué incluye

- **Onboarding** de 3 pasos (nombre, altura, peso, pecho, cintura, cadera, entrepierna). Se guarda en el teléfono.
- **Inicio**: tienda con prendas ordenadas por cómo te quedan, con badge verde/amarillo/rojo.
- **Buscar** (botón central): por nombre, marca, tipo o corte.
- **Detalle**: veredicto, selector de talle y comparación medida por medida.
- **Probador**: maniquí gris con tus proporciones, la prenda encima, giro con el dedo, cambio de talle en vivo.
- **Para vos**: consejos según contextura y estatura.
- **Perfil**: editás tus medidas cuando quieras.
- **Mis prendas** (Perfil → Mis prendas): cargás tus propias prendas con foto (cámara o galería), marca, precio, corte, color y tabla de talles. Se guardan en el teléfono.

## Veredicto

- 🟢 **Apto para vos**: todas las medidas entran en el rango del talle y el largo es correcto.
- 🟡 **Cuidado**: queda ajustada o suelta, o el largo es muy corto/largo.
- 🔴 **No recomendado**: una medida está a más de 6 cm del rango (físicamente no entra, o queda enorme).

## Estructura

```
lib/
  main.dart        arranque y tema
  models.dart      Perfil, Producto, Talla, Corte
  catalog.dart     catálogo de ejemplo y tablas de talles
  fit.dart         lógica del veredicto y talle sugerido
  mannequin.dart   maniquí 3D falso (CustomPainter con rotación)
  tips.dart        consejos "Para vos"
  assets/icon/     ícono de la app (se aplica con flutter_launcher_icons)
  state.dart       estado + guardado local
  widgets.dart     tarjetas, sliders, badges
  screens/         onboarding, shell (barra inferior), home, search, detail, tryon, profile
```
