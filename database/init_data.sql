INSERT INTO
    account (rowid, account_name, init_amount, invest)
VALUES
    (1, '給料', 20000, FALSE);

INSERT INTO
    category (rowid, category_name, in_out, parent_category)
VALUES
    (1, '給料', 'in', null),
    (2, '食', 'out', null),
    (3, '日用', 'out', null),
    (4, '房租', 'out', null),
    (5, '外食', 'out', 2);

INSERT INTO
    budget (rowid, budget_name)
VALUES
    (1, '變動支出'),
    (2, '固定支出');

INSERT INTO
    budget_det (rowid, budget, budget_month, budget_amount)
VALUES
    (1, 1, '2026-01-01', 10000),
    (2, 2, '2026-01-01', 10000),
    (3, 1, '2026-02-01', 10000),
    (4, 2, '2026-02-01', 10000);

INSERT INTO
    plan (rowid, plan_name, target_budget)
VALUES
    (1, '食', 1),
    (2, '房租', 2);

INSERT INTO
    category_plan (category, plan)
VALUES
    (2, 1),
    (4, 2),
    (5, 1);

INSERT INTO
    plan_det (rowid, plan, plan_month, plan_amount)
VALUES
    (1, 1, '2026-01-01', 5000),
    (2, 2, '2026-01-01', 9000);

INSERT INTO
    expense (rowid, pay_day, amount, target_category, target_plan, target_account, memo)
VALUES
    (1, '2026-01-01', 100, 1, 1, 1, 'eat'),
    (2, '2026-01-02', 9000, 4, 2, 1, 'rent');

INSERT INTO
    income (rowid, in_day, amount, target_category, target_account, memo)
VALUES
    (1, '2026-01-30', 20000, 2, 1, '給料');