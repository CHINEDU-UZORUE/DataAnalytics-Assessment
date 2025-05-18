# DataAnalytics-Assessment


This project contains SQL queries designed to tackle four specific business scenarios for analyzing Cowrywise customer and transaction data. Below, I go through each task, explaining how I approached the problem and the challenges I faced while writing the queries.

---

## Question 1.  High-Value Customers with Multiple Products

- **Scenario**: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
- **Task**: Write a query to find customers with at least one funded savings plan AND one
funded investment plan, sorted by total deposits.


### My Approach

I started by thinking about how to identify customers with at least one savings plan and one investment plan. The `plans_plan` table had fields (`is_regular_savings` and `is_a_fund`) to distinguish between savings and investment plans, so I decided to use Common Table Expressions (CTEs) to break the problem into manageable steps. First, I created a CTE to count savings plans per customer, then another for investment plans. 
Next, I joined these to find customers who appeared in both, meaning they had at least one of each. Finally, I pulled in the user details and summed up the `confirmed_amount` from the `savings_savingsaccount` table to get total deposits. I also had to make sure the sorting by total deposits was accurate, so grouping by `owner_id` and using `SUM` was critical.

### Challenges Faced
- **Understanding Plan Types**: Initially, I wasn’t sure if `is_regular_savings = 1` and `is_a_fund = 1` were mutually exclusive or if a plan could have both flags set. I assumed they were distinct based on the context, but this required careful validation.
- **Joining Data**: Joining the `qualified_customers` CTE with the `savings_savingsaccount` table was somehow because I needed to ensure all relevant deposits were included without duplicating rows. The `GROUP BY u.id` helped avoid this.
- **Performance Concerns**: With the large size of the datasets, I worried about the performance of multiple CTEs and joins. This way, I kept the query modular to make it easier to optimize later if needed.

---

## Question 2. Transaction Frequency Analysis
- **Scenario**: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
- **Task**: Calculate the average number of transactions per customer per month and categorize them:
● "High Frequency" (≥10 transactions/month)
● "Medium Frequency" (3-9 transactions/month)
● "Low Frequency" (≤2 transactions/month)


### My Approach

I approached this question in three steps. First, I used a CTE to count transactions per customer per month, making sure to only include successful transactions (`transaction_status = 'success'`). Then, I calculated the average transactions per customer across all their active months. Finally, I used a `CASE` statement to categorize customers into frequency groups and aggregated the results to show how many customers fell into each category, along with the average transactions in each segment.

I used the `DATE_FORMAT` function for grouping by month, and I made sure to round the averages to two decimal places for readability. 

### My Approach
- **Defining a Month**: Deciding how to group transactions by month was initially an issue. I had to use `DATE_FORMAT(transaction_date, '%Y-%m-01')` to standardize the month.
- **Successful Transactions**: The requirement didn’t explicitly mention filtering for successful transactions, but I assumed it was implied since failed transactions wouldn’t reflect user activity. This was a judgment call on my part.

---

## 3. Account Inactivity Alert
- **Scenario**: The ops team wants to flag accounts with no inflow transactions for over one year.
- **Task**: Find all active accounts (savings or investments) with no transactions in the last 1
year (365 days) .

### My Approach
I used a CTE to find the latest transaction date per plan (`plan_id`) from the `savings_savingsaccount` table. Then, I created another CTE to identify all active plans (those with `is_regular_savings = 1` or `is_a_fund = 1`). I joined these with a `LEFT JOIN` to include plans that might have no transactions at all, then filtered for those where the last transaction was older than 365 days. The `DATEDIFF` function helped calculate inactivity days, and I included the account type (Savings or Investment) for clarity.

I didn't understand whether “inflow transactions” meant only positive `confirmed_amount` values. 

### Challenges Faced
- **Inflow Definition**: The requirement mentioned “no inflow transactions,” but I wasn’t sure if this meant only deposits (`confirmed_amount > 0`) or any transaction. I leaned toward any transaction to avoid missing active accounts.
- **Null Transactions**: Some plans might have no transactions, resulting in a `NULL` `last_transaction_date`. The `LEFT JOIN` handled this, but I had to ensure the `WHERE` clause correctly filtered for old or missing transactions.
- **Active Accounts**: Defining “active” accounts was ambiguous. I assumed it meant plans with `is_regular_savings = 1` or `is_a_fund = 1`, but there could be other status flags like `is_active` in user_customuser table.

---

## 4. Customer Lifetime Value (CLV) Estimation

### My Approach
I started with a CTE to calculate the total transactions and average profit per transaction (0.1% of the transaction amount) per customer. Then, in the main query, I calculated tenure using `DATEDIFF` to find months since `date_joined`, applied the CLV formula, and joined with the `users_customuser` table for customer details. I rounded the tenure and CLV values to make the output clean and readable.
To Sort by CLV, I used `ORDER BY estimated_clv DESC`.

### Challenges Faced
- **Tenure Edge Cases**: Customers who signed up very recently might have a tenure of zero months, which could cause division errors in the CLV formula. I relied on `DATEDIFF` returning at least 1 day.
- **Profit Calculation**: Calculating 0.1% of the transaction amount (`0.001 * SUM(confirmed_amount)`) was simple, but I had to ensure it was divided by the transaction count correctly to get the average profit per transaction.

---
