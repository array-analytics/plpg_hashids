
DROP FUNCTION if exists hashids.decode(text, text, integer, text, boolean);
DROP FUNCTION if exists hashids.decode(text, text, integer, text);
DROP FUNCTION if exists hashids.decode(text, text, integer);
DROP FUNCTION if exists hashids.decode(text, text);
DROP FUNCTION if exists hashids.decode(text);

CREATE OR REPLACE FUNCTION hashids.decode(
    in p_hash text,
    in p_salt text,
    in p_min_hash_length integer,
    in p_alphabet text,
    p_zero_offset boolean DEFAULT true)
  RETURNS bigint[] AS
$$
DECLARE
    p_hash ALIAS for $1;
    p_salt ALIAS for $2;
    p_min_hash_length ALIAS for $3;
    p_alphabet ALIAS for $4;
    p_zero_offset ALIAS for $5; -- adding an offset so that this can work with values from a zero based array language

    v_seps text; 
    v_guards text; 
    v_alphabet text := p_alphabet;
    v_lottery char(1);

    v_hashBreakdown varchar(255);
    v_hashArray text[];
    v_index integer := 1;
    v_j integer := 1;
    v_hashArrayLength integer;
    v_subHash varchar;
    v_buffer varchar(255);
    v_encodeCheck varchar(255);
    v_ret_temp bigint;
    v_ret bigint[];
BEGIN

    select * from hashids.setup_alphabet(p_salt, v_alphabet) into v_alphabet, v_seps, v_guards;
    --raise notice 'v_seps: %', v_seps;
    --raise notice 'v_alphabet: %', v_alphabet;
    --raise notice 'v_guards: %', v_guards;

    v_hashBreakdown := regexp_replace(p_hash, '[' || v_guards || ']', ' ');
    v_hashArray := regexp_split_to_array(p_hash, '[' || v_guards || ']');
   
    -- take the guards and replace with space,
    -- split on space
    -- if length is 3 or 2, set index to 1 else start at zero

    -- if first index in idBreakDown isn't default
    
    if ((array_length(v_hashArray, 1) = 3) or (array_length(v_hashArray, 1) = 2)) then
        v_index := 2; -- in the example code (C# and js) it is 1 here, but postgresql arrays start at 1, so switching to 2
    END IF;
    --raise notice '%', v_hashArray;

    v_hashBreakdown := v_hashArray[v_index];
    --raise notice 'v_hashArray[%] %', v_index, v_hashBreakdown;
    if (left(v_hashBreakdown, 1) <> '') IS NOT false then
        v_lottery := left(v_hashBreakdown, 1);
        --raise notice 'v_lottery %', v_lottery;
        --raise notice 'SUBSTRING(%, 2, % - 1) %', v_hashBreakdown, length(v_hashBreakdown), SUBSTRING(v_hashBreakdown, 2);
        
        v_hashBreakdown := SUBSTRING(v_hashBreakdown, 2);
        v_hashArray := regexp_split_to_array(v_hashBreakdown, '[' || v_seps || ']');
        --raise notice 'v_hashArray % -- %', v_hashArray, array_length(v_hashArray, 1);
        v_hashArrayLength := array_length(v_hashArray, 1);
        for v_j in 1..v_hashArrayLength LOOP
            v_subHash := v_hashArray[v_j];
            --raise notice 'v_subHash %', v_subHash;
            v_buffer := v_lottery || p_salt || v_alphabet;
            --raise notice 'v_buffer %', v_buffer;
            --raise notice 'v_alphabet: hashids.consistent_shuffle(%, %) == %', v_alphabet, SUBSTRING(v_buffer, 1, length(v_alphabet)), hashids.consistent_shuffle(v_alphabet, SUBSTRING(v_buffer, 1, length(v_alphabet)));
            v_alphabet := hashids.consistent_shuffle(v_alphabet, SUBSTRING(v_buffer, 1, length(v_alphabet)));
            v_ret_temp := hashids.unhash(v_subHash, v_alphabet, p_zero_offset);
            --raise notice 'v_ret_temp: %', v_ret_temp;
            v_ret := array_append(v_ret, v_ret_temp);
        END LOOP;
        v_encodeCheck := hashids.encode_list(v_ret, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
        IF (v_encodeCheck <> p_hash) then
            raise notice 'hashids.encodeList(%): % <> %', v_ret, v_encodeCheck, p_hash;
            return ARRAY[]::bigint[];
        end if;
    end if;
    
    RETURN v_ret;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;


CREATE OR REPLACE FUNCTION hashids.decode( in p_hash text )
  RETURNS bigint[] AS
$$
    DECLARE
        p_numbers ALIAS for $1;
        p_salt text := ''; -- default
        p_min_hash_length integer := 0; -- default
        p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.decode(p_hash, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.decode( 
  in p_hash text, 
  in p_salt text)
  RETURNS text AS
$$
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2; -- default
        p_min_hash_length integer := 0; -- default
        p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.decode(p_hash, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.decode( 
  in p_hash text, 
  in p_salt text,
  in p_min_hash_length integer)
  RETURNS bigint[] AS
$$
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2; -- default
        p_min_hash_length ALIAS for $3; -- default
        p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.decode(p_hash, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.decode( 
  in p_hash text, 
  in p_salt text,
  in p_min_hash_length integer,
  in p_alphabet text)
  RETURNS bigint[] AS
$$
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2; -- default
        p_min_hash_length ALIAS for $3; -- default
        p_alphabet ALIAS for $4; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.decode(p_hash, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.decode( 
  in p_hash text, 
  in p_salt text,
  in p_min_hash_length integer,
  in p_alphabet text,
  in p_zero_offset boolean)
  RETURNS bigint[] AS
$$
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2; -- default
        p_min_hash_length ALIAS for $3; -- default
        p_alphabet ALIAS for $4; -- default
        p_zero_offset ALIAS for $5 ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.decode(p_hash, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;
