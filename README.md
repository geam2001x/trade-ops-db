# Trade Ops DB

Capa de base de datos del sistema `Trade Operations Suite`.

## Estado

Base inicial creada.
Todavia no existen migraciones ni automatizacion de despliegue.

## Objetivo

Centralizar:

- modelo de datos fase 1
- schema inicial
- seeds
- notas de integridad
- futuras migraciones

## Archivos actuales

- `schema.sql`
- `seed-reference-data.sql`

## Uso inicial

Crear schema y tablas:

```bash
mysql -u root -p < schema.sql
```

Cargar datos base:

```bash
mysql -u root -p < seed-reference-data.sql
```

## Nota

La base creada por este schema se llama:

```text
trade_operations_suite
```
