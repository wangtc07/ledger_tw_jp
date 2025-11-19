CREATE TABLE IF NOT EXISTS account (
    account_name VARCHAR(32) NOT NULL,
    init_amount INT NOT NULL
);

CREATE TABLE IF NOT EXISTS budget (
    budget_name VARCHAR(32),
    budget_month DATE,
    budget_amount INT
);

CREATE TABLE IF NOT EXISTS plan (
    plan_name VARCHAR(32),
    plan_month DATE,
    plan_amount INT,
    target_budget INT,
    FOREIGN KEY (target_budget) REFERENCES budget (rowid)
);

CREATE TABLE IF NOT EXISTS category (
    category_name VARCHAR(32),
    in_out CHAR(3),
    parent_category INT,
    FOREIGN KEY (parent_category) REFERENCES category (rowid)
);

CREATE TABLE IF NOT EXISTS expense (
    pay_day DATE,
    amount INT,
    target_category INT,
    target_plan INT,
    target_account INT,
    FOREIGN KEY (target_category) REFERENCES category (rowid),
    FOREIGN KEY (target_plan) REFERENCES plan (rowid),
    FOREIGN KEY (target_account) REFERENCES account (rowid)
);

CREATE TABLE IF NOT EXISTS income (
    in_day DATE,
    amount INT,
    target_category INT DEFAULT 1,
    target_account INT,
    FOREIGN KEY (target_category) REFERENCES category (rowid),
    FOREIGN KEY (target_account) REFERENCES account (rowid)
);