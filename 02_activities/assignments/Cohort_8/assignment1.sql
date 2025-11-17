/* ASSIGNMENT 1 */
/* SECTION 2 */

--SELECT
/* 1. Write a query that returns everything in the customer table. */
SELECT * 
FROM customer; 

/* 2. Write a query that displays all of the columns and 10 rows from the cus- tomer table, 
sorted by customer_last_name, then customer_first_ name. */
SELECT * 
FROM customer
ORDER BY customer_last_name, customer_first_name -- sort order not specified (assume default), LIMIT return depends on ORDER
LIMIT 10;


--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. */
SELECT * 
FROM customer_purchases 
WHERE product_id IN (4,9); -- no product_ids exist above 7

/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), 
filtered by customer IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
*/

-- option 1
SELECT * , quantity * cost_to_customer_per_qty AS price -- create price column 
FROM customer_purchases
WHERE customer_id >= '8' AND customer_id <='10';

-- option 2
SELECT * , quantity * cost_to_customer_per_qty AS price -- create price column 
FROM customer_purchases
WHERE customer_id BETWEEN '8' AND '10';  -- could also use IN (8,9,10)


--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */

/* SELECT DISTINCT product_qty_type FROM product -- get all possible cases 
		- overwriting NULL is bad practice unless intentional, fine here because:
				1) potatoes can be bought in bulk AND 
				2) this table is NOT individual purchases, quantity specified elsewhere 
*/
SELECT product_id,  product_name  

, CASE WHEN LOWER(product_qty_type) = 'unit'  THEN 'unit'
--	WHEN product_qty_type = 'lbs' THEN 'bulk' -- preserve NULL 
	ELSE 'bulk'  -- assign all other values bulk (intentional)
	END AS prod_qty_type_condensed  -- create output column 
		
FROM product;


/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */
SELECT product_id, product_name

, CASE WHEN LOWER(product_qty_type) = 'unit'  THEN 'unit'
	ELSE 'bulk'
	END AS prod_qty_type_condensed 

, CASE WHEN LOWER(product_name) LIKE '%pepper%'	THEN 1 -- contains pepper anywhere, case insensitive 
	ELSE 0
	END AS pepper_flag

FROM product;
--WHERE pepper_flag = 1 OR  (pepper_flag = 0 AND product_name LIKE '%pepper%') -- check 


--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by vendor_name, then market_date. */

/* check vendor_id 2, 5, 6 are absent from final table 
SELECT DISTINCT vendor_id FROM vendor WHERE vendor_id NOT IN (SELECT DISTINCT vendor_id FROM vendor_booth_assignments)
*/
SELECT 
v.*,  -- select all columns from vendor 
vb.booth_number, vb.market_date  -- exclude vendor_id in output table

FROM vendor AS v 	-- table order doesn't matter with INNER JOIN, yay!
INNER JOIN vendor_booth_assignments as vb
	ON v.vendor_id = vb.vendor_id 

ORDER BY vendor_name, market_date; --no sort order specified, assumed default 
-- WHERE vb.vendor_id IN (2,5,6); -- check inner join 


/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */
/* NOTES - vendors are not always assigned to the same booth  */

-- SELECT COUNT(DISTINCT vendor_id) AS num_vendors FROM vendor_booth_assignments -- query result should have 6 rows 
SELECT vendor_id, 
COUNT(booth_number) AS times_rented -- also could have used COUNT(*)  

FROM vendor_booth_assignments
GROUP BY vendor_id; -- aggregate


/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 
HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */

/* SELECT COUNT(DISTINCT customer_id) FROM customer_purchases; -- 26
SELECT COUNT(DISTINCT customer_id) FROM customer;  -- 26
SELECT DISTINCT customer_id FROM customer WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM customer_purchases)
*/
SELECT  
c.customer_id, 
c.customer_first_name,  
c.customer_last_name, -- c and cp (below) not needed since colnames are unique, here for explicitness 
SUM(cp.quantity*cp.cost_to_customer_per_qty) AS total_cost  -- calculate total_cost then sum across unique customer_id rows (group by)

FROM customer_purchases AS cp
INNER JOIN customer AS c -- INNER JOIN so table order doesn't matter, yay! 
		ON c.customer_id = cp.customer_id 

GROUP BY cp.customer_id -- cp.customer_first_name, cp.customer_last_name not needed as cp.customer_id already uniquely identifies 
HAVING total_cost > 2000 -- only customers spending > $2000 get a bumper sticker
ORDER BY c.customer_last_name, c.customer_first_name; -- sort order not further specified, assume default  


--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/

DROP TABLE IF EXISTS temp.new_vendor; -- if exists, drop it, otherwise do nothing 

CREATE  TABLE temp.new_vendor AS SELECT * FROM vendor;  -- copy vendor table; note this changes table typing and schema

INSERT INTO temp.new_vendor 
		VALUES (10, 'Thomass Superfood Store',  'Fresh Focused', 'Thomas', 'Rosenthal'); -- add entry manually; note that INSERT INTO + VALUES is one clause 
-- SELECT * FROM temp.new_vendor WHERE vendor_id = 10 -- confirm insertion worked as intended

/* To preserve typing and schema, recreate table using CREATE TABLE for vendor
CREATE TABLE temp.new_vendor (
  "vendor_id" int(11) NOT NULL ,
  "vendor_name" varchar(45) NOT NULL,
  "vendor_type" varchar(45) NOT NULL,
  "vendor_owner_first_name" varchar(45) NOT NULL,
  "vendor_owner_last_name" varchar(45) NOT NULL,
  PRIMARY KEY ("vendor_id"),
  UNIQUE  ("vendor_id"),
  UNIQUE  ("vendor_name")
)

INSERT INTO temp.new_vendor SELECT * FROM vendor
INSERT INTO temp.new_vendor VALUES (10, 'Thomass Superfood Store',  'Fresh Focused', 'Thomas', 'Rosenthal'); -- add entry manually; note that INSERT INTO + VALUES is one clause 
SELECT * FROM temp.new_vendor WHERE vendor_id = 10 -- confirm insertion worked as intended
*/

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.
HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */
SELECT customer_id,
strftime('%m',market_date) AS month,
strftime('%Y',market_date) AS year

FROM customer_purchases;


/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */

SELECT cp.customer_id,
--c.customer_last_name,  c.customer_first_name,
SUM(cp.quantity * cp.cost_to_customer_per_qty) AS ['April 2022 Spend']

FROM customer_purchases as cp
--INNER JOIN customer as c
--	ON c.customer_id = cp.customer_id

WHERE strftime('%m', cp.market_date) = '04' AND strftime('%Y', cp.market_date) = '2022'
GROUP BY cp.customer_id;
