-- Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- ● Account tenure (months since signup)
-- ● Total transactions
-- ● Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
-- ● Order by estimated CLV from highest to lowest

USE adashi_staging;

-- CTE to get average profit_per_transaction per customer
WITH appt AS (
SELECT 
	owner_id,
	COUNT(transaction_reference) AS total_transactions,
	(0.001*SUM(confirmed_amount)) / COUNT(transaction_reference) AS avg_profit_per_transaction
FROM savings_savingsaccount
GROUP BY owner_id
)

SELECT
	u.id AS owner_id,
	CONCAT(u.first_name, ' ', u.last_name) AS name,
	TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    	a.total_transactions,
    ROUND((a.total_transactions / (TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()))) * 12 * avg_profit_per_transaction,2) AS estimated_clv
FROM users_customuser AS u
JOIN appt AS a ON u.id = a.owner_id
ORDER BY estimated_clv DESC;
