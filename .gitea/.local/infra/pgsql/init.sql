DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'devops') THEN
      EXECUTE 'CREATE DATABASE devops';
   END IF;
END
$$;