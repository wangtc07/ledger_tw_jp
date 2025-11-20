-- 當月收入, 當月支出, 帳戶餘額
-- SQL_in_out_bal_list
SELECT
    strftime ('%Y-%m', e.pay_day) as month, -- 月份
    (
        SELECT
            SUM(i.amount)
        FROM
            income i
        WHERE
            i.in_day >= date (all_months.cur_month || '-01')
            AND i.in_day <= date (
                all_months.cur_month || '-01', '+1 month', '-1 day'
            )
    ) as in_amount, -- 當月收入
    (
        SELECT
            SUM(e2.amount)
        FROM
            expense e2
        WHERE
            e2.pay_day >= date (all_months.cur_month || '-01')
            AND e2.pay_day <= date (
                all_months.cur_month || '-01', '+1 month', '-1 day'
            )
    ) as out_amount, -- 當月支出
    (
        SELECT
            bal_amount
        FROM
            account_balance_view abv
        WHERE abv.cur_month = all_months.cur_month
        
    ) as bal_amount
FROM
    (
        -- 產生「所有出現過收入或支出的年月」當駕駛表
        -- 這樣即使某個月只有收入、沒有支出，也會出現
        SELECT
            strftime ('%Y-%m', in_day) AS cur_month
        FROM
            income
        UNION
        SELECT
            strftime ('%Y-%m', pay_day) AS cur_month
        FROM
            expense
    ) all_months
ORDER BY all_months.cur_month;

-- 預算明細
-- SQL_budget_list
SELECT
    b.budget_name, -- 預算名稱
    b.budget_month as month, -- 月份
    b.budget_amount AS cur_budget, -- 當月預算
    COALESCE(bbv.bal_amount, 0) + b.budget_amount AS cumulative_budget, -- 上個月結餘 + 當月預算 = 累積預算
    COALESCE(
        (
            SELECT SUM(e.amount)
            FROM expense e
                JOIN plan p ON p.rowid = e.target_plan
                JOIN plan_det pd ON pd.plan = p.rowid
            WHERE
                p.target_budget = b.rowid
                AND pd.plan_month = b.budget_month
        ),
        0
    ) AS cur_mon_spent -- 當月支出金額 （有綁此預算下的 plan）
FROM budget b
    LEFT JOIN (
        -- 上個月的累積結餘（用上面的預算結餘查詢結果）
        SELECT
            budget_name, cur_month, bal_amount
        FROM budget_balance_view -- 預算累積結餘VIEW
    ) bbv ON bbv.budget_name = b.budget_name
    AND date(bbv.cur_month, '+1 month') = date(
        b.budget_month, 'start of month'
    )
ORDER BY b.budget_month;

-- 預算明細>月別支出計畫
-- SQL_budget_plan_list
SELECT
    p.plan_name, -- 支出計畫
    pd.plan_month as month, -- 月份
    pd.plan_amount AS plan_amount, -- 計畫金額
    COALESCE(SUM(e.amount), 0) AS actual_amount, -- 支出金額
    pd.plan_amount - COALESCE(SUM(e.amount), 0) AS balance -- 剩餘金額
FROM
    plan p
    JOIN plan_det pd ON pd.plan = p.rowid
    LEFT JOIN expense e ON e.target_plan = p.rowid
    AND strftime('%Y-%m', e.pay_day) = strftime('%Y-%m', pd.plan_month)
GROUP BY
    p.rowid,
    pd.plan_month
ORDER BY pd.plan_month, p.plan_name;
