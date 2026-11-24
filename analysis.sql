-- Stock Market Data Analysis | PostgreSQL
-- Synthetic daily prices for SQL practice; not investment advice or live market data.
DROP TABLE IF EXISTS stock_prices;
CREATE TABLE stock_prices (
 price_id INT PRIMARY KEY, ticker VARCHAR(10), trade_date DATE,
 open_price NUMERIC(10,2), high_price NUMERIC(10,2), low_price NUMERIC(10,2), close_price NUMERIC(10,2), volume BIGINT
);
INSERT INTO stock_prices VALUES
(1,'ALFA','2026-01-02',100,104,99,103,120000),
(2,'ALFA','2026-01-03',103,105,101,102,98000),
(3,'ALFA','2026-01-04',102,108,102,107,145000),
(4,'ALFA','2026-01-05',107,109,104,105,110000),
(5,'ALFA','2026-01-06',105,111,104,110,160000),
(6,'BETA','2026-01-02',250,254,247,252,85000),
(7,'BETA','2026-01-03',252,253,244,246,102000),
(8,'BETA','2026-01-04',246,251,245,250,93000),
(9,'BETA','2026-01-05',250,258,249,257,135000),
(10,'BETA','2026-01-06',257,260,253,255,119000);
-- 1. Daily percentage returns
WITH p AS (SELECT *, LAG(close_price) OVER (PARTITION BY ticker ORDER BY trade_date) AS prev_close FROM stock_prices)
SELECT ticker,trade_date,close_price,
 ROUND(100.0*(close_price-prev_close)/NULLIF(prev_close,0),2) AS daily_return_pct
FROM p ORDER BY ticker,trade_date;
-- 2. Period performance
SELECT ticker, MIN(trade_date) AS start_date, MAX(trade_date) AS end_date,
 ROUND(100.0*( (ARRAY_AGG(close_price ORDER BY trade_date DESC))[1] /
 (ARRAY_AGG(close_price ORDER BY trade_date))[1] - 1),2) AS period_return_pct
FROM stock_prices GROUP BY ticker;
-- 3. Moving average
SELECT ticker,trade_date,close_price,
 ROUND(AVG(close_price) OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS ma_3
FROM stock_prices;
-- 4. Daily trading range
SELECT ticker,trade_date,high_price-low_price AS intraday_range,
 ROUND(100.0*(high_price-low_price)/NULLIF(open_price,0),2) AS range_pct
FROM stock_prices;
-- 5. Volume leaders
SELECT ticker,SUM(volume) AS total_volume,ROUND(AVG(volume),0) AS avg_daily_volume
FROM stock_prices GROUP BY ticker ORDER BY total_volume DESC;
-- 6. Highest-volume trading days
SELECT ticker,trade_date,volume,
 DENSE_RANK() OVER (PARTITION BY ticker ORDER BY volume DESC) AS volume_rank
FROM stock_prices;
-- 7. Close price vs previous session
SELECT ticker,trade_date,close_price,
 close_price-LAG(close_price) OVER (PARTITION BY ticker ORDER BY trade_date) AS price_change
FROM stock_prices;
-- 8. Descriptive volatility proxy (sample standard deviation of daily close prices)
SELECT ticker,ROUND(STDDEV_SAMP(close_price),2) AS close_price_stddev
FROM stock_prices GROUP BY ticker;
