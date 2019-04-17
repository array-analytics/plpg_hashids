DROP FUNCTION if exists hashids.unhash(text, text, boolean);

CREATE OR REPLACE FUNCTION hashids.unhash(
    p_input text,
    p_alphabet text,
    p_zero_offset boolean DEFAULT true)
  RETURNS bigint AS
$$
DECLARE 
    p_input ALIAS for $1;
    p_alphabet ALIAS for $2;
    p_zero_offset integer := case when $3 = true then 1 else 0 end ; -- adding an offset so that this can work with values from a zero based array language
    v_input_length integer := length($1);
    v_alphabet_length integer := length($2);
    v_ret bigint := 0;
    v_input_char char(1);
    v_pos integer;
    v_i integer := 1;
BEGIN
    for v_i in 1..v_input_length loop
        v_input_char := SUBSTRING(p_input, (v_i), 1);
        v_pos := POSITION(v_input_char in p_alphabet) - p_zero_offset; -- have to remove one to interface with .net because it is a zero based index
        --raise notice '%[%] is % to position % in %', p_input, v_i, v_input_char, v_pos, p_alphabet;
        --raise notice '  % + (% * power(%, % - % - 1)) == %', v_ret, v_pos, v_alphabet_length, v_input_length, (v_i - 1), v_ret + (v_pos * power(v_alphabet_length, v_input_length - (v_i-1) - 1));
        v_ret := v_ret + (v_pos * power(v_alphabet_length, v_input_length - (v_i-p_zero_offset) - 1));
    end loop;

    RETURN v_ret;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;