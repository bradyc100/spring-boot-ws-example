DROP TABLE IF EXISTS tools;

CREATE TABLE tools(
  sku TEXT CONSTRAINT tools_pkey PRIMARY KEY,
  description TEXT NOT NULL DEFAULT '',
  make TEXT NOT NULL DEFAULT '',
  numInStock INTEGER,
  price NUMERIC CHECK (price > 0),
  other_attr JSON
);

CREATE INDEX tindex 
ON tools
USING BTREE(sku);

INSERT INTO tools(sku, description, make,  numinstock, price, other_attr)
VALUES('T001', 'claw hammer fiberglass handle', 'Kobalt', 2, 15.00, '{}');

INSERT INTO tools(sku, description, make,  numinstock, price, other_attr)
VALUES('T002', 'belt sander 10W', 'DeWalt', 5, 50.00, '{}');

INSERT INTO tools(sku, description, make,  numinstock, price, other_attr)
VALUES('T003', 'reciprocating saw 20W sawzall', 'DeWalt', 5, 75.00, '{}');

INSERT INTO tools(sku, description, make,  numinstock, price, other_attr)
VALUES('T004', 'jigsaw 10W', 'Kobalt', 2, 35.00, '{}');

DROP TABLE IF EXISTS plumbing;

CREATE TABLE plumbing(
  sku TEXT CONSTRAINT plumbing_pkey PRIMARY KEY,
  description TEXT NOT NULL DEFAULT '',
  price NUMERIC CHECK (price > 0),
  numInStock INTEGER,
  other_attr JSON
);

CREATE INDEX pindex 
ON plumbing
USING BTREE(sku);

INSERT INTO plumbing(sku, description, price, numinstock, other_attr)
VALUES('P001', 'PVC 1 Foot Section', 2, 5.00, '{}');

INSERT INTO plumbing(sku, description, price, numinstock, other_attr)
VALUES('P002', 'PVC 90 degree elbow', 2, 2.00, '{}');

INSERT INTO plumbing(sku, description, price, numinstock, other_attr)
VALUES('P003', 'PVC Cement adhesive', 2, 5.00, '{}');

CREATE TABLE IF NOT EXISTS transactions(
  id SERIAL CONSTRAINT tx_pkey PRIMARY KEY,
  skus TEXT[],
  total_amount NUMERIC 
);

DROP TRIGGER IF EXISTS tx_insert ON transactions;
DROP FUNCTION decrement_inventory;

CREATE OR REPLACE FUNCTION decrement_inventory()
  RETURNS trigger as 
  $BODY$
  DECLARE
    tx_sku TEXT;
    rec RECORD;
  BEGIN
    FOREACH tx_sku IN ARRAY NEW.skus
    LOOP
      FOR rec IN SELECT sku FROM tools
                  WHERE sku = tx_sku
      LOOP
        UPDATE tools
        SET numinstock = numinstock - 1
        WHERE sku = tx_sku;
      END LOOP;


      FOR rec IN SELECT sku FROM plumbing
                  WHERE sku = tx_sku
      LOOP
        UPDATE plumbing
        SET numinstock = numinstock - 1
        WHERE sku = tx_sku;
      END LOOP;
    END LOOP;
    RETURN NEW;
  END;
  $BODY$

LANGUAGE plpgsql;

CREATE TRIGGER tx_insert
  AFTER INSERT
  ON transactions
  FOR EACH ROW
  EXECUTE PROCEDURE decrement_inventory();
