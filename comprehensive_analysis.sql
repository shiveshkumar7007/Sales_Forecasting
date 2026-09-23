CREATE DATABASE IF NOT EXISTS Sales_Forecast_Project;
USE Sales_Forecast_Project;

-- Q1: Loyal vs Discount-Only Customers
SELECT
    customer_segment,
    promo_dependency_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(final_loyalty_score), 3) AS avg_loyalty_score,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(avg_annual_frequency), 1) AS avg_frequency
FROM customer_features
GROUP BY customer_segment, promo_dependency_segment
ORDER BY avg_loyalty_score DESC;

-- Q2: Behavioral Patterns Predicting High Value
SELECT
    value_tier,
    ROUND(AVG(avg_previous_purchases), 1) AS avg_past_purchases,
    ROUND(AVG(avg_annual_frequency), 1) AS avg_frequency,
    ROUND(AVG(subscription_score), 3) AS avg_subscription,
    ROUND(AVG(avg_review_rating), 2) AS avg_rating,
    ROUND(AVG(final_loyalty_score), 3) AS avg_loyalty,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    COUNT(*) AS total_customers
FROM customer_features
GROUP BY value_tier
ORDER BY avg_spend DESC;

-- Q3: Geographically Underlevered Markets
SELECT
    location,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(final_loyalty_score), 3) AS avg_loyalty,
    ROUND(AVG(discount_dependency_score), 3) AS avg_discount_dependency,
    SUM(CASE WHEN value_tier = 'Premium Value' THEN 1 ELSE 0 END) AS premium_customers,
    ROUND(100.0 * SUM(CASE WHEN value_tier = 'Premium Value' THEN 1 ELSE 0 END) / COUNT(*), 1) AS premium_pct,
    (SELECT cf2.favorite_category
     FROM customer_features cf2
     WHERE cf2.location = cf.location
     GROUP BY cf2.favorite_category
     ORDER BY COUNT(*) DESC
     LIMIT 1) AS top_category
FROM customer_features cf
GROUP BY location
HAVING COUNT(*) >= 5
ORDER BY avg_spend DESC
LIMIT 20;

-- Q4: Restructuring the Promotional Strategy
SELECT
    promo_dependency_segment,
    value_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(avg_annual_frequency), 1) AS avg_frequency,
    ROUND(AVG(final_loyalty_score), 3) AS avg_loyalty,
    ROUND(AVG(avg_review_rating), 2) AS avg_satisfaction
FROM customer_features
GROUP BY promo_dependency_segment, value_tier
ORDER BY promo_dependency_segment, avg_spend DESC;

-- Q5: Ideal Customer Profile
SELECT
    CASE
        WHEN age < 25 THEN '18-24'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    favorite_category,
    preferred_payment_method,
    preferred_shipping_type,
    satisfaction_flag,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(final_loyalty_score), 3) AS avg_loyalty
FROM customer_features
WHERE value_tier = 'Premium Value'
  AND promo_dependency_segment != 'Highly Promo Dependent'
GROUP BY age_group, favorite_category, preferred_payment_method, preferred_shipping_type, satisfaction_flag
ORDER BY avg_spend DESC
LIMIT 20;

-- Q6: Promo Margin Leakage & Profit-at-Risk Analysis
SELECT 
    location,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN discount_dependency_score >= 0.75 THEN total_spend ELSE 0 END) AS high_promo_spend,
    SUM(total_spend) AS total_revenue,
    ROUND(100.0 * SUM(CASE WHEN discount_dependency_score >= 0.75 THEN total_spend ELSE 0 END) / SUM(total_spend), 2) AS promo_revenue_share_pct,
    ROUND(AVG(CASE WHEN discount_dependency_score >= 0.75 THEN final_loyalty_score END), 3) AS promo_group_avg_loyalty
FROM customer_features
GROUP BY location
HAVING COUNT(*) >= 10
ORDER BY promo_revenue_share_pct DESC
LIMIT 10;

-- Q7: Cross-Sell & Category Expansion Matrix
SELECT 
    favorite_category,
    value_tier,
    COUNT(*) AS segment_customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(subscription_score), 3) AS avg_subscription_score,
    ROUND(AVG(avg_review_rating), 2) AS avg_rating,
    ROUND(100.0 * SUM(CASE WHEN subscription_score = 1.0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS subscribed_pct
FROM customer_features
GROUP BY favorite_category, value_tier
ORDER BY favorite_category, avg_spend DESC;

-- Q8: At-Risk High-Value Churn Prediction Profiler
SELECT 
    value_tier,
    satisfaction_flag,
    preferred_shipping_type,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(avg_annual_frequency), 1) AS avg_frequency,
    ROUND(AVG(avg_previous_purchases), 1) AS avg_past_purchases,
    ROUND(AVG(discount_dependency_score), 3) AS avg_discount_dependency
FROM customer_features
WHERE value_tier IN ('High Value', 'Premium Value')
  AND (satisfaction_flag = 'Low Satisfaction' OR avg_review_rating < 3.0)
GROUP BY value_tier, satisfaction_flag, preferred_shipping_type
ORDER BY customer_count DESC;

-- Q9: Cumulative Revenue Concentration via Decile Ranking
WITH RankedCustomers AS (
    SELECT 
        customer_id,
        total_spend,
        NTILE(10) OVER (ORDER BY total_spend DESC) AS spend_decile
    FROM customer_features
)
SELECT 
    spend_decile AS decile_group,
    COUNT(customer_id) AS customer_count,
    ROUND(SUM(total_spend), 2) AS decile_total_spend,
    ROUND(100.0 * SUM(total_spend) / (SELECT SUM(total_spend) FROM customer_features), 2) AS revenue_share_pct
FROM RankedCustomers
GROUP BY spend_decile
ORDER BY spend_decile;

-- Q10: Multi-Channel Preference Optimization
SELECT 
    preferred_payment_method,
    preferred_shipping_type,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(final_loyalty_score), 3) AS avg_loyalty_score,
    ROUND(AVG(discount_dependency_score), 3) AS avg_discount_dependency,
    ROUND(100.0 * SUM(CASE WHEN subscription_score = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS subscription_penetration_pct
FROM customer_features
GROUP BY preferred_payment_method, preferred_shipping_type
HAVING COUNT(*) >= 20
ORDER BY avg_loyalty_score DESC, avg_spend DESC;

-- Q11: Segment Benchmark Variance Analysis
SELECT 
    cf.customer_id,
    cf.customer_segment,
    cf.total_spend AS individual_spend,
    sa.avg_spend AS segment_avg_spend,
    ROUND(cf.total_spend - sa.avg_spend, 2) AS spend_variance_from_segment
FROM customer_features cf
JOIN segment_analysis sa 
  ON cf.customer_segment = sa.customer_segment
WHERE cf.total_spend > (sa.avg_spend * 1.5)
ORDER BY spend_variance_from_segment DESC
LIMIT 15;

-- Q12: Geographic Efficiency vs State Benchmark Comparison
SELECT 
    cf.customer_id,
    cf.location,
    cf.final_loyalty_score,
    ga.avg_loyalty AS state_avg_loyalty,
    ga.avg_discount_dependency AS state_avg_discount_dep
FROM customer_features cf
JOIN geography_analysis ga 
  ON cf.location = ga.location
WHERE cf.final_loyalty_score > ga.avg_loyalty
  AND ga.avg_discount_dependency > 0.40
ORDER BY cf.final_loyalty_score DESC
LIMIT 15;

-- Q13: Category Expectation vs Reality Check
SELECT 
    cf.customer_id,
    cf.favorite_category,
    cf.avg_review_rating AS customer_avg_rating,
    ca.avg_rating AS category_global_avg_rating,
    ROUND(ca.avg_rating - cf.avg_review_rating, 2) AS rating_deficit
FROM customer_features cf
JOIN category_analysis ca 
  ON cf.favorite_category = ca.category
WHERE cf.avg_review_rating < ca.avg_rating
  AND ca.avg_rating > 3.7
ORDER BY rating_deficit DESC
LIMIT 15;

-- Q14: The Subscription Revenue Premium Analysis
SELECT 
    favorite_category,
    CASE WHEN subscription_score = 1 THEN 'Subscribed' ELSE 'Not Subscribed' END AS subscription_status,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_revenue,
    ROUND(AVG(avg_annual_frequency), 1) AS avg_frequency
FROM customer_features
GROUP BY favorite_category, subscription_score
ORDER BY favorite_category, subscription_score DESC;

-- Q15: High-Frequency Shipping Drain Identification
SELECT 
    customer_id,
    customer_segment,
    preferred_shipping_type,
    avg_annual_frequency,
    discount_dependency_score,
    total_spend,
    1 AS query_trigger -- <--- Add this small line
FROM customer_features
WHERE avg_annual_frequency > 24 
  AND discount_dependency_score > 0.8
  AND preferred_shipping_type IN ('Express', 'Next Day')
ORDER BY avg_annual_frequency DESC, total_spend ASC
LIMIT 20;