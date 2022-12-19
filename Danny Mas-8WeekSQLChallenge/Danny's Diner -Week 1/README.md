# Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

# Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

* `sales`
* `menu`
* `members`

# Entity Relationship Diagram

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/ERD.JPG)

***As a personal preference, I decided to make a database to house all of the tables inside of it in MySQL Workbench. So for this weeks schema, I have annotated each table with a "w1_" and will do the same for the following weeks to come.***

# Example Datasets

## **sales**
The sales table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered. 
|customer_id|order_date|product_id|
|--|--|--|
|A|2021-01-01|1|
|A|2021-01-01|2|
|A|2021-01-07|2|
|A|2021-01-10|3|
|A|2021-01-11|3|
|A|2021-01-11|3|
|B|2021-01-01|2|
|B|2021-01-02|2|
|B|2021-01-04|1|
|B|2021-01-11|1|
|B|2021-01-16|3|
|B|2021-02-01|3|
|C|2021-01-01|3|
|C|2021-01-01|3|
|C|2021-01-07|3|

## **menu**
The `menu` table maps the `product_id` to the actual `product_name` and `price` of each menu item. 
|product_id|product_name|price|
|--|--|--|
|1|sushi|10|
|2|curry|15|
|3|ramen|12|


## **members**
The final `members` table captures the `join_date` when a `customer_id` joined the beta version of the Danny's Diner loyalty program. 
|customer_id|join_date|
|--|--|
|A|2021-01-07|
|B|2021-01-09|

# Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

[1. What is the total amount each customer spent at the restaurant?](#q-1)

[2. How many days has each customer visited the restaurant?](#q-2)

[3. What was the first item from the menu purchased by each customer?](#q-3)

[4. What is the most purchased item on the menu and how many times was it purchased by all customers?](#q-4)

[5. Which item was the most popular for each customer?](#q-5)

[6. Which item was purchased first by the customer after they became a member?](#q-6)

[7. Which item was purchased just before the customer became a member?](#q-7)

[8. What is the total items and amount spent for each member before they became a member?](#q-8)

[9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?](#q-9)

[10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?](#q-10)

[11. Bonus Question](#q-11)

# Solutions
<a name="q-1"><a/>
1. What is the total amount each customer spent at the restaurant?

```SQL
SELECT 
	customer_id
	,SUM(M.price) AS total_spent
FROM 
	w1_sales AS S
JOIN 
	w1_menu AS M 
ON 
	S.product_id = M.product_id
GROUP BY 
	1;
```
We needed to do a join on this query because the customer_id is from the sales table and the price is from the menu table. The use of the SUM function was used find out the total amount of money spent and the GROUP BY function so that it would distribute all of the information by customer instead of just one row in the table. 

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q1.JPG)

<a name="q-2"><a/>
2. How many days has each customer visited the restaurant?
```SQL
SELECT 
	customer_id
	,COUNT(DISTINCT order_date) AS 'Days Visited'
FROM 
	w1_sales
GROUP BY 
	1
ORDER BY 
	2 DESC;
```

The COUNT function was used in conjunction with DISTINCT to only count the singular days that each customer visited the restaurant.

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q2.JPG)

<a name="q-3"><a/>
3. What was the first item from the menu purchased by each customer?
```SQL 
WITH FirstPurchase AS
	(SELECT 
		S.customer_id
		,M.product_name
		,ROW_NUMBER() OVER (PARTITION BY S.customer_id ORDER BY S.order_date, S.product_id) AS RN
		FROM 
			w1_sales AS S
		JOIN 
			w1_menu AS M
		ON 
            S.product_id = M.product_id
	)
SELECT 
	customer_id
	,product_name
FROM
	FirstPurchase
WHERE 
	RN = 1;
```
The use of common table expressions help with the organization of thought processes when tackling the query. Utilizing the window function ROW_NUMBER to add a count of the items by customer then limiting the output to only the first in the partition. 

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q3.JPG)

<a name="q-4"><a/>
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```SQL
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
```
Using the COUNT function again, we can get a number of how many products were purchased and then GROUP BY on the joined menu table to see how many of each were sold by product name. Limiting the results to 1 since we are only interested in getting the most purchased item.

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q4.JPG)

<a name="q-5"><a/>
5. Which item was the most popular for each customer?
```SQL
WITH MostPopular AS
	(
    SELECT 
		S.customer_id AS C_Id
		,M.product_name AS P_Name
		,RANK() OVER (PARTITION BY CUSTOMER_ID ORDER BY COUNT(M.PRODUCT_ID) DESC) AS RNK
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
```

Again using the window function of Rank, I was able to apply a rank on how many times each of the products were ordered by each customer and limit to the highest ranked product was. From the results it looks like Customer B has ordered the same amount of meals for each type indicating they have no preference as to most popular. 

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q5.JPG)

<a name="q-6"><a/>
6. Which item was purchased first by the customer after they became a member?
```SQL
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
```

Using the Rank window function, applying the rank based on the order date regarding the customer ID I applied the condition where the order date was greater than the join date but also limiting to the first rank so that it only showed the first of each Member order. 

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q6.JPG)

<a name="q-7"><a/>
7. Which item was purchased just before the customer became a member?
```SQL
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
```

Similar to the query from the previous question, the only difference was changing the Where clause to limit the order dates BEFORE the join date instead of AFTER. 

![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q7.JPG)

<a name="q-8"><a/>
8. What is the total items and amount spent for each member before they became a member?
```SQL
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
```
![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q8.JPG)

<a name="q-9"><a/>
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```SQL
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
```
![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q9.JPG)

<a name="q-10"><a/>
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```SQL
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
```
![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/Q10.JPG)

<a name="q-11"><a/>
11. Bonus Question

Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
```SQL
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
```
![image](https://github.com/ItsMundo/SQL_Projects/blob/main/Danny%20Mas-8WeekSQLChallenge/Danny's%20Diner%20-Week%201/Images/BonusQ.JPG)
