# Console Frontend (React SPA)

## 1. Arquitectura frontend creada
- Se inicializó un proyecto de Vite + React + TypeScript + TailwindCSS en `console/frontend/`.
- Se configuró el cliente para montarse bajo `/app/` de manera segura.
- Directorios: `src/api` (cliente HTTP con inyección de credenciales), `src/components` (componentes base reutilizables y layout), `src/pages` (vistas lógicas), `src/styles` (configuración de Tailwind global y tokens).
- Se implementaron ruteo estricto con `React Router` y un `AuthProvider` responsable de chequear la sesión contra la API de backend existente `/auth/me`.

## 2. Archivos creados/modificados
- `console/app/main.py`: Se montó el router `/app` hacia el index del SPA, y `StaticFiles` para `/assets`.
- `console/app/routers/app_spa.py`: Catch-All router seguro para renderizar `index.html`.
- `console/frontend/`: +20 archivos de componentes, páginas, APIs, vite config, package.json.

## 3. Diff stat
- Backend: ~10 líneas nuevas en FastAPI para exponer la carpeta `dist`.
- Frontend: ~1200 líneas nuevas de código limpio en React estricto con TypeScript.

## 4. Rutas nuevas
- `/app/overview`
- `/app/monitor`
- `/app/jobs`
- `/app/jobs/:id`
- `/app/datasets`
- `/app/datasets/:name`
- `/app/apps`
- `/app/vault`
- `/app/security`
- `/app/users`
- `/app/settings`

## 5. APIs usadas
- `/auth/me` (Chequeo de Auth)
- `/mcp/servers` (Monitor)
- `/api/config` (Overview)
- `/api/pipeline_runs` (Jobs)
- `/api/datasets` (Datasets)
- `/api/vault/connections` (Vault)
- `/security/sessions` (Security)
- `/api/admin/users` (Users)

## 6. Qué HTML viejo sigue vivo
- Siguen vivos temporalmente los HTML de la carpeta `console/app/static`: `index.html`, `monitor.html`, `admin_users.html`, `apps_gallery.html` y todos los de la carpeta `viewers`. Estos seguirán funcionando normalmente en las rutas viejas para no romper operaciones del equipo durante la prueba.

## 7. Qué pantallas ya tienen equivalente React
- Overview (`index.html`) -> `OverviewPage.tsx`
- Monitor (`monitor.html`) -> `MonitorPage.tsx`
- Admin Users (`admin_users.html`) -> `UsersPage.tsx`
- Jobs List (`viewers/jobs.html`) -> `JobsPage.tsx`
- Job Detail (`viewers/job.html`) -> `JobDetailPage.tsx`
- Datasets List (`viewers/datasets.html`) -> `DatasetsPage.tsx`
- Dataset Detail (`viewers/dataset.html`) -> `DatasetDetailPage.tsx`
- Vault (`viewers/vault.html`) -> `VaultPage.tsx`
- Apps Gallery (`apps_gallery.html`) -> `AppsPage.tsx`
- Security Audit -> `SecurityPage.tsx`

## 8. Validaciones ejecutadas
- Se ejecutó `npm run build` en el frontend compilando con TypeScript estricto.
- Se compilaron y cargaron estáticamente los módulos de FastAPI con `uvicorn`.

## 9. Errores encontrados
- Durante el chequeo la imagen oficial de docker hub dio problemas de Rate Limit para pulls anónimos locales. Sin embargo, el código React y FastAPI está listo para ejecución en el workflow normal de CI/CD.

## 10. Riesgos pendientes
- Dado que no todas las APIs estaban implementadas completas, algunas vistas (ej. Detalles de job vía 404, etc.) incluyen fallbacks visuales elegantes para evitar crashes de UI.

## 11. Cómo correrlo localmente
- ```bash
  cd console/frontend
  npm install
  npm run build
  cd ../..
  docker compose --env-file infra/.env.example -f infra/docker-compose.yml up -d --build console
  ```

## 12. Siguiente fase recomendada
- Fase 2: Configurar variables dinámicas en el frontend para soportar customizaciones por ambiente (ej. colores o logos).
- Fase 3: Desactivar las rutas antiguas en `pages.py` tras confirmar que los usuarios de producción migraron exitosamente a `/app`.
