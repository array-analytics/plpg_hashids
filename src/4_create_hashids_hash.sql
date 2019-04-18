drop function if exists hashids.hash(bigint, text, boolean);

CREATE OR REPLACE FUNCTION hashids.hash(
    p_input bigint,
    p_alphabet text,
    p_zero_offset boolean DEFAULT true)
  RETURNS text AS
$$
DECLARE 
    p_input ALIAS for $1;
    p_alphabet ALIAS for $2;
    p_zero_offset integer := case when $3 = true then 1 else 0 end ; -- adding an offset so that this can work with values from a zero based array language
    v_hash varchar(255) := '';
    v_alphabet_length integer := length($2);
    v_pos integer;
BEGIN

    WHILE 1 = 1 LOOP
        v_pos := (p_input % v_alphabet_length) + p_zero_offset; -- have to add one, because SUBSTRING in SQL starts at 1 instead of 0 (like it does in other languages)
        --raise notice '% mod % == %', p_input, v_alphabet_length, v_pos;
        --raise notice 'SUBSTRING(%, %, 1): %', p_alphabet, v_pos, (SUBSTRING(p_alphabet, v_pos, 1));
        --raise notice '% || % == %', SUBSTRING(p_alphabet, v_pos, 1), v_hash, SUBSTRING(p_alphabet, v_pos, 1) || v_hash;
        v_hash := SUBSTRING(p_alphabet, v_pos, 1) || v_hash;
        p_input := CAST((p_input / v_alphabet_length) as int);
        --raise notice 'p_input %', p_input;
        IF p_input <= 0 THEN
            EXIT;
        END IF;
    END LOOP;

    RETURN v_hash;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 250;


