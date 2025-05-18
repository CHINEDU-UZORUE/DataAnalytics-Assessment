-- Task: Find all active accounts (savings or investments) with no transactions
-- in the last 1 year (365 days) .

USE adashi_staging;

-- CTE to get last transaction date of active accounts
WITH latest_txn AS (
    SELECT 
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    -- AND transaction_status = 'success'
    GROUP BY plan_id
),

-- CTE to identify all active plans
all_active_plans AS (
    SELECT 
        id AS plan_id,
        owner_id,
        created_on,
        CASE 
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
        END AS type
    FROM plans_plan 
    WHERE (is_regular_savings = 1 OR is_a_fund = 1) 

)

-- Final query to get all active accounts (savings or investments) with no transactions
-- in the last 1 year (365 days)

SELECT 
    a.plan_id,
    a.owner_id,
    a.type,
    COALESCE(DATE(lt.last_transaction_date),DATE(a.created_on)) AS last_transaction_date,  -- Using the DATE() function to get only the date part
    DATEDIFF(CURDATE(), COALESCE(lt.last_transaction_date, a.created_on)) AS inactivity_days
FROM all_active_plans a
LEFT JOIN latest_txn lt ON a.plan_id = lt.plan_id
WHERE (lt.last_transaction_date IS NULL 
   OR lt.last_transaction_date < CURDATE() - INTERVAL 365 DAY) AND created_on < CURDATE() - INTERVAL 365 DAY
ORDER BY inactivity_days DESC;