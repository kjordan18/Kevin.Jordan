
USE sakila;

-- return first and last name columns
SELECT first_name, last_name
FROM actor;

-- create column as Actor_Name
SELECT CONCAT_WS(' ', actor.first_name, actor.last_name) AS Actor_Name
FROM actor;

-- ID number with first name "Joe"

SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.first_name = "Joe";

-- actors with last name CONTAINING "GEN"

SELECT actor.actor_id, actor.first_name, actor.last_name
FROM sakila.actor
WHERE actor.last_name LIKE '%GEN%';

-- last names contain the letters LI, order the rows by last name and first name

SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.last_name LIKE '%LI%' ORDER BY a.last_name;

-- country id, country of Afghanistan, Bangladesh, and China

SELECT c.country_id, c.country
FROM country c
WHERE c.country = "Afghanistan" OR c.country = "Bangladesh" OR c.country = "China";

-- middle name column

ALTER TABLE actor
ADD middle_name VARCHAR(25) AFTER first_name; 

-- type(middle name) -> blobs

ALTER TABLE actor
MODIFY middle_name BLOB;

-- delete middle name column

ALTER TABLE actor
DROP middle_name;

-- last name of actors with how many of each last name exists

SELECT COUNT(last_name), last_name
FROM actor 
GROUP BY last_name
ORDER BY last_name ASC;

-- last name and count of actors with multiple last name entries

SELECT COUNT(last_name), last_name
FROM actor 
GROUP BY last_name
HAVING COUNT(last_name) >= 2
ORDER BY last_name ASC;

-- Change 'Groucho' to 'Harpo'

SELECT first_name, last_name, actor_id 
FROM actor 
WHERE first_name = 'Groucho' AND last_name = 'Williams';

UPDATE actor SET first_name = 'Harpo'  WHERE actor_id = 172;

-- If the first name is HARPO, change it to GROUCHO, otherwise, change the first name to MUCHO GROUCHO

UPDATE actor SET first_name = 
CASE WHEN first_name = 'Harpo' THEN 'Groucho' ELSE 'Mucho Groucho' END 
WHERE actor_id = 172;

SHOW CREATE TABLE address;

-- Display  first, last names, and address, of each staff member (use the tables staff and address): 

SELECT s.last_name, s.first_name, a.address 
FROM staff s
INNER JOIN address a 
ON s.address_id = a.address_id;

-- Display total amount rung up by each staff member in August of 2005 (use tables staff and payment). 

SELECT s.last_name, s.first_name, SUM(p.amount)
FROM staff s
INNER JOIN payment p 
ON s.staff_id = p.staff_id
WHERE MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
GROUP BY s.staff_id;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT COUNT(fa.actor_id) AS 'Actor Count', f.title 
FROM film_actor fa 
INNER JOIN film f 
ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY `Actor Count` DESC;

SELECT f.title, COUNT(i.inventory_id) 
FROM film f 
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;


-- List the total paid by each customer. List the customers alphabetically by last name:
SELECT c.customer_id, c.last_name, c.first_name, COUNT(p.amount) AS 'Total Paid' 
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;

-- Display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film 
WHERE title LIKE 'K%' OR title like 'Q%' AND language_id IN 
(
	SELECT language_id 
	FROM language 
    WHERE name = 'English'
);

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name  
FROM actor 
WHERE actor_id IN 
(
	SELECT actor_id
	FROM film_actor 
    WHERE film_id IN 
    (
		SELECT film_id 
        FROM film
        WHERE title = 'Alone Trip'
	)
);

-- Need the names and email addresses of all Canadian customer
SELECT c.first_name, c.last_name, c.email, co.country
FROM customer c
    INNER JOIN address a 
        ON a.address_id = c.address_id
    INNER JOIN city ci
        ON ci.city_id = a.address_id
	INNER JOIN country co
		ON co.country_id = ci.country_id
        where co.country like 'Canada';

-- Identify all movies categorized as famiy films.
SELECT title 
FROM film
WHERE film_id IN
	(
		SELECT film_id
		FROM film_category
		WHERE category_id IN 
		(
			SELECT category_id
			FROM category
			WHERE name LIKE 'Family%'
		));


-- Display the most frequently rented movies in descending order.
SELECT count(r.inventory_id) as 'Rentals', f.title
FROM film f
    INNER JOIN inventory i 
        ON f.film_id = i.film_id
	INNER JOIN rental r
		ON r.inventory_id = i.inventory_id
	GROUP BY f.title
	ORDER BY count(r.inventory_id) DESC;


-- Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, sum(p.amount) AS 'Total In Dollars'
FROM payment p
    INNER JOIN staff st 
        ON p.staff_id = st.staff_id
	INNER JOIN store s
		ON st.store_id = s.store_id
	GROUP BY s.store_id;

-- Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, ci.city, co.country
FROM store s
	JOIN address a
		ON a.address_id = s.address_id
	JOIN city ci 
        ON a.city_id = ci.city_id
	JOIN country co 
        ON ci.country_id = co.country_id
	GROUP BY s.store_id;

-- List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name, SUM(p.amount) AS 'Gross Rental ($)'
FROM payment p
	JOIN  rental r
		ON p.customer_id = r.customer_id
	JOIN inventory i 
        ON i.inventory_id = r.inventory_id
	JOIN film f
		ON f.film_id = i.film_id
	JOIN film_category fc 
        ON f.film_id = fc.film_id
	JOIN category c
		on fc.category_id = c.category_id
	GROUP BY c.name
    ORDER BY sum(p.amount) DESC LIMIT 5;
    
-- Use the solution from the problem above to create a view.

CREATE VIEW Top_5_Genres AS
SELECT c.name, sum(p.amount) AS 'Gross Rental ($)'
FROM payment p
	JOIN  rental r
		ON p.customer_id = r.customer_id
	JOIN inventory i 
        ON i.inventory_id = r.inventory_id
	JOIN film f
		ON f.film_id = i.film_id
	JOIN film_category fc 
        ON f.film_id = fc.film_id
	JOIN category c
		on fc.category_id = c.category_id
	GROUP BY c.name
    ORDER BY sum(p.amount) DESC LIMIT 5;
    
-- How would you display the view that you created in 8a?
SELECT * FROM Top_5_Genres;

-- delete view
DROP VIEW Top_5_Genres;


