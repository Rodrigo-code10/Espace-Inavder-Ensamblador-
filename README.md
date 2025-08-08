# 🛸Space Invaders en Ensamblador  

Este proyecto es una recreación del clásico **Space Invaders** programado en **lenguaje ensamblador x86** utilizando **TASM** y el **modo gráfico 12h (640x480, 16 colores)**.  
El juego incluye mecánicas completas: movimiento del jugador, disparos, enemigos organizados en filas, detección de colisiones, puntajes, vidas, y almacenamiento de puntuaciones en un archivo.

## 🚀 Características principales
- **Interfaz gráfica** en modo video 12h.
- **Título y menú** 
- **Movimiento del jugador** con teclas de flecha.
- **Disparo de balas** (jugador y enemigos).
- **Enemigos animados** con diferentes tipos y puntajes.
- **Detección de colisiones** jugador-enemigo y bala-enemigo.
- **Sistema de puntuación** con sumas en BCD y almacenamiento.
- **Registro de jugadores recientes** en `PLAYERS.txt`.
- **Botón gráfico** con detección de doble clic para guardar puntajes.
- **Reinicio de partida** con tecla `F1`.

## 👽 Estructura del código
### 1. **Macros**
- `CUADRO_MAC`: Dibuja bloques de píxeles (base para todas las figuras).
- `DIBUJAR_JUGADOR`: Convierte coordenadas de posición a píxeles y dibuja la nave.
- `DIBUJAR_INVADERS`: Itera y dibuja los 50 invasores activos.
- `CHECAR_COLISION`: Verifica colisiones entre balas del jugador y enemigos.
- `COLISION_PERSONAJE`: Detecta colisiones entre balas enemigas y el jugador.
- `suma`: Suma de puntajes en formato BCD.

### 2. **Procedimientos**
- **Pantallas**:  
  - `VENTANA1`: Título del juego.  
  - `VENTANA2`: Selección de apodo y visualización de puntajes por tipo de enemigo.  
  - `VENTANA3`: Tabla de jugadores recientes desde `PLAYERS.txt`.  
  - `VENTANA4`: Juego principal.  
  - `VENTANA5`: Pantalla de *Game Over*.  
  - `VENTANA6`: Confirmación para guardar puntaje.  
- **Dibujo de nave y enemigos**: `DNAVE`, `CARGA_INVADERS`, depende del tipo.  
- **Reseteo de variables**: `RESETEAR_VARIABLES`.  
- **Gestión de archivos**: Lectura y escritura de puntajes.  

## 🪐 Controles
| Acción | Tecla / Botón |
|--------|---------------|
| Mover jugador | Flechas |
| Disparar | Espacio |
| Salir | ESC |
| Reiniciar juego | F1 |
| Guardar puntaje | Mouse (doble clic) |

## 🛰️ Archivos relacionados
- **`PFINAL.asm`** → Código fuente principal.
- **`MACROS.LIB`** → Macros de soporte (dibujo, lectura de teclado, manejo de archivos, etc.).
- **`PLAYERS.txt`** → Archivo donde se guardan los puntajes y apodos de los jugadores.
