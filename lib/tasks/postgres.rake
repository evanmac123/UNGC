namespace :postgres do

  desc "Add fold_ascii support."
  task install_extensions: [:environment] do
    raise 'Extentions can only be added to PostgreSQL.' unless DbConnectionHelper.backend == :postgres
    ActiveRecord::Base.connection.execute 'CREATE EXTENSION IF NOT EXISTS unaccent'

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE OR REPLACE FUNCTION fold_ascii(text)
        RETURNS text AS $$

        SELECT lower(unaccent($1));

        $$ LANGUAGE sql IMMUTABLE
        COST 1;
    SQL

    ActiveRecord::Base.connection.execute 'DROP INDEX IF EXISTS idx_organizations_casefolded'
    ActiveRecord::Base.connection.execute('CREATE UNIQUE INDEX idx_organizations_casefolded ON organizations(fold_ascii(name))')

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE OR REPLACE FUNCTION crc32(text_string text) RETURNS bigint AS $$
      DECLARE
        tmp bigint;
        i int;
        j int;
        byte_length int;
        binary_string bytea;
      BEGIN
        IF text_string IS NULL THEN
          RETURN 0;
        END IF;

        i = 0;
        tmp = 4294967295;
        byte_length = bit_length(text_string) / 8;
        binary_string = decode(replace(text_string, E'\\\\', E'\\\\\\\\'), 'escape');
        LOOP
          tmp = (tmp # get_byte(binary_string, i))::bigint;
          i = i + 1;
          j = 0;
          LOOP
            tmp = ((tmp >> 1) # (3988292384 * (tmp & 1)))::bigint;
            j = j + 1;
            IF j >= 8 THEN
             EXIT;
            END IF;
            END LOOP;
          IF i >= byte_length THEN
            EXIT;
          END IF;
        END LOOP;
        RETURN (tmp # 4294967295);
        END
      $$ IMMUTABLE LANGUAGE plpgsql;
    SQL
  end

  # HACK: maintain backward compatibility with older typo :]
  task install_extentions: [:install_extensions]
end
