-- 帳戶表：儲存資產帳戶資訊
CREATE TABLE IF NOT EXISTS account (
    account_name VARCHAR(32) NOT NULL, -- 帳戶名稱
    init_amount INT NOT NULL, -- 初始金額
    invest BOOLEAN DEFAULT FALSE -- 投資轉帳 （轉入轉出視為收入支出）
);

-- 預算表：設定每月的總預算
CREATE TABLE IF NOT EXISTS budget (
    budget_name VARCHAR(32) -- 預算名稱
);

-- 預算細項表：：設定每月的總預算
CREATE TABLE IF NOT EXISTS budget_det (
    budget INTEGER, -- 關聯的預算ID
    budget_month DATE, -- 預算月份
    budget_amount INT, -- 預算金額
    FOREIGN KEY (budget) REFERENCES budget (rowid)
);

-- 計畫表：預算底下的具體支出計畫
CREATE TABLE IF NOT EXISTS plan (
    plan_name VARCHAR(32), -- 計畫名稱
    target_budget INT, -- 關聯的預算ID
    FOREIGN KEY (target_budget) REFERENCES budget (rowid)
);

-- 計畫細項表：計畫在各月份的詳細分配
CREATE TABLE IF NOT EXISTS plan_det (
    plan INTEGER, -- 關聯的計畫ID
    plan_month DATE, -- 計畫月份
    plan_amount INT, -- 計畫金額
    FOREIGN KEY (plan) REFERENCES plan (rowid)
);

-- 類別表：收支類別
CREATE TABLE IF NOT EXISTS category (
    category_name VARCHAR(32), -- 類別名稱
    in_out CHAR(3), -- 收支類型 (IN/OUT)
    parent_category INT, -- 父類別ID
    FOREIGN KEY (parent_category) REFERENCES category (rowid)
);

-- 支出表：記錄每一筆支出
CREATE TABLE IF NOT EXISTS expense (
    pay_day DATE, -- 支出日期
    amount INT, -- 金額
    target_category INT, -- 關聯類別ID
    target_plan INT, -- 關聯計畫ID
    target_account INT, -- 關聯帳戶ID
    memo VARCHAR(256), -- 備註
    FOREIGN KEY (target_category) REFERENCES category (rowid),
    FOREIGN KEY (target_plan) REFERENCES plan (rowid),
    FOREIGN KEY (target_account) REFERENCES account (rowid)
);

-- 收入表：記錄每一筆收入
CREATE TABLE IF NOT EXISTS income (
    in_day DATE, -- 收入日期
    amount INT, -- 金額
    target_category INT DEFAULT 1, -- 關聯類別ID (預設為1)
    target_account INT, -- 關聯帳戶ID
    memo VARCHAR(256), -- 備註
    FOREIGN KEY (target_category) REFERENCES category (rowid),
    FOREIGN KEY (target_account) REFERENCES account (rowid)
);

-- 轉帳表：記錄帳戶間的轉帳
CREATE TABLE IF NOT EXISTS trans (
    transfer_day DATE, -- 轉帳日期
    amount INT, -- 金額
    in_account INT, -- 轉入帳戶ID
    out_account INT, -- 轉出帳戶ID
    memo VARCHAR(256), -- 備註
    FOREIGN KEY (in_account) REFERENCES account (rowid),
    FOREIGN KEY (out_account) REFERENCES account (rowid)
);