import GRDB
import Foundation

/// 應用程式的主要資料庫控制器
/// 負責管理資料庫連線與遷移
public struct AppDatabase {
    /// 資料庫寫入器，可以是 DatabaseQueue (一般使用) 或 DatabasePool (進階並發)
    public let dbWriter: any DatabaseWriter

    /// 初始化資料庫
    /// - Parameter dbWriter: 傳入一個資料庫寫入器
    public init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        // 執行資料庫遷移，確保資料表結構是最新的
        try migrator.migrate(dbWriter)
    }

    /// 定義資料庫遷移邏輯
    public var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // 註冊 v1 版本的遷移
        // 如果未來有 schema 變更，可以註冊 v2, v3...
        migrator.registerMigration("v1") { db in
            // 帳戶表
            try db.create(table: "account") { t in
                t.autoIncrementedPrimaryKey("rowid")
                t.column("account_name", .text).notNull()
                t.column("init_amount", .integer).notNull()
                t.column("invest", .boolean).defaults(to: false)
            }

            // 預算表
            try db.create(table: "budget") { t in
                t.autoIncrementedPrimaryKey("rowid")
                t.column("budget_name", .text)
            }

            // 預算細項表
            try db.create(table: "budget_det") { t in
                t.column("budget", .integer).references("budget", onDelete: .cascade)
                t.column("budget_month", .date)
                t.column("budget_amount", .integer)
            }

            // 計畫表
            try db.create(table: "plan") { t in
                t.autoIncrementedPrimaryKey("rowid")
                t.column("plan_name", .text)
                t.column("target_budget", .integer).references("budget", onDelete: .cascade)
            }

            // 計畫細項表
            try db.create(table: "plan_det") { t in
                t.column("plan", .integer).references("plan", onDelete: .cascade)
                t.column("plan_month", .date)
                t.column("plan_amount", .integer)
            }

            // 類別表
            try db.create(table: "category") { t in
                t.autoIncrementedPrimaryKey("rowid")
                t.column("category_name", .text)
                t.column("in_out", .text).check { $0 == "in" || $0 == "out" }
                t.column("parent_category", .integer).references("category")
            }

            // 支出表
            try db.create(table: "expense") { t in
                t.column("pay_day", .date)
                t.column("amount", .integer)
                t.column("target_category", .integer).references("category")
                t.column("target_plan", .integer).references("plan")
                t.column("target_account", .integer).references("account")
                t.column("memo", .text)
            }

            // 收入表
            try db.create(table: "income") { t in
                t.column("in_day", .date)
                t.column("amount", .integer)
                t.column("target_category", .integer).defaults(to: 1).references("category")
                t.column("target_account", .integer).references("account")
                t.column("memo", .text)
            }

            // 轉帳表
            try db.create(table: "trans") { t in
                t.column("transfer_day", .date)
                t.column("amount", .integer)
                t.column("in_account", .integer).references("account")
                t.column("out_account", .integer).references("account")
                t.column("memo", .text)
            }
            
            // Views
            try db.execute(sql: """
            CREATE VIEW daily_trans_view AS
            SELECT
                e.pay_day AS note_date,
                NULL AS in_amount,
                e.amount AS out_amount,
                NULL AS in_account_name,
                a_out.account_name AS out_account_name,
                c_out.category_name AS category_name,
                e.memo AS memo
            FROM
                expense e
                LEFT JOIN account a_out ON a_out.rowid = e.target_account
                LEFT JOIN category c_out ON c_out.rowid = e.target_category
            UNION ALL
            SELECT
                i.in_day AS note_date,
                i.amount AS in_amount,
                NULL AS out_amount,
                a_in.account_name AS in_account_name,
                NULL AS out_account_name,
                c_in.category_name AS category_name,
                i.memo AS memo
            FROM
                income i
                LEFT JOIN account a_in ON a_in.rowid = i.target_account
                LEFT JOIN category c_in ON c_in.rowid = i.target_category
            UNION ALL
            SELECT
                t.transfer_day AS note_date,
                NULL AS in_amount,
                t.amount AS out_amount,
                a_in.account_name AS in_account_name,
                a_out.account_name AS out_account_name,
                NULL AS category_name,
                t.memo AS memo
            FROM
                trans t
                LEFT JOIN account a_in ON a_in.rowid = t.in_account
                LEFT JOIN account a_out ON a_out.rowid = t.out_account
            WHERE
                a_in.invest = TRUE
            UNION ALL
            SELECT
                t.transfer_day AS note_date,
                t.amount AS in_amount,
                NULL AS out_amount,
                a_in.account_name AS in_account_name,
                a_out.account_name AS out_account_name,
                NULL AS category_name,
                t.memo AS memo
            FROM
                trans t
                LEFT JOIN account a_in ON a_in.rowid = t.in_account
                LEFT JOIN account a_out ON a_out.rowid = t.out_account
            WHERE
                a_out.invest = TRUE
            UNION ALL
            SELECT
                t.transfer_day AS note_date,
                t.amount AS in_amount,
                t.amount AS out_amount,
                a_in.account_name AS in_account_name,
                a_out.account_name AS out_account_name,
                NULL AS category_name,
                t.memo AS memo
            FROM
                trans t
                LEFT JOIN account a_in ON a_in.rowid = t.in_account
                LEFT JOIN account a_out ON a_out.rowid = t.out_account
            WHERE
                a_in.invest = FALSE
                AND a_out.invest = FALSE;
            """)
            
            try db.execute(sql: """
            CREATE VIEW budget_balance_view AS
            SELECT
                budget_name,
                cur_month,
                total_budget,
                total_amount,
                total_budget - total_amount AS bal_amount
            FROM (
                    SELECT
                        b.budget_name,
                        strftime('%Y-%m', bd.budget_month) AS cur_month,
                        (
                            SELECT SUM(bd2.budget_amount)
                            FROM budget_det bd2
                                JOIN budget b2 ON b2.rowid = bd2.budget
                            WHERE
                                b2.budget_name = b.budget_name
                                AND bd2.budget_month <= bd.budget_month
                        ) AS total_budget,
                        IFNULL(
                            (
                                SELECT SUM(e2.amount)
                                FROM
                                    expense e2
                                    JOIN plan p2 ON p2.rowid = e2.target_plan
                                    JOIN plan_det pd2 ON pd2.plan = p2.rowid
                                    AND pd2.plan_month = date(e2.pay_day, 'start of month')
                                WHERE
                                    p2.target_budget = b.rowid
                                    AND pd2.plan_month <= bd.budget_month
                                    AND e2.pay_day <= date(
                                        bd.budget_month, 'start of month', '+1 month', '-1 day'
                                    )
                            ), 0
                        ) AS total_amount
                    FROM budget b
                        JOIN budget_det bd ON bd.budget = b.rowid
                    GROUP BY
                        b.rowid, bd.budget_month
                ) bal
            ORDER BY cur_month;
            """)
            
            try db.execute(sql: """
            CREATE VIEW IF NOT EXISTS account_balance_view AS
            SELECT
                cur_month,
                total_in,
                total_out,
                total_in - total_out AS bal_amount
            FROM (
                    SELECT all_months.cur_month,
                        (
                            SELECT SUM(i.amount)
                            FROM income i
                            WHERE
                                i.in_day <= date(
                                    all_months.cur_month || '-01', '+1 month', '-1 day'
                                )
                        ) AS total_in,
                        (
                            SELECT SUM(e2.amount)
                            FROM expense e2
                            WHERE
                                e2.pay_day <= date(
                                    all_months.cur_month || '-01', '+1 month', '-1 day'
                                )
                        ) AS total_out
                    FROM (
                            SELECT strftime('%Y-%m', in_day) AS cur_month
                            FROM income
                            UNION
                            SELECT strftime('%Y-%m', pay_day) AS cur_month
                            FROM expense
                        ) all_months
                    GROUP BY
                        all_months.cur_month
                    ORDER BY all_months.cur_month
                ) bal;
            """)
        }

        return migrator
    }
}
