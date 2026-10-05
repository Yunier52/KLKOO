# KLKOO Studio Admin Panel

Panel azul modular para **tu propia experiencia de Roblox Studio**. Incluye Fly, ESP, Speed y High Jump, más dos espacios preparados para futuras opciones. No es un executor ni está pensado para modificar experiencias ajenas.

## Instalación

1. En Roblox Studio, crea un `Script` dentro de `ServerScriptService` y copia el contenido de `Server.server.lua`.
2. Crea un `LocalScript` dentro de `StarterPlayer > StarterPlayerScripts` y copia el contenido de `Client.client.lua`.
3. Prueba el juego con **Play**. El script servidor crea automáticamente `ReplicatedStorage/KLKOO_AdminPanel` y sus remotos.

## Permisos

- En una experiencia propiedad de una cuenta personal, solo el propietario de la experiencia puede abrir el panel automáticamente.
- En una experiencia propiedad de un grupo, añade los `UserId` autorizados a `ADMIN_USER_IDS` al principio de `Server.server.lua`, por ejemplo: `local ADMIN_USER_IDS = {12345678}`. No uses nombres de usuario; usa los IDs numéricos.
- El servidor comprueba el permiso antes de aceptar cambios de Speed o High Jump.

## Controles y valores

- **Fly:** WASD para moverte, Espacio para subir y Ctrl izquierdo para bajar. Velocidad inicial: `55`.
- **ESP:** resalta otros personajes para depuración visual; el resaltado atraviesa paredes.
- **Speed:** fija WalkSpeed a `32` y restaura el valor anterior al apagarlo.
- **High Jump:** fija JumpPower a `100` y restaura los valores anteriores al apagarlo.
- **CERRAR / X:** apaga las opciones activas y elimina la interfaz. Vuelve a entrar o reinicia el `LocalScript` para abrir el panel otra vez.

Los valores se pueden ajustar en la tabla `SETTINGS` del script servidor y en `flySpeed` del LocalScript. Fly y ESP son herramientas locales de depuración; deben reservarse para administradores de tu experiencia.
