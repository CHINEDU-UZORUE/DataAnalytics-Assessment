-- Task: Calculate the average number of transactions per customer per month and categorize them:

USE adashi_staging;

-- Step 1: CTE to Compute number of transactions per user per month
WITH monthly_stats AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS month,
        COUNT(transaction_reference) AS monthly_txns
    FROM savings_savingsaccount
    WHERE transaction_status = 'success' -- To ensure only count successful transactions are counted
    GROUP BY owner_id, month
),

-- Step 2: CTE to Compute average transactions per user across months
avg_txn_per_user AS (
    SELECT 
        owner_id,
        AVG(monthly_txns) AS avg_transactions_per_month
    FROM monthly_stats
    GROUP BY owner_id
)

-- Step 3: Final Query to Segment users based on their average transactions per month
SELECT 
    CASE 
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_txn_in_segment
FROM avg_txn_per_user
GROUP BY frequency_category

