
create or replace function hashids.clean_seps_from_alphabet(
	in p_seps text,
	in p_alphabet text
)
  RETURNS text AS
$$
DECLARE 
    p_seps ALIAS for $1;
    p_alphabet ALIAS for $2;
    v_split_seps text[] := regexp_split_to_array(p_seps, '');
    v_split_alphabet text[] := regexp_split_to_array(p_alphabet, '');
    v_i integer := 1;
    v_length integer := length(p_seps);
    v_ret text := '';
BEGIN
	-- had to add this function because doing this:
	-- p_seps := array_to_string(ARRAY(select chars.cha from (select unnest(regexp_split_to_array(p_seps, '')) as cha intersect select unnest(regexp_split_to_array(p_alphabet, '')) as cha ) as chars order by ascii(cha) desc), '');
	-- doesn't preserve the order of the input
	
	for v_i in 1..v_length loop
		-- raise notice 'v_split_seps[%]: %  == %', v_i, v_split_seps[v_i], v_split_seps[v_i] = any (v_split_alphabet);
		if (v_split_seps[v_i] = any (v_split_alphabet)) then
			v_ret = v_ret || v_split_seps[v_i];
		end if;
	end loop;

	-- raise notice 'v_ret: %', v_ret;
	return v_ret;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 200;

create or replace function hashids.clean_alphabet_from_seps(
	in p_seps text,
	in p_alphabet text
)
  RETURNS text AS
$$
DECLARE 
    p_seps ALIAS for $1;
    p_alphabet ALIAS for $2;
    v_split_seps text[] := regexp_split_to_array(p_seps, '');
    v_split_alphabet text[] := regexp_split_to_array(p_alphabet, '');
    v_i integer := 1;
    v_length integer := length(p_alphabet);
    v_ret text := '';
BEGIN
	-- had to add this function because doing this:
	-- p_alphabet := array_to_string(ARRAY( select chars.cha from (select unnest(regexp_split_to_array(p_alphabet, '')) as cha EXCEPT select unnest(regexp_split_to_array(p_seps, '')) as cha) as chars  ), '');
	-- doesn't preserve the order of the input
	
	for v_i in 1..v_length loop
		--raise notice 'v_split_alphabet[%]: % != %', v_i, v_split_alphabet[v_i], v_split_alphabet[v_i] <> all (v_split_seps);
		if (v_split_alphabet[v_i] <> all (v_split_seps)) then
			v_ret = v_ret || v_split_alphabet[v_i];
		end if;
	end loop;

	-- raise notice 'v_ret: %', v_ret;
	return v_ret;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 200;

CREATE OR REPLACE FUNCTION hashids.distinct_alphabet(in p_alphabet text)
  RETURNS text AS
$$
DECLARE 
    p_alphabet ALIAS for $1;
    v_split_alphabet text[] := regexp_split_to_array(p_alphabet, '');
    v_i integer := 2;
    v_length integer := length(p_alphabet);
    v_ret_array text[];
BEGIN
	-- had to add this function because doing this:
	-- p_alphabet := string_agg(distinct chars.split_chars, '') from (select unnest(regexp_split_to_array(p_alphabet, '')) as split_chars) as chars;
	-- doesn't preserve the order of the input, which was causing issues
	if (v_length = 0) then
		RAISE EXCEPTION 'alphabet must contain at least 1 char' USING HINT = 'Please check your alphabet';
	end if;
	v_ret_array := array_append(v_ret_array, v_split_alphabet[1]);

	-- starting at 2 because already appended 1 to it.
	for v_i in 2..v_length loop
		-- raise notice 'v_split_alphabet[%]: % != %', v_i, v_split_alphabet[v_i], v_split_alphabet[v_i] <> all (v_ret_array);
		
		if (v_split_alphabet[v_i] <> all (v_ret_array)) then
			v_ret_array := array_append(v_ret_array, v_split_alphabet[v_i]);
		end if;
	end loop;

	-- raise notice 'v_ret_array: %', array_to_string(v_ret_array, '');
	return array_to_string(v_ret_array, '');
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 200;
