DROP DATABASE IF EXISTS exchange;
DROP USER IF EXISTS trader;

CREATE USER trader WITH password 'trader';

CREATE DATABASE exchange
  WITH TEMPLATE = template0
       ENCODING = 'UTF8';

ALTER DATABASE exchange OWNER TO trader;
GRANT ALL PRIVILEGES ON DATABASE exchange TO trader;

\connect exchange trader

CREATE SCHEMA IF NOT EXISTS trader AUTHORIZATION trader;

CREATE SEQUENCE IF NOT EXISTS SEQUENCE_ID
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1;

--------------------------------------------------------------------------------
-- exchange --------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE TABLE exchange (
    id		numeric PRIMARY KEY DEFAULT NEXTVAL('SEQUENCE_ID'),
    name	varchar(50) NOT NULL,
    description	text,
    endpoint	text
);
--------------------------------------------------------------------------------

COMMENT ON TABLE exchange IS 'Exchange';

COMMENT ON COLUMN exchange.id IS 'Id';
COMMENT ON COLUMN exchange.name IS 'Name';
COMMENT ON COLUMN exchange.description IS 'Description';
COMMENT ON COLUMN exchange.endpoint IS 'The base endpoint';
--------------------------------------------------------------------------------

CREATE INDEX idx_exchange_name ON exchange (name);

INSERT INTO exchange (name, description, endpoint) VALUES ('binance', 'Binance', 'https://api.binance.com');
INSERT INTO exchange (name, description, endpoint) VALUES ('poloniex', 'Poloniex', 'https://poloniex.com');
INSERT INTO exchange (name, description, endpoint) VALUES ('bitfinex', 'Bitfinex', 'https://api.bitfinex.com');

--------------------------------------------------------------------------------
-- key -------------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE TABLE key (
    id		numeric PRIMARY KEY DEFAULT NEXTVAL('SEQUENCE_ID'),
    exchange	numeric NOT NULL,
    api		text NOT NULL,
    secret	text NOT NULL,
    CONSTRAINT fk_key_exchange FOREIGN KEY (exchange) REFERENCES exchange(id)
);
--------------------------------------------------------------------------------

COMMENT ON TABLE key IS 'Keys';

COMMENT ON COLUMN key.id IS 'Id';
COMMENT ON COLUMN key.exchange IS 'Exchange';
COMMENT ON COLUMN key.api IS 'API key';
COMMENT ON COLUMN key.secret IS 'Secret key';

--------------------------------------------------------------------------------
-- orders ----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE TABLE orders (
    id		numeric PRIMARY KEY DEFAULT NEXTVAL('SEQUENCE_ID'),
    async_key   numeric NOT NULL,
    exchange	numeric NOT NULL,
    datetime    timestamp DEFAULT clock_timestamp() NOT NULL,
    pair	varchar(50) NOT NULL,
    type	varchar(50) NOT NULL,
    amount	numeric NOT NULL,
    response	jsonb,
    runtime		interval,
    CONSTRAINT fk_orders_exchange FOREIGN KEY (exchange) REFERENCES exchange(id)
);
--------------------------------------------------------------------------------

COMMENT ON TABLE orders IS 'Orders';

COMMENT ON COLUMN orders.id IS 'Id';
COMMENT ON COLUMN orders.async_key IS 'The key to update the record in asynchronous mode';
COMMENT ON COLUMN orders.exchange IS 'Exchange';
COMMENT ON COLUMN orders.datetime IS 'Date time';
COMMENT ON COLUMN orders.pair IS 'Currency Pair';
COMMENT ON COLUMN orders.type IS '“buy” or “sell”';
COMMENT ON COLUMN orders.amount IS 'Amount';
COMMENT ON COLUMN orders.response IS 'JSON response';
COMMENT ON COLUMN orders.runtime IS 'Request runtime';
--------------------------------------------------------------------------------

CREATE UNIQUE INDEX ON orders (async_key);

CREATE INDEX ON orders (datetime);
CREATE INDEX ON orders (pair);
CREATE INDEX ON orders (type);

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ft_orders_update()
RETURNS trigger AS $$
BEGIN
  NEW.RUNTIME = age(clock_timestamp(), OLD.DATETIME);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = trader, pg_temp;

--------------------------------------------------------------------------------

CREATE TRIGGER t_orders_update
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE PROCEDURE ft_orders_update();

--------------------------------------------------------------------------------
-- NewOrder --------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION NewOrder (
    pAsyncKey	numeric,
    pExchange    varchar,
    pPair    varchar,
    pType	varchar,
    pAmount	numeric
) RETURNS	numeric
AS $$
DECLARE
  nId numeric;
  nExchange numeric;
BEGIN
  SELECT id INTO nExchange FROM exchange WHERE name = lower(pExchange);

  IF not found THEN
    RAISE EXCEPTION 'ERROR: Exchange "%" not found.', pExchange;
  END IF;

  INSERT INTO orders (async_key, exchange, pair, type, amount)
  VALUES (pAsyncKey, nExchange, pPair, pType, pAmount)
  RETURNING id INTO nId;

  RETURN nId;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = trader, pg_temp;

--------------------------------------------------------------------------------
-- VIEW VOrders ----------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW VOrders (Id, Exchange, ExchangeName, ExchangeDescription,
    ExchangeEndPoint, DateTime, Pair, Type, Amount, RunTime, Response)
AS
  SELECT o.id, o.exchange, e.name, e.description, e.endpoint, o.datetime,
         o.pair, o.type, o.amount, round(extract(second from o.runtime)::numeric, 3),
         o.response
    FROM orders o INNER JOIN exchange e ON e.id = o.exchange;
