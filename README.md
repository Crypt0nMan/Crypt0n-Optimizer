# Crypt0n Optimizer v1.0

🚀 **Optimización avanzada de Windows con niveles de intensidad y restauración automática.**

Este script permite elegir entre diferentes perfiles de optimización para Windows, con respaldo automático y opción de restauración en caso de problemas.  

---

## ⚠️ Disclaimer  
El uso de este script es **bajo tu propia responsabilidad**.  
El autor no se hace responsable por daños, pérdida de datos o configuraciones alteradas.  

> **Recomendación:** Crea una carpeta exclusiva para el script antes de ejecutarlo. Allí se guardarán los **logs** y **backups** automáticamente.  

---

## 📌 Niveles de Optimización

- **[1] Mínimo** → Ajustes suaves, sin cambios agresivos.  
- **[2] Básico** → Telemetría reducida y limpieza de temporales.  
- **[3] Intermedio** → Deshabilita servicios no críticos, con cambios moderados.  
- **[4] Avanzado** → Debloat moderado y optimización de red.  
- **[5] Ultra** → Debloat agresivo y máxima reducción de procesos.  
- **[R] Restaurar** → Revierte cambios desde el backup más reciente.  
- **[Q] Salir**  

---

## 📝 Funcionalidades

✔️ Deshabilitar telemetría y servicios innecesarios.  
✔️ Limpieza de archivos temporales y cachés.  
✔️ Ajustes de red para mejorar latencia.  
✔️ Eliminación de apps preinstaladas (bloatware).  
✔️ Creación automática de backups antes de aplicar cambios.  
✔️ Restauración con un solo clic mediante `restore.cmd`.  
✔️ Barra de progreso general para ver el avance.  
✔️ Log de todas las acciones realizadas.  

---

## 📂 Estructura generada

```
📁 Crypt0n Optimizer
 ├─ crypt0n_optimizer_v1.0.bat   ← Script principal
 ├─ README.md                    ← Este archivo
 ├─ 📁 backups                   ← Backups automáticos
 ├─ 📁 logs                      ← Registros de cambios
 └─ 📁 assets
      └─ crypt0n-logo.png        ← Logo del proyecto
```

---

## ▶️ Uso

1. Descarga o clona este repositorio:  
   ```bash
   git clone https://github.com/<tu-usuario>/Crypt0n-Optimizer.git
   ```
2. Abre la carpeta del proyecto y ejecuta el archivo:
   ```bash
   crypt0n_optimizer_v1.0.bat
   ```
3. Acepta el **disclaimer** y selecciona el nivel de optimización.  

---

## 🔄 Restauración

En caso de problemas:  
1. Ve a la carpeta `backups`.  
2. Ejecuta `restore.cmd` para revertir al estado anterior.  

---

## 📜 Licencia

Este proyecto se distribuye bajo la licencia **MIT**.  
Eres libre de usarlo, modificarlo y compartirlo, siempre mencionando al autor original.  

---

✨ **Crypt0n Optimizer v1.0 – Tu Windows, más rápido, limpio y ligero.**
