SELECT TOP 10 * FROM OrderItemRefunds
SELECT TOP 10 * FROM OrderItems
SELECT TOP 10 * FROM Orders
SELECT TOP 10 * FROM Products
SELECT TOP 10 * FROM WebsitePageviews
SELECT TOP 10 * FROM WebsiteSessions

--Dulplicates in Orders Table
SELECT
	order_id
FROM 
	Orders
GROUP BY 
	order_id
HAVING 
	COUNT(order_id) > 1

--Dulplicates in Orders Items Table
SELECT
	order_item_id
FROM 
	OrderItems
GROUP BY 
	order_item_id
HAVING 
	COUNT(order_item_id) > 1

--Dulplicates in Orders Item Refunds Table
SELECT
	order_item_refund_id
FROM 
	OrderItemRefunds
GROUP BY 
	order_item_refund_id
HAVING 
	COUNT(order_item_refund_id) > 1

--Dulplicates in Products
SELECT
	product_id
FROM 
	Products
GROUP BY 
	product_id
HAVING 
	COUNT(product_id) > 1

--Dulplicates in Website Sessions Table
SELECT
	website_session_id
FROM 
	WebsiteSessions
GROUP BY 
	website_session_id
HAVING 
	COUNT(website_session_id) > 1

--Dulplicates in Website Pageview Table
SELECT
	website_pageview_id
FROM 
	WebsitePageviews
GROUP BY 
	website_pageview_id
HAVING 
	COUNT(website_pageview_id) > 1


--Price USD > 0 in Orders Table
SELECT
	*
FROM
	Orders
WHERE
	price_usd <= 0

--Cogs USD > 0 in Orders Table
SELECT
	*
FROM
	Orders
WHERE
	cogs_usd <= 0

--Cogs > Price USD in Orders Table
SELECT
	*
FROM
	Orders
WHERE
	cogs_usd >= price_usd

--Price USD > 0 in Order Items Table
SELECT
	*
FROM
	OrderItems
WHERE
	price_usd <= 0

--Cogs USD > 0 in Order Items Table
SELECT
	*
FROM
	OrderItems
WHERE
	cogs_usd <= 0

--Cogs > Price USD in Orders Items Table
SELECT
	*
FROM
	OrderItems
WHERE
	cogs_usd >= price_usd

--Refund Amount USD > Price USD
SELECT
	*
FROM 
	OrderItems as oi
INNER JOIN 
	OrderItemRefunds as orf
ON
	oi.order_item_id = orf.order_item_id
WHERE 
	refund_amount_usd > price_usd

--Sum of Items Purchased = Number of Rows in Order Item Table
SELECT
	SUM(items_purchased) as Total_Items_Sold,
	(
	 SELECT
		COUNT(order_item_id) as Total_Order_Items
	 FROM OrderItems
	 ) as Total_Order_Items
FROM Orders

--Sum of Price USD in Orders = Sum of Price USD in Order Items Table
SELECT
	SUM(price_usd) as Total_Revenue_Orders,
	(
	 SELECT
		SUM(price_usd) as Total_Revenue_OrderItems
	 FROM OrderItems
	 ) as Total_Revenue_OrderItems
FROM Orders

--Sum of COGS USD in Orders = Sum of COGS USD in Order Items Table
SELECT
	SUM(cogs_usd) as Total_COGS_Orders,
	(
	 SELECT
		SUM(cogs_usd) as Total_COGS_OrderItems
	 FROM OrderItems
	 ) as Total_COGS_OrderItems
FROM Orders

--Order ID in Order Items must exist in Orders Table
SELECT
	DISTINCT(order_id)
FROM OrderItems

EXCEPT

SELECT
	DISTINCT(order_id)
FROM Orders

--Product ID in Orders Items Table must exist in Product Table
SELECT
	DISTINCT(product_id)
FROM OrderItems

EXCEPT

SELECT
	DISTINCT(product_id)
FROM Products

-- Is Primary Item should always be 1 or 0
SELECT
	DISTINCT(is_primary_item)
FROM
	OrderItems

--Primary Product ID in Orders Table must exist in Product Table
SELECT
	DISTINCT(primary_product_id)
FROM Orders

EXCEPT

SELECT
	DISTINCT(product_id)
FROM Products

--Refund Created at should be >= Order Created at
SELECT
	*
FROM
	OrderItems as o
INNER JOIN
	OrderItemRefunds as orf
ON
	o.order_item_id = orf.order_item_id
WHERE
	orf.created_at <= o.created_at

--Product Created at should be <= Order Created at
SELECT
	*
FROM
	OrderItems as o
INNER JOIN
	Products as p
ON
	o.product_id = p.product_id
WHERE
	p.created_at >= o.created_at

--Website Session Id in Website Pageview Table must exist in Website Sessions Table
SELECT
	DISTINCT(website_session_id)
FROM WebsitePageviews

EXCEPT

SELECT
	DISTINCT(website_session_id)
FROM WebsiteSessions


--Website Sessions where UTM Params are 'NULL' and HTTP Referer is also 'NULL'
SELECT
	* 
FROM 
	WebsiteSessions
WHERE
	(utm_campaign = 'NULL' AND utm_content = 'NULL' AND utm_source = 'NULL') and http_referer = 'NULL'

--Website Sessions where UTM Params are 'NULL' and HTTP Referer is not 'NULL'
SELECT
	* 
FROM 
	WebsiteSessions
WHERE
	(utm_campaign = 'NULL' AND utm_content = 'NULL' AND utm_source = 'NULL') and http_referer != 'NULL'

--Total Website Session Where any one UTM Params are 'NULL'
SELECT
	* 
FROM 
	WebsiteSessions
WHERE
	(utm_campaign = 'NULL' or utm_content = 'NULL' or utm_source = 'NULL')

----Total Website Session Where all UTM Params are 'NULL'
SELECT
	* 
FROM 
	WebsiteSessions
WHERE
	(utm_campaign = 'NULL' AND utm_content = 'NULL' AND utm_source = 'NULL')