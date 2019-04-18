drop function if exists hashids.setup_alphabet(text, text);

CREATE OR REPLACE FUNCTION hashids.setup_alphabet(
    in p_salt text default '',
    inout p_alphabet text default 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
    out p_seps text,
    out p_guards text)
AS
$$
DECLARE 
    p_salt ALIAS for $1;
    p_alphabet ALIAS for $2;
    p_seps ALIAS for $3;
    p_guards ALIAS for $4;
    v_sep_div float := 3.5;
    v_guard_div float := 12.0;
    v_guard_count integer;
    v_seps_length integer;
    v_seps_diff integer;
BEGIN
  p_seps := 'cfhistuCFHISTU';
	p_alphabet := string_agg(distinct chars.split_chars, '') from (select unnest(regexp_split_to_array(p_alphabet, '')) as split_chars) as chars;
	-- this also doesn't preserve the order of alphabet, but it doesn't appear to matter.

	if length(p_alphabet) < 16 then
		RAISE EXCEPTION 'alphabet must containt 16 unique characters, it is: %', length(p_alphabet) USING HINT = 'Please check your alphabet';
	end if;

	-- seps should only contain character present in the passed alphabet
  -- p_seps := array_to_string(ARRAY(select chars.cha from (select unnest(regexp_split_to_array(p_seps, '')) as cha intersect select unnest(regexp_split_to_array(p_alphabet, '')) as cha ) as chars order by ascii(cha) desc), '');
  -- this doesn't preserve the input order, which is bad
  p_seps := hashids.clean_seps_from_alphabet(p_seps, p_alphabet);

	-- alphabet should not contain seps.
  p_alphabet := array_to_string(ARRAY( select chars.cha from (select unnest(regexp_split_to_array(p_alphabet, '')) as cha EXCEPT select unnest(regexp_split_to_array(p_seps, '')) as cha) as chars order by ascii(cha) ), '');

	p_seps := hashids.consistent_shuffle(p_seps, p_salt);

	if (length(p_seps) = 0) or ((length(p_alphabet) / length(p_seps)) > v_sep_div) then
		v_seps_length := cast( ceil( length(p_alphabet)/v_sep_div ) as integer);
		if v_seps_length = 1 then 
			v_seps_length := 2; 
		end if;
		if v_seps_length > length(p_seps) then
			v_seps_diff := v_seps_length - length(p_seps);
			p_seps := SUBSTRING(p_alphabet, 1, v_seps_diff);
			p_alphabet := SUBSTRING(p_alphabet, v_seps_diff + 1);
		else 
			p_seps := SUBSTRING(p_seps, 1, v_seps_length + 1);
		end if;
	end if;

	p_alphabet := hashids.consistent_shuffle(p_alphabet, p_salt);

	v_guard_count := cast(ceil(length(p_alphabet) / v_guard_div ) as integer);

	if length(p_alphabet) < 3 then
		p_guards := SUBSTRING(p_seps, 1, v_guard_count);
		p_seps := SUBSTRING(p_seps, v_guard_count + 1);
	else
		p_guards := SUBSTRING(p_alphabet, 1, v_guard_count);
		p_alphabet := SUBSTRING(p_alphabet, v_guard_count + 1);
	end if;
	
END;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 200;