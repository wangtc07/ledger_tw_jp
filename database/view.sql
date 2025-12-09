-- 月明細：日單位的列表
CREATE VIEW daily_trans_view AS
-- 支出
SELECT
    e.pay_day AS note_date, -- 日期
    NULL AS in_amount, -- 收入金額 (支出為 NULL)
    e.amount AS out_amount, -- 支出金額
    NULL AS in_account_name, -- 轉入帳戶 (支出為 NULL)
    a_out.account_name AS out_account_name, -- 轉出帳戶 (支出帳戶)
    c_out.category_name AS category_name, -- 類別名稱
    e.memo AS memo -- 備註
FROM
    expense e
    LEFT JOIN account a_out ON a_out.rowid = e.target_account
    LEFT JOIN category c_out ON c_out.rowid = e.target_category
UNION ALL
-- 收入
SELECT
    i.in_day AS note_date, -- 日期
    i.amount AS in_amount, -- 收入金額
    NULL AS out_amount, -- 支出金額 (收入為 NULL)
    a_in.account_name AS in_account_name, -- 轉入帳戶 (收入帳戶)
    NULL AS out_account_name, -- 轉出帳戶 (收入為 NULL)
    c_in.category_name AS category_name, -- 類別名稱
    i.memo AS memo -- 備註
FROM
    income i
    LEFT JOIN account a_in ON a_in.rowid = i.target_account
    LEFT JOIN category c_in ON c_in.rowid = i.target_category
UNION ALL
-- 轉帳支出 （投資帳戶轉入）
SELECT
    t.transfer_day AS note_date, -- 日期
    NULL AS in_amount, -- 轉入金額 (視為收入)
    t.amount AS out_amount, -- 轉出金額 (視為支出)
    a_in.account_name AS in_account_name, -- 轉入帳戶
    a_out.account_name AS out_account_name, -- 轉出帳戶
    NULL AS category_name, -- 類別名稱 (轉帳無類別)
    t.memo AS memo -- 備註
FROM
    trans t
    LEFT JOIN account a_in ON a_in.rowid = t.in_account
    LEFT JOIN account a_out ON a_out.rowid = t.out_account
WHERE
    a_in.invest = TRUE
UNION ALL
-- 轉帳收入 （投資帳戶轉出, 盈利）
SELECT
    t.transfer_day AS note_date, -- 日期
    t.amount AS in_amount, -- 轉入金額 (視為收入)
    NULL AS out_amount, -- 轉出金額 (視為支出)
    a_in.account_name AS in_account_name, -- 轉入帳戶
    a_out.account_name AS out_account_name, -- 轉出帳戶
    NULL AS category_name, -- 類別名稱 (轉帳無類別)
    t.memo AS memo -- 備註
FROM
    trans t
    LEFT JOIN account a_in ON a_in.rowid = t.in_account
    LEFT JOIN account a_out ON a_out.rowid = t.out_account
WHERE
    a_out.invest = TRUE
UNION ALL
-- 轉帳單純 （一般帳戶間轉帳）
SELECT
    t.transfer_day AS note_date, -- 日期
    t.amount AS in_amount, -- 轉入金額
    t.amount AS out_amount, -- 轉出金額
    a_in.account_name AS in_account_name, -- 轉入帳戶
    a_out.account_name AS out_account_name, -- 轉出帳戶
    NULL AS category_name, -- 類別名稱 (轉帳無類別)
    t.memo AS memo -- 備註
FROM
    trans t
    LEFT JOIN account a_in ON a_in.rowid = t.in_account
    LEFT JOIN account a_out ON a_out.rowid = t.out_account
WHERE
    a_in.invest = FALSE
    AND a_out.invest = FALSE;

-- 預算累積結餘VIEW(with credit)
CREATE VIEW budget_balance_view AS
SELECT
    budget_name, -- 預算名稱
    cur_month, -- 月份
    total_budget, -- 累積預算
    total_amount, -- 累積支出
    total_budget - total_amount AS bal_amount -- 預算累積結餘
FROM
    (
        SELECT
            b.budget_name, -- 預算名稱
            bd.budget_month AS cur_month, -- 月份
            (
                SELECT
                    SUM(bd2.budget_amount)
                FROM
                    budget_det bd2
                    JOIN budget b2 ON b2.rowid = bd2.budget
                WHERE
                    b2.budget_name = b.budget_name
                    AND bd2.budget_month <= bd.budget_month -- 某月以前的總預算
            ) AS total_budget, -- 累積預算
            IFNULL (
                (
                    SELECT
                        SUM(ed.amount)
                    FROM
                        (
                            SELECT
                                credit_e.rowid as rowid,
                                credit_e.amount,
                                CASE
                                -- 如果是信用卡支出 and debit_day is not null ->> debit_day 當作支出日
                                    WHEN a.credit
                                    AND credit_e.debit_day IS NOT NULL THEN credit_e.debit_day
                                    -- 如果是信用卡支出 and debit_day is null and pay_day <= plan_month + 精算日 ->> plan_month +1 month + 結款日
                                    WHEN a.credit
                                    AND credit_e.debit_day IS NULL
                                    AND credit_e.pay_day <= strftime ('%Y-%m', pd2.plan_month) || ca.count_day THEN DATE(strftime ('%Y-%m', pd2.plan_month) || ca.debit_day, '+1 month')
                                    -- 如果是信用卡支出 and debit_day is null and pay_day > plan_month + 精算日 ->> plan_month +2 month + 結款日
                                    WHEN a.credit
                                    AND credit_e.debit_day IS NULL
                                    AND credit_e.pay_day <= strftime ('%Y-%m', pd2.plan_month) || ca.count_day THEN DATE(strftime ('%Y-%m', pd2.plan_month) || ca.debit_day, '+2 month')
                                    -- 除此之外(一般支出)
                                    ELSE credit_e.pay_day
                                END as pay_day,
                                p2.target_budget,
                                pd2.plan_month
                            FROM
                                expense credit_e
                                JOIN plan p2 ON p2.rowid = credit_e.target_plan -- 計畫
                                JOIN plan_det pd2 ON pd2.plan = p2.rowid -- 計畫細項
                                AND pd2.plan_month = date(credit_e.pay_day, 'start of month') -- 支出月份的計畫
                                JOIN account a ON a.rowid = credit_e.target_account -- 支出帳戶
                                LEFT JOIN credit_account ca ON ca.account = a.rowid -- 信用卡表
                        ) ed
                    WHERE
                        ed.target_budget = b.rowid -- 此預算的計劃
                        AND ed.plan_month <= bd.budget_month -- 此預算,某月以前的計畫
                        AND ed.pay_day <= date(bd.budget_month, 'start of month', '+1 month', '-1 day') -- 此預算,某月以前的總花費
                ),
                0
            ) AS total_amount -- 累積實際支出（只算有綁這個 budget 底下 plan 的支出）
        FROM
            budget b
            JOIN budget_det bd ON bd.budget = b.rowid
        GROUP BY
            b.rowid,
            bd.budget_month -- 按年月分組
    ) bal
ORDER BY
    cur_month;

-- 查看「帳戶餘額」：每月累積結餘（收入 - 支出）
-- 改良版：同時考慮 income 與 expense, 避免只有支出時漏掉月份
CREATE VIEW IF NOT EXISTS account_balance_view AS
SELECT
    cur_month,
    total_in, -- 當月收入
    total_out, -- 當月支出
    total_in - total_out AS bal_amount -- 當月結餘
FROM
    (
        SELECT
            all_months.cur_month, -- 月份
            (
                SELECT
                    SUM(i.amount)
                FROM
                    income i
                WHERE
                    i.in_day <= date(all_months.cur_month || '-01', '+1 month', '-1 day')
            ) AS total_in, -- 累積收入：到當月底為止的所有收入
            (
                SELECT
                    SUM(e2.amount)
                FROM
                    expense e2
                WHERE
                    e2.pay_day <= date(all_months.cur_month || '-01', '+1 month', '-1 day')
            ) AS total_out -- 累積支出：到當月底為止的所有支出
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
        GROUP BY
            all_months.cur_month
        ORDER BY
            all_months.cur_month
    ) bal;