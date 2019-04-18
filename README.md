# plpg_hashids
A small set of TSQL functions to generate YouTube-like hashes from one or many numbers. 
Use hashids when you do not want to expose your database ids to the user.

[http://www.hashids.org/](http://www.hashids.org/)

This repository contains a port to plpgsql of the other projects found at hashids.org.
The [TSQL](https://github.com/waynebloss/hashids-tsql), [Postgres](https://github.com/iCyberon/pg_hashids), [Javascript](https://github.com/ivanakimov/hashids.js) and [.NET](https://github.com/ullmark/hashids.net) versions of Hashids are the primary reference projects for this port, with the TSQL version being the initial version.

Tested PostgreSQL versions : 9.6.X (Should work on older and newer versions, just not tested)

It is done using plpgsql becuase Postgresql on Azure and AWS doesn't support creating your own extensions.

## What is it?

hashids (Hash ID's) creates short, unique, decryptable hashes from unsigned integers.

_(NOTE: This is **NOT** a true cryptographic hash, since it is reversible.)_

It was designed for websites to use in URL shortening, tracking stuff, or making pages private (or at least unguessable).

This algorithm tries to satisfy the following requirements:

1. Hashes must be unique and decryptable.
2. They should be able to contain more than one integer (so you can use them in complex or clustered systems).
3. You should be able to specify minimum hash length.
4. Hashes should not contain basic English curse words (since they are meant to appear in public places - like the URL).

Instead of showing items as `1`, `2`, or `3`, you could show them as `U6dc`, `u87U`, and `HMou`.
You can choose to store these hashes in the database or encrypt + decrypt on the fly.

All integers need to be greater than or equal to zero.

See [hashids.org](http://www.hashids.org/) for more information on this technique.

## Usage

Run the scripts in the order that they are in, in the `src` folder. Please note, that they are in their own schema (`hashids`), if you don't want that you will have to edit the scripts to remove the assumption of the `hashids` schema.

#### Encoding
Returns a hash using the default `alphabet` and empty `salt`.

	SELECT hashids.encode(1001); -- Result: jNl

Returns a hash using the default `alphabet` and supplied `salt`.

	SELECT hashids.encode(1234567, 'This is my salt'); -- Result: Pdzxp

Returns a hash using the default `alphabet`, `salt` and minimum hash length.
	
	SELECT hashids.encode(1234567, 'This is my salt', 10); -- Result: PlRPdzxpR7
	
Returns a hash using the supplied `alphabet`, `salt` and minimum hash length.
	
	SELECT hashids.encode(1234567, 'This is my salt', 10, 'abcdefghijABCDxFGHIJ1234567890'); -- Result: 3GJ956J9B9

Returns a hash for an array of numbers.

	SELECT hashids.encode_list(ARRAY[1,2,3]); -- Result: o2fXhV
  
#### Decoding
You can also decode previously generated hashes. Just use the same `salt`, otherwise you'll get wrong results.

	SELECT unnest(hashids.decode('PlRPdzxpR7', 'This is my salt', 10)); -- Result: 1234567
	
Using a custom alphabet

	SELECT unnest(hashids.decode('3GJ956J9B9', 'This is my salt', 10, 'abcdefghijABCDxFGHIJ1234567890')); -- Result: 1234567
