-- Creates a constraint on a chunk.
CREATE OR REPLACE FUNCTION _timescaledb_internal.chunk_constraint_add_table_constraint(
    chunk_constraint_row  _timescaledb_catalog.chunk_constraint
)
    RETURNS VOID LANGUAGE PLPGSQL AS
$BODY$
DECLARE
    sql_code    TEXT;
    chunk_row _timescaledb_catalog.chunk;
    hypertable_row _timescaledb_catalog.hypertable;
    constraint_oid OID;
    def TEXT;
BEGIN
    SELECT * INTO STRICT chunk_row FROM _timescaledb_catalog.chunk c 
    SELECT * INTO STRICT hypertable_row FROM _timescaledb_catalog.hypertable h
    -- REMOVING CONSTRAINT CHECK
    --IF chunk_constraint_row.dimension_slice_id IS NOT NULL THEN
    --    def := format('CHECK (%s)',  _timescaledb_internal.dimension_slice_get_constraint_sql(chunk_constraint_row.dimension_slice_id));
   -- ELSIF chunk_constraint_row.hypertable_constraint_name IS NOT NULL THEN
   --    SELECT oid INTO STRICT constraint_oid FROM pg_constraint
    --    WHERE conname=chunk_constraint_row.hypertable_constraint_name AND
     --         conrelid = format('%I.%I', hypertable_row.schema_name, hypertable_row.table_name)::regclass::oid;
    --    def := pg_get_constraintdef(constraint_oid);
   -- ELSE
   --     RAISE 'Unknown constraint type';
   -- END IF;

    sql_code := format(
        $$ ALTER TABLE %I.%I ADD CONSTRAINT %I %s $$,
        chunk_row.schema_name, chunk_row.table_name, chunk_constraint_row.constraint_name, def
    );
    EXECUTE sql_code;
END
$BODY$;

CREATE OR REPLACE FUNCTION _timescaledb_internal.chunk_constraint_drop_table_constraint(
    chunk_constraint_row  _timescaledb_catalog.chunk_constraint
)
    RETURNS VOID LANGUAGE PLPGSQL AS
$BODY$
DECLARE
    sql_code    TEXT;
    chunk_row _timescaledb_catalog.chunk;
BEGIN
    SELECT * INTO STRICT chunk_row FROM _timescaledb_catalog.chunk c 

    sql_code := format(
        $$ ALTER TABLE %I.%I DROP CONSTRAINT %I $$,
        chunk_row.schema_name, chunk_row.table_name, chunk_constraint_row.constraint_name
    );

    EXECUTE sql_code;
END
$BODY$;

-- remove all constraint functions


