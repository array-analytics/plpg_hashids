
create or replace function hashids.clean_seps_from_alphabet(
	p_seps text,
	p_alphabet text
)
  RETURNS text AS
$$
DECLARE 
    p_seps ALIAS for $1;
    p_alphabet ALIAS for $2;
    v_split_seps text[]	:= regexp_split_to_array(p_seps, '');
    v_split_alphabet text[]	:= regexp_split_to_array(p_alphabet, '');
    v_i integer := 1;
    v_length integer := length(p_seps);
    v_ret_array text[];
    v_ret text := '';
BEGIN
	-- had to add this function because doing this:
	-- p_seps := array_to_string(ARRAY(select chars.cha from (select unnest(regexp_split_to_array(p_seps, '')) as cha intersect select unnest(regexp_split_to_array(p_alphabet, '')) as cha ) as chars order by ascii(cha) desc), '');
	-- doesn't preserve the order of the input
	
	for v_i in 1..v_length loop
		--raise notice 'v_split_seps[%]: %  == %', v_i, v_split_seps[v_i], v_split_seps[v_i] = any (v_split_alphabet);
		if (v_split_seps[v_i] = any (v_split_alphabet)) then
			v_ret = v_ret || v_split_seps[v_i];
		end if;
	end loop;

	raise notice 'v_ret: %', v_ret;
	return v_ret;
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 200;
