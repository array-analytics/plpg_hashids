DROP FUNCTION if exists hashids.consistent_shuffle(text, text);

CREATE OR REPLACE FUNCTION hashids.consistent_shuffle
(
	p_alphabet text,
	p_salt text
)
RETURNS text AS 
$$
DECLARE p_alphabet ALIAS FOR $1;
	p_salt ALIAS FOR $2;
	v_ls int;
	v_i int;
	v_v int := 0;
	v_p int := 0; 
	v_n int := 0;
	v_j int := 0;
	v_temp char(1);
BEGIN
	
	-- Null or Whitespace?
	IF p_salt IS NULL OR length(LTRIM(RTRIM(p_salt))) = 0 THEN
		RETURN p_alphabet;
	END IF;

	v_ls := length(p_salt);
	v_i := length(p_alphabet) - 1;

	WHILE v_i > 0 LOOP
		
		v_v := v_v % v_ls;
		v_n := ascii(SUBSTRING(p_salt, v_v + 1, 1)); -- need some investigation to see if +1 here is because of 1 based arrays in sql ... this isn't in the reference JS or .net code.
		v_p := v_p + v_n;
		v_j := (v_n + v_v + v_p) % v_i;
		v_temp := SUBSTRING(p_alphabet, v_j + 1, 1);
		p_alphabet := 
				SUBSTRING(p_alphabet, 1, v_j) || 
				SUBSTRING(p_alphabet, v_i + 1, 1) || 
				SUBSTRING(p_alphabet, v_j + 2, 255);
		p_alphabet :=  SUBSTRING(p_alphabet, 1, v_i) || v_temp || SUBSTRING(p_alphabet, v_i + 2, 255);
		v_i := v_i - 1;
		v_v := v_v + 1;

	END LOOP; -- WHILE

	RETURN p_alphabet;

END;
$$
LANGUAGE plpgsql IMMUTABLE
  COST 200;