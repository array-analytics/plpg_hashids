-- our usage of these functions places all of them in a separate schema, with "hashids" being the default name
-- change this or don't use it (but know that the other sql functions will not work out of the box, they are assume hashids schema). 
CREATE SCHEMA hashids;