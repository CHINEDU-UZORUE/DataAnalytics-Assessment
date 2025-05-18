-- Task: Write a query to find customers with at least one funded savings plan AND 
-- one funded investment plan, sorted by total deposits.


USE adashi_staging;
-- CTE to retrieve customers with at least ONE savings plan
WITH savings_customers AS (
    SELECT owner_id,
    SUM(is_regular_savings) AS savings_count
    FROM plans_plan
    WHERE is_regular_savings = 1 -- savings_plan : is_regular_savings = 1
    GROUP BY owner_id
),
-- CTE to retrieve customers with at least ONE investment plan
investment_customers AS (
    SELECT owner_id,
    SUM(is_a_fund) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1 -- investment_plan: is_a_fund = 1
    GROUP BY owner_id
),

-- This CTE combines the previous 2 CTEs to get customers that satisfy both conditions
qualified_customers AS (
    SELECT s.owner_id,
    s.savings_count AS savings_count,
    i.investment_count AS investment_count
    FROM savings_customers s
    INNER JOIN investment_customers i ON s.owner_id = i.owner_id
)

SELECT 
    qc.owner_id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    qc.savings_count,
    qc.investment_count,
    SUM(a.confirmed_amount) AS total_deposits
FROM qualified_customers qc
JOIN users_customuser u ON qc.owner_id = u.id
JOIN savings_savingsaccount a ON u.id = a.owner_id
GROUP BY u.id
ORDER BY total_deposits DESC;
