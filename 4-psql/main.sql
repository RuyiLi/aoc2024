CREATE TABLE input (rowidx SERIAL PRIMARY KEY, data TEXT);
COPY input (data) FROM STDIN;
SELECT * FROM input;

CREATE FUNCTION chr_at(r INT, c INT) RETURNS CHAR
AS $$
BEGIN
	RETURN (SELECT SUBSTR(data, c, 1) FROM input WHERE rowidx = r);
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION build_str(r INT, c INT, dr INT, dc INT, len INT DEFAULT 4) RETURNS TEXT
AS $$
DECLARE res_str TEXT;
BEGIN
	SELECT '' INTO res_str;
	FOR m IN 0..(len - 1) LOOP
		SELECT res_str || chr_at(r + m * dr, c + m * dc) INTO res_str;
	END LOOP;
	RETURN res_str;
END
$$ LANGUAGE plpgsql;

DO $$
DECLARE numrows INT;
DECLARE numcols INT;
BEGIN
	SELECT COUNT(*) FROM input INTO numrows;
	SELECT LENGTH(data) FROM input LIMIT 1 INTO numcols;

	-- puzzle 1
	CREATE TABLE search_xmas (data TEXT);
	FOR r IN 1..numrows LOOP
		FOR c IN 1..numcols LOOP
			INSERT INTO search_xmas (data) 
			VALUES
				(build_str(r, c, 1, 0)),
				(build_str(r, c, 1, 1)),
				(build_str(r, c, 0, 1)),
				(build_str(r, c, -1, 1)),
				(build_str(r, c, -1, 0)),
				(build_str(r, c, -1, -1)),
				(build_str(r, c, 0, -1)),
				(build_str(r, c, 1, -1));
		END LOOP;
	END LOOP;
	RAISE NOTICE 'Puzzle 1: %', (SELECT COUNT(*) FROM search_xmas WHERE data = 'XMAS');

	-- puzzle 2
	CREATE TABLE search_x (data TEXT);
	FOR r IN 1..numrows LOOP
		FOR c IN 1..numcols LOOP
			INSERT INTO search_x (data) 
			VALUES (build_str(r - 1, c - 1, 1, 1, 3) || build_str(r + 1, c - 1, -1, 1, 3));
		END LOOP;
	END LOOP;
	RAISE NOTICE 'Puzzle 2: %', (
		SELECT COUNT(*) FROM search_x 
		WHERE data IN ('SAMSAM', 'SAMMAS', 'MASMAS', 'MASSAM')
	);
END
$$;
