-- La API usa la clave secreta (rol service_role). Las tablas se crearon sin
-- darle permisos a ese rol, por eso Supabase respondía 403 al escribir.
-- Aplicar una sola vez (Supabase → SQL Editor → Run). Es segura de repetir.

grant usage on schema public to service_role;
grant select, insert, update, delete on all tables in schema public to service_role;
grant usage, select on all sequences in schema public to service_role;

-- Tablas que se creen después también le darán permisos.
alter default privileges in schema public
  grant select, insert, update, delete on tables to service_role;
alter default privileges in schema public
  grant usage, select on sequences to service_role;
