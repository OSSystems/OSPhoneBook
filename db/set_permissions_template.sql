DO $$DECLARE r record;
BEGIN
  FOR r IN SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE' AND table_schema = 'public'
  LOOP
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' ||
      quote_ident(r.table_schema) || '.' ||
      quote_ident(r.table_name) || ' TO "%{application_user}"';
  END LOOP;

  FOR r IN SELECT sequence_schema, sequence_name
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
  LOOP
    EXECUTE 'GRANT USAGE, SELECT ON SEQUENCE ' ||
      quote_ident(r.sequence_schema) || '.' ||
      quote_ident(r.sequence_name) || ' TO "%{application_user}"';
  END LOOP;
END$$;
