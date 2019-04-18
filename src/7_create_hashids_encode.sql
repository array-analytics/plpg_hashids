DROP FUNCTION if exists hashids.encode(bigint);
DROP FUNCTION if exists hashids.encode(bigint, text);
DROP FUNCTION if exists hashids.encode(bigint, text, integer);
DROP FUNCTION if exists hashids.encode(bigint, text, integer, text);
DROP FUNCTION if exists hashids.encode(bigint, text, integer, text, boolean);

CREATE OR REPLACE FUNCTION hashids.encode(in p_number bigint)
  RETURNS text AS
$$
DECLARE
    p_number ALIAS for $1;
    p_salt text := ''; -- default
    p_min_hash_length integer := 0; -- default
    p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
    p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(ARRAY[p_number::bigint]::bigint[], p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;


CREATE OR REPLACE FUNCTION hashids.encode(
  in p_number bigint,
  in p_salt text)
  RETURNS text AS
$$
DECLARE
    p_number ALIAS for $1;
    p_salt ALIAS for $2;
    p_min_hash_length integer := 0; -- default
    p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
    p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(ARRAY[p_number::bigint]::bigint[], p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;


CREATE OR REPLACE FUNCTION hashids.encode(
  in p_number bigint,
  in p_salt text,
  in p_min_hash_length integer)
  RETURNS text AS
$$
DECLARE
    p_number ALIAS for $1;
    p_salt ALIAS for $2;
    p_min_hash_length ALIAS for $3; -- default
    p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
    p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(ARRAY[p_number::bigint]::bigint[], p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.encode(
  in p_number bigint,
  in p_salt text,
  in p_min_hash_length integer,
  in p_alphabet text)
  RETURNS text AS
$$
DECLARE
    p_number ALIAS for $1;
    p_salt ALIAS for $2;
    p_min_hash_length ALIAS for $3; -- default
    p_alphabet ALIAS for $4; -- default
    p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(ARRAY[p_number::bigint]::bigint[], p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.encode(
  in p_number bigint,
  in p_salt text,
  in p_min_hash_length integer,
  in p_alphabet text
  in p_zero_offset boolean)
  RETURNS text AS
$$
DECLARE
    p_number ALIAS for $1;
    p_salt ALIAS for $2;
    p_min_hash_length ALIAS for $3; -- default
    p_alphabet ALIAS for $4; -- default
    p_zero_offset ALIAS for $5 ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(ARRAY[p_number::bigint]::bigint[], p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;
