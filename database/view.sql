-- 查看某月(當月)「支出予算」的累積結餘
SELECT
    budget_name, -- 預算名稱
    cur_month, -- 月份
    total_budget - total_amount as bal_amount -- 預算累積結餘
FROM (
        SELECT (
                SELECT b3.budget_name
                FROM budget b3
                WHERE
                    b3.rowid = b.rowid
            ) as budget_name, strftime('%Y-%m', b.budget_month) as cur_month, SUM(e.amount) AS cur_mon_amount, (
                SELECT SUM(budget_amount)
                FROM budget b2
                WHERE
                    b2.budget_month <= b.budget_month -- 某月以前的總預算
                    AND b2.rowid = b.rowid
            ) as total_budget, (
                SELECT IFNULL(SUM(e2.amount), 0) -- 沒支出計劃 或 沒有實際支出 都視為0
                FROM expense e2
                WHERE
                    strftime('%Y-%m', e2.pay_day) <= strftime('%Y-%m', b.budget_month) -- 某月以前的總花費
                    AND e2.target_plan = p.rowid -- 有設定支出計劃
            ) as total_amount
        FROM budget b
            LEFT JOIN plan p ON p.target_budget = b.rowid
            LEFT JOIN expense e ON e.target_plan = p.rowid
        GROUP BY
            b.rowid, strftime('%Y-%m', b.budget_month) -- 按年月分組
    ) bal;

-- 查看「帳戶餘額」
SELECT
    cur_month, -- 月份
    total_in - total_out as bal_amount -- 帳戶累積結餘
FROM (
        SELECT
            ()
            strftime('%Y-%m', e.pay_day) as cur_month, (
                SELECT SUM(i.amount)
                FROM income i
                WHERE
                    i.in_day <= e.pay_day -- 某月以前的總收入
            ) as total_in, (
                SELECT SUM(e2.amount)
                FROM expense e2
                WHERE
                    strftime('%Y-%m', e2.pay_day) <= strftime('%Y-%m', e.pay_day) -- 某月以前的總花費
            ) as total_out
        FROM expense e
        GROUP BY
            strftime('%Y-%m', e.pay_day) -- 按年月分組
    ) bal;