-- 當月收入, 當月支出, 當月結餘
-- SQL_in_out_bal_list
SELECT * FROM account_balance_view;

-- 預算明細
-- SQL_budget_list
SELECT
    b.budget_name, -- 預算名稱
    bd.budget_month as month, -- 月份
    bd.budget_amount AS cur_budget, -- 當月預算
    COALESCE(bbv.bal_amount, 0) + bd.budget_amount AS cumulative_budget, -- 上個月結餘 + 當月預算 = 累積預算
    COALESCE(
        (
            SELECT SUM(e.amount)
            FROM
                expense e
                JOIN plan p ON p.rowid = e.target_plan
                JOIN plan_det pd ON pd.plan = p.rowid
                AND pd.plan_month = date(e.pay_day, 'start of month') -- 支出月份的計畫
            WHERE
                p.target_budget = b.rowid
                AND pd.plan_month = bd.budget_month
        ),
        0
    ) AS cur_mon_spent -- 當月支出金額 （有綁此預算下的 plan）
FROM
    budget b
    JOIN budget_det bd ON bd.budget = b.rowid
    LEFT JOIN (
        -- 上個月的累積結餘（用上面的預算結餘查詢結果）
        SELECT
            budget_name,
            cur_month,
            bal_amount
        FROM budget_balance_view -- 預算累積結餘VIEW
    ) bbv ON bbv.budget_name = b.budget_name
    AND date(
        bbv.cur_month || '-01',
        '+1 month'
    ) = date(
        bd.budget_month,
        'start of month'
    )
ORDER BY bd.budget_month;

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
    AND pd.plan_month = date(e.pay_day, 'start of month') -- 支出月份的計畫
GROUP BY
    p.rowid,
    pd.plan_month
ORDER BY pd.plan_month, p.plan_name;