
drop function if exists hashids.encode_list(bigint[], text, integer, text, boolean);
drop function if exists hashids.encode_list(bigint[], text, integer, text);
drop function if exists hashids.encode_list(bigint[], text, integer);
drop function if exists hashids.encode_list(bigint[], text);
drop function if exists hashids.encode_list(bigint[]);


CREATE OR REPLACE FUNCTION hashids.encode_list(
    in p_numbers bigint[],
    in p_salt text, -- DEFAULT '',
    in p_min_hash_length integer, -- integer default 0,
    in p_alphabet text, -- DEFAULT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
    in p_zero_offset boolean DEFAULT true)
  RETURNS text AS
$$
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2;
        p_min_hash_length ALIAS for $3;
        p_alphabet ALIAS for $4;
        p_zero_offset integer := case when $5 = true then 1 else 0 end ; -- adding an offset so that this can work with values from a zero based array language
        v_seps text; 
        v_guards text;

        -- Working Data
        v_alphabet text := p_alphabet;
        v_numbersHashInt int = 0;
        v_lottery char(1);
        v_buffer varchar(255);
        v_last varchar(255);
        v_ret varchar(255);
        v_sepsIndex int;
        v_lastId int;
        v_count int = array_length(p_numbers, 1);
        v_i int = 0;
        v_id int = 0;
        v_number bigint;
        v_guardIndex int;
        v_guard char(1);
        v_halfLength int;
        v_excess int;
BEGIN

    select * from hashids.setup_alphabet(p_salt, p_alphabet) into v_alphabet, v_seps, v_guards;
    --raise notice 'v_seps: %', v_seps;
    --raise notice 'v_alphabet: %', v_alphabet;
    --raise notice 'v_guards: %', v_guards;

    -- Calculate numbersHashInt
    for v_lastId in 1..v_count LOOP
        v_numbersHashInt := v_numbersHashInt + (p_numbers[v_lastId] % ((v_lastId-p_zero_offset) + 100));
    END LOOP;
    
    -- Choose lottery
    v_lottery := SUBSTRING(v_alphabet, (v_numbersHashInt % length(v_alphabet)) + 1, 1); -- is this a +1 because of sql 1 based index, need to double check to see if can be replaced with param.
    v_ret := v_lottery;

    -- Encode many
    v_i := 0;
    v_id := 0;
    for v_i in 1..v_count LOOP
        v_number := p_numbers[v_i];
        raise notice '%[%]: % for %', p_numbers, v_i, v_number, v_count;

        v_buffer := v_lottery || p_salt || v_alphabet;
        v_alphabet := hashids.consistent_shuffle(v_alphabet, SUBSTRING(v_buffer, 1, length(v_alphabet)));
        v_last := hashids.hash(v_number, v_alphabet, cast(p_zero_offset as boolean));
        v_ret := v_ret || v_last;
        --raise notice 'v_ret: %', v_ret;
        --raise notice '(v_i < v_count: % < % == %', v_i, v_count, (v_i < v_count);
        IF (v_i) < v_count THEN
            --raise notice 'v_sepsIndex:  % mod (% + %) == %', v_number, ascii(SUBSTRING(v_last, 1, 1)), v_i, (v_number % (ascii(SUBSTRING(v_last, 1, 1)) + v_i));
            v_sepsIndex := v_number % (ascii(SUBSTRING(v_last, 1, 1)) + (v_i-p_zero_offset)); -- since this is 1 base vs 0 based bringing the number back down so that the mod is the same for zero based records
            v_sepsIndex := v_sepsIndex % length(v_seps);
            v_ret := v_ret || SUBSTRING(v_seps, v_sepsIndex+1, 1);
        END IF;

    END LOOP;
    
    ----------------------------------------------------------------------------
    -- Enforce minHashLength
    ----------------------------------------------------------------------------
    IF length(v_ret) < p_min_hash_length THEN
            
        ------------------------------------------------------------------------
        -- Add first 2 guard characters
        ------------------------------------------------------------------------
        v_guardIndex := (v_numbersHashInt + ascii(SUBSTRING(v_ret, 1, 1))) % length(v_guards);
        v_guard := SUBSTRING(v_guards, v_guardIndex + 1, 1);
        --raise notice '% || % is %', v_guard, v_ret, v_guard || v_ret; 
        v_ret := v_guard || v_ret;
        IF length(v_ret) < p_min_hash_length THEN
            v_guardIndex := (v_numbersHashInt + ascii(SUBSTRING(v_ret, 3, 1))) % length(v_guards);
            v_guard := SUBSTRING(v_guards, v_guardIndex + 1, 1);
            v_ret := v_ret || v_guard;
        END IF;
        ------------------------------------------------------------------------
        -- Add the rest
        ------------------------------------------------------------------------
        WHILE length(v_ret) < p_min_hash_length LOOP
            v_halfLength := COALESCE(v_halfLength, CAST((length(v_alphabet) / 2) as int));
            v_alphabet := hashids.consistent_shuffle(v_alphabet, v_alphabet);
            v_ret := SUBSTRING(v_alphabet, v_halfLength + 1, 255) || v_ret || SUBSTRING(v_alphabet, 1, v_halfLength);
            v_excess := length(v_ret) - p_min_hash_length;
            IF v_excess > 0 THEN 
                v_ret := SUBSTRING(v_ret, CAST((v_excess / 2) as int) + 1, p_min_hash_length);
            END IF;
        END LOOP;
    END IF;
    RETURN v_ret;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 350;


CREATE OR REPLACE FUNCTION hashids.encode_list( in p_numbers bigint[] )
  RETURNS text AS
$$
-- Options Data - generated by hashids-tsql
    DECLARE
        p_numbers ALIAS for $1;
        p_salt text := ''; -- default
        p_min_hash_length integer := 0; -- default
        p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(p_numbers, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.encode_list( 
  in p_numbers bigint[],
  in p_salt text )
  RETURNS text AS
$$
-- Options Data - generated by hashids-tsql
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2; -- default
        p_min_hash_length integer := 0; -- default
        p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(p_numbers, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;

CREATE OR REPLACE FUNCTION hashids.encode_list( 
  in p_numbers bigint[],
  in p_salt text,
  in p_min_hash_length integer )
  RETURNS text AS
$$
-- Options Data - generated by hashids-tsql
    DECLARE
        p_numbers ALIAS for $1;
        p_salt ALIAS for $2; -- default
        p_min_hash_length ALIAS for $3; -- default
        p_alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; -- default
        p_zero_offset boolean := true ; -- adding an offset so that this can work with values from a zero based array language
BEGIN
    RETURN hashids.encode_list(p_numbers, p_salt, p_min_hash_length, p_alphabet, p_zero_offset);
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 300;


