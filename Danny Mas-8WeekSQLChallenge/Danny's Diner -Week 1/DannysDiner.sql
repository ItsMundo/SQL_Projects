-- Danny's Diner
-- Solutions to Week 1 questions

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	customer_id
	, SUM(M.price) AS total_spent
FROM 
	w1_sales AS S
JOIN 
	w1_menu AS M 
ON 
	S.product_id = M.product_id
GROUP BY 
	1;
-- 2. How many days has each customer visited the restaurant?
SELECT 
	customer_id
	,COUNT(DISTINCT order_date) AS 'Days Visited'
FROM 
	w1_sales
GROUP BY 
	1
ORDER BY 
	2 DESC;
-- 3. What was the first item from the menu purchased by each customer?
WITH FirstPurchase AS
	(SELECT 
		S.customer_id
		,M.product_name
		,ROW_NUMBER() OVER (PARTITION BY S.customer_id ORDER BY S.order_date, S.product_id) AS RN
		FROM 
			w1_sales AS S
		JOIN 
			w1_menu AS M
		ON S.product_id = M.product_id
	)
SELECT 
	customer_id
	,product_name
FROM
	FirstPurchase
WHERE 
	RN = 1;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
	M.product_name
    ,COUNT(S.product_id) AS '# Purchased'
FROM 
	w1_menu AS M
JOIN
	w1_sales AS S 
ON 
	M.product_id = S.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- 5. Which item was the most popular for each customer?
WITH MostPopular AS
	(
    SELECT 
		S.customer_id AS C_Id
		,M.product_name AS P_Name
		,RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(M.productid) DESC) AS RNK
		FROM 
			w1_sales AS S
		JOIN 
			w1_menu AS M 
		ON S.product_id = M.product_id
		GROUP BY 1,2
	)
SELECT 
	*
FROM 
	MostPopular
WHERE 
	RNK = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH FirstMemberPurchase AS
	(
		SELECT
			M.customer_id AS Customer
			,M2.product_name AS Product
			,RANK() OVER (PARTITION BY M.customer_id ORDER BY S.order_date) AS RNK
		FROM 
			w1_members AS M
		JOIN 
			w1_sales AS S 
		ON 
			S.customer_id = M.customer_id
		JOIN 
			w1_menu AS M2
		ON 
			S.product_id = M2.product_id
		WHERE 
			S.order_date >= M.join_date
	)
SELECT 
	Customer
	,Product
FROM 
	FirstMemberPurchase
WHERE 
	RNK = 1;
-- 7. Which item was purchased just before the customer became a member?
WITH LastNonmemberPurchase AS
	(
		SELECT 
			M.customer_id AS Customer
			,M2.product_name AS Product
			,RANK() OVER (PARTITION BY M.customer_id ORDER BY S.order_date DESC) AS RNK
		FROM 
			w1_members AS M
		JOIN 
			w1_sales AS S 
		ON 
			S.customer_id = M.customer_id
		JOIN 
			w1_menu AS M2 
		ON 
			S.product_id = M2.product_id
		WHERE 
			S.order_date < M.join_date
	)
SELECT 
	Customer
	,Product
FROM 
	LastNonmemberPurchase
WHERE 
	RNK = 1;
-- 8. What is the total items and amount spent for each member before they became a member?
WITH TotalNonMemberPurchase AS
	(
		SELECT 
			M.customer_id AS Customer
			,COUNT(M2.product_id) AS TotalItems
			,SUM(M2.price) AS TotalSpent
		FROM 
			w1_members AS M
		JOIN 
			w1_sales AS S 
		ON 
			S.customer_id = M.customer_id
		JOIN 
			w1_menu AS M2 
		ON 
			S.product_id = M2.product_id
		WHERE 
			S.order_date < M.join_date
		GROUP BY Customer
	)
SELECT 
	*
FROM 
	TotalNonMemberPurchase
ORDER BY customer;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH TotalMemberPts AS
	(
		SELECT 
			M.customer_id AS Customer
			,SUM(CASE
					WHEN M2.product_name = 'sushi' 
						THEN (M2.price * 20)
						ELSE (M2.price * 10)
				END) AS Member_Points
		FROM 
			w1_members AS M
		JOIN 
			w1_sales AS S 
        ON 
			S.customer_id = M.customer_id
		JOIN 
			w1_menu AS M2 
		ON S.product_id= M2.product_id
		GROUP BY Customer
	)
SELECT 
	*
FROM 
	TotalMemberPts;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH JanMemberPts AS
	(
		SELECT 
			M.customer_id AS customer
			,SUM(CASE
					WHEN s.order_date < m.join_date 
                    THEN
						CASE
							WHEN M2.product_name = 'sushi' 
                            THEN (M2.price * 20)
							ELSE (M2.price* 10)
						END
					WHEN S.order_date > (m.join_date + 6) 
                    THEN 
						CASE
							WHEN M2.product_name= 'sushi' 
                            THEN (M2.price * 20)
							ELSE (M2.price* 10)
						END 
					ELSE (M2.price* 20)	
				END) AS MemberPts
		FROM 
			w1_members AS M
		JOIN 
			w1_sales AS S 
		ON 
			S.customer_id= M.customer_id
		JOIN 
			w1_menu AS M2 
		ON 
			S.product_id = M2.product_id
		WHERE 
			S.order_date <= '2021-01-31'
		GROUP BY customer
	)
SELECT 
	*
FROM 
	JanMemberPts
ORDER BY customer;

-- bonus questions
-- Join All The Things

SELECT
	S.customer_id
    ,S.order_date
    ,M.product_name
    ,M.price
	,(CASE 
		WHEN 
			MM.join_date>S.order_date
			THEN 'N'
		WHEN
			MM.join_date <= S.order_date
			THEN 'Y'
		ELSE'N'
	END) AS 'member'
FROM
	w1_sales AS S
LEFT JOIN
	w1_menu AS M
ON
	S.product_id=M.product_id
LEFT JOIN
	w1_members AS MM
ON
	S.customer_id=MM.customer_id;