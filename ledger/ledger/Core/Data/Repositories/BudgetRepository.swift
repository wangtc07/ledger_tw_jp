import GRDB
import Foundation

/// 預算相關的資料倉庫
/// 負責處理預算列表、支出計畫與帳戶餘額的查詢
public struct BudgetRepository {
    /// 資料庫寫入器，用於執行 SQL 查詢
    private let dbWriter: any DatabaseWriter
    
    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }
    
    /// 取得預算列表
    /// 包含當月預算、累積預算以及當月支出
    /// - Returns: 預算列表 DTO 陣列
    public func getBudgetList(month: Date) async throws -> [BudgetListDTO] {
        // 使用 dbWriter.read 進行唯讀查詢，不會阻塞寫入操作
        try await dbWriter.read { db in
            let sql = """
            SELECT
                b.budget_name,
                bd.budget_month as month,
                bd.budget_amount AS cur_budget,
                COALESCE(bbv.bal_amount, 0) + bd.budget_amount AS cumulative_budget,
                COALESCE(
                    (
                        SELECT SUM(e.amount)
                        FROM
                            expense e
                            JOIN plan p ON p.rowid = e.target_plan
                            JOIN plan_det pd ON pd.plan = p.rowid
                            AND pd.plan_month = date(e.pay_day, 'start of month')
                        WHERE
                            p.target_budget = b.rowid
                            AND pd.plan_month = bd.budget_month
                    ),
                    0
                ) AS cur_mon_spent
            FROM
                budget b
                JOIN budget_det bd ON bd.budget = b.rowid
                LEFT JOIN (
                    SELECT
                        budget_name,
                        cur_month,
                        bal_amount
                    FROM budget_balance_view
                ) bbv ON bbv.budget_name = b.budget_name
                AND date(bbv.cur_month || '-01', '+1 month') = date(
                    bd.budget_month,
                    'start of month'
                )
            WHERE date(bd.budget_month, 'start of month') = date(?, 'start of month')
            ORDER BY bd.budget_month;
            """
            return try BudgetListDTO.fetchAll(db, sql: sql, arguments: [month])
        }
    }
    
    /// 取得預算計畫列表
    /// 包含計畫名稱、計畫金額、實際支出與餘額
    public func getBudgetPlanList(month: Date) async throws -> [BudgetPlanListDTO] {
        try await dbWriter.read { db in
            let sql = """
            SELECT
                p.plan_name,
                pd.plan_month as month,
                pd.plan_amount AS plan_amount,
                COALESCE(SUM(e.amount), 0) AS actual_amount,
                pd.plan_amount - COALESCE(SUM(e.amount), 0) AS balance
            FROM
                plan p
                JOIN plan_det pd ON pd.plan = p.rowid
                LEFT JOIN expense e ON e.target_plan = p.rowid
                AND pd.plan_month = date(e.pay_day, 'start of month')
            WHERE date(pd.plan_month, 'start of month') = date(?, 'start of month')
            GROUP BY
                p.rowid,
                pd.plan_month
            ORDER BY pd.plan_month, p.plan_name;
            """
            return try BudgetPlanListDTO.fetchAll(db, sql: sql, arguments: [month])
        }
    }
    
    public func getAccountBalance(month: Date) async throws -> [AccountBalance] {
        try await dbWriter.read { db in
            let sql = "SELECT * FROM account_balance_view WHERE cur_month = strftime('%Y-%m', ?)"
            return try AccountBalance.fetchAll(db, sql: sql, arguments: [month])
        }
    }
    
    public func getMonthlyIncome(month: Date) async throws -> Int {
        try await dbWriter.read { db in
            let sql = """
            SELECT COALESCE(SUM(amount), 0)
            FROM income
            WHERE date(in_day, 'start of month') = date(?, 'start of month')
            """
            return try Int.fetchOne(db, sql: sql, arguments: [month]) ?? 0
        }
    }
    
    public func getMonthlyExpense(month: Date) async throws -> Int {
        try await dbWriter.read { db in
            let sql = """
            SELECT COALESCE(SUM(amount), 0)
            FROM expense
            WHERE date(pay_day, 'start of month') = date(?, 'start of month')
            """
            return try Int.fetchOne(db, sql: sql, arguments: [month]) ?? 0
        }
    }
}
