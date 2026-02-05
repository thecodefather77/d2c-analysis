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


UPDATE WebsiteSessions
SET 
    utm_campaign = 'Direct',
    utm_content = 'Direct',
    utm_source = 'Direct'
WHERE 
    utm_campaign = 'NULL'
    AND utm_content = 'NULL'
    AND utm_source = 'NULL'
    AND http_referer != 'NULL';

UPDATE WebsiteSessions
SET 
    utm_campaign = 'Unrecorded',
    utm_content = 'Unrecorded',
    utm_source = 'Unrecorded',
	http_referer = 'Unrecorded'
WHERE
    utm_campaign = 'NULL'
    AND utm_content = 'NULL'
    AND utm_source = 'NULL'
    AND http_referer = 'NULL';


select MONTH(created_at) as [month], YEAR(created_at) as [year], COUNT(website_session_id) as [count] from WebsiteSessions
group by MONTH(created_at), YEAR(created_at)

select a.[month], AVG(a.count)
from (select MONTH(created_at) as [month], YEAR(created_at) as [year], COUNT(website_session_id) as [count] from WebsiteSessions
group by year(created_at), month(created_at)) as a

group by a.[month]




select website_session_id, MIN(created_at), MAX(created_at) from WebsitePageviews
group by website_session_id

select website_session_id, DATEDIFF(SECOND, MIN(created_at), max(created_at)) as duration from WebsitePageviews
group by website_session_id

select	AVG(A.duration)
from 
(select website_session_id, cast(DATEDIFF(MINUTE, MIN(created_at), max(created_at)) AS decimal(10,2)) as duration 
from WebsitePageviews
where YEAR(created_at) = 2015
group by website_session_id) as A

select website_session_id, pageview_url,MIN(created_at), MAX(created_at) from WebsitePageviews
group by website_session_id, pageview_url
order by website_session_id


select	A.pageview_url, AVG(A.duration) from (select website_session_id, pageview_url,cast(DATEDIFF(SECOND, MIN(created_at), max(created_at)) AS decimal(10,2)) as duration from WebsitePageviews
group by website_session_id, pageview_url) as A
groUP BY A.pageview_url


SELECT 
    A.pageview_url,
    AVG(A.duration) AS avg_duration_seconds
FROM (
    SELECT 
        website_session_id,
        pageview_url,
        CAST(
            DATEDIFF(SECOND, MIN(created_at), MAX(created_at)) AS DECIMAL(10,10)
        ) AS duration
    FROM WebsitePageviews
    GROUP BY website_session_id, pageview_url
    HAVING DATEDIFF(SECOND, MIN(created_at), MAX(created_at)) > 0
) AS A
GROUP BY A.pageview_url;


SELECT 
    weekday_name,
    AVG(daily_count) AS avg_transactions
FROM (
    SELECT 
        CAST(created_at AS DATE) AS session_date,
        DATENAME(WEEKDAY, created_at) AS weekday_name,
        COUNT(website_session_id) AS daily_count
    FROM WebsiteSessions
    GROUP BY 
        CAST(created_at AS DATE),
        DATENAME(WEEKDAY, created_at)
) AS d
GROUP BY weekday_name
ORDER BY 
    CASE weekday_name
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;


select order_id, COUNT(order_item_id) as [count] from OrderItems
group by order_id
having COUNT(order_item_id) > 1
order by [count] desc


select pageview_url, COUNT(website_pageview_id) from WebsitePageviews
group by pageview_url


select website_session_id, COUNT(pageview_url) from WebsitePageviews
group by website_session_id
having count(pageview_url) = 1

With SinglePageView as (
	SELECT
		website_session_id,
		COUNT(pageview_url) as [PageCount]
	From 
		WebsitePageviews
	GROUP BY 
		website_session_id
	HAVING
		COUNT(pageview_url) = 1
),
TotalPageViews as (
	SELECT
		pageview_url,
		COUNT(website_pageview_id) as TotalViews
	FROM
		WebsitePageviews
	GROUP BY
		pageview_url
),
Joined as (
	SELECT
		sp.website_session_id,
		sp.[PageCount],
		wp.pageview_url
	FROM 
		SinglePageView as sp
	LEFT JOIN 
		WebsitePageviews as wp
	ON
		sp.website_session_id = wp.website_session_id
),
BounceAggTable as (
	SELECT 
		pageview_url,
		SUM(PageCount) as [TotalBounce]
	FROM
		Joined
	GROUP BY
		pageview_url
),
PageviewsFinal as (
	SELECT
		tp.pageview_url,
		tp.TotalViews,
		ba.TotalBounce
	FROM
		TotalPageViews as tp
	LEFT JOIN
		BounceAggTable as ba
	ON tp.pageview_url = ba.pageview_url
)

SELECT
	pageview_url,
	(TotalBounce / TotalViews) as BouncERate
FROM
	PageviewsFinal



--==================================
WITH SinglePageView AS (
    SELECT
        website_session_id,
        COUNT(pageview_url) AS PageCount
    FROM WebsitePageviews
    GROUP BY website_session_id
    HAVING COUNT(pageview_url) = 1
),
TotalPageViews AS (
    SELECT
        pageview_url,
        COUNT(website_pageview_id) AS TotalViews
    FROM WebsitePageviews
    GROUP BY pageview_url
),
Joined AS (
    SELECT
        sp.website_session_id,
        sp.PageCount,
        wp.pageview_url
    FROM SinglePageView AS sp
    LEFT JOIN WebsitePageviews AS wp
        ON sp.website_session_id = wp.website_session_id
),
BounceAggTable AS (
    SELECT 
        pageview_url,
        SUM(PageCount) AS TotalBounce
    FROM Joined
    GROUP BY pageview_url
),
PageviewsFinal AS (
    SELECT
        tp.pageview_url,
        tp.TotalViews,
        COALESCE(ba.TotalBounce, 0) AS TotalBounce
    FROM TotalPageViews AS tp
    LEFT JOIN BounceAggTable AS ba
        ON tp.pageview_url = ba.pageview_url
)
SELECT
    pageview_url,
    CAST(TotalBounce AS FLOAT) / NULLIF(TotalViews, 0) AS BounceRate
FROM PageviewsFinal
ORDER BY BounceRate DESC;


select top 2 * from WebsiteSessions
select top 2 * from WebsitePageviews
select top 2 * from Orders

select distinct pageview_url from WebsitePageviews