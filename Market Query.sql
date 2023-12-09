-- create database
create database market_basket_analysis
-- Data Cleaning
-- change table names
EXEC sp_rename 'QVI_purchase_behaviour','purchase_behaviour_data'
EXEC sp_rename 'QVI_transaction_data','transaction_data'

-- change column headers (purchase behaviour)
USE market_basket_analysis;
begin transaction;
sp_rename 'QVI_purchase_behaviour.LYLTY_CARD_NBR', 'customer_id','column'
sp_rename 'QVI_purchase_behaviour.PREMIUM_CUSTOMER', 'customer_category', 'column'
sp_rename 'QVI_purchase_behaviour.LIFESTAGE', 'customer_lifestage','column'

-- change column headers (transaction data)
sp_rename 'QVI_transaction_data.DATE','Date','column'
sp_rename 'QVI_transaction_data.STORE_NBR', 'Store_number', 'column'
sp_rename 'QVI_transaction_data.LYLTY_CARD_NBR', 'customer_id', 'column'
sp_rename 'QVI_transaction_data.TXN_ID', 'tax_id', 'column'
sp_rename 'QVI_transaction_data.PROD_NBR', 'product_id', 'column'
sp_rename 'QVI_transaction_data.PROD_NAME', 'product_name','column'
sp_rename 'QVI_transaction_data.PROD_QTY', 'production_quantity','column'
sp_rename 'QVI_transaction_data.TOT_SALES', 'total_sales','column'
sp_rename 'transaction_data.tax_id', 'transaction_id', 'column'

-- View datasets
SELECT * FROM transaction_data
SELECT * FROM purchase_behaviour_data


-- To get rid of the space
SELECT 'product_name', REPLACE('product_name','  ',' ')
from transaction_data
SELECT product_name, TRIM(LTRIM(RTRIM(product_name)))
from transaction_data
SELECT 'product_name', TRANSLATE('product_name', ' ', ' ') AS cleaned_column
FROM transaction_data;
SELECT Product_name, LTRIM(substring(product_name,patindex('%  %',product_name),len('% _____________________________ ')))
FROM transaction_data;
SELECT product_name, substring(product_name,1,len('__________________ %'))
from transaction_data



-- Market Basket Analysis
-- What are the most frequently bought together products?
WITH market AS (
		SELECT t.product_name as product1, 
			   d.product_name as product2,
			   COUNT(1) as frequency,
			   (SELECT COUNT(transaction_id) FROM transaction_data) as total_transaction,
			   (SELECT COUNT(transaction_id) FROM transaction_data e
				   WHERE e.product_name = t.product_name) as frequency_lhs,
			   (SELECT COUNT(transaction_id) FROM transaction_data e
				   WHERE e.product_name = d.product_name) as frequency_rhs
		FROM transaction_data t
		JOIN transaction_data d
		  ON t.transaction_id = d.transaction_id
		WHERE t.product_name > d.product_name
		GROUP BY t.product_name, d.product_name
)
SELECT product1,
	   product2,
	   frequency, 
	   (frequency*100.0/total_transaction) as support,
	   (frequency/frequency_lhs)*100.0 as confidence,
	   ceiling((frequency*100.0/total_transaction)/
	   ((frequency_lhs*100.0/total_transaction)* (frequency_rhs*100.0/total_transaction))) as lift
FROM market
ORDER BY frequency desc

