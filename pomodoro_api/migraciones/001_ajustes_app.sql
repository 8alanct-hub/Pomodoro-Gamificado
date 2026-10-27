-- Columnas que usa la app y que faltaban en la base de datos.
-- Aplicar una sola vez (Supabase → SQL Editor → Run). Es segura de repetir.

-- Nombre de la mascota (obligatorio al nacer, se puede cambiar en la pantalla 11b).
alter table public.mascotas
  add column if not exists nombre text
  check (nombre is null or char_length(btrim(nombre)) between 1 and 20);

-- Peces atrapados por partida (insignia "Pescador experto").
alter table public.partidas_pesca
  add column if not exists peces integer not null default 0
  check (peces >= 0);

-- Pomodoros por ciclo (RF-006, de 1 a 8).
alter table public.configuracion_pomodoro
  add column if not exists pomodoros_por_ciclo smallint not null default 4
  check (pomodoros_por_ciclo between 1 and 8);
