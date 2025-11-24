import GRDB
import Foundation

/// 交易相關的資料倉庫
/// 負責支出、收入與轉帳的儲存與查詢
public struct TransactionRepository {
    private let dbWriter: any DatabaseWriter
    
    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }
    
    /// 儲存支出紀錄
    public func saveExpense(_ expense: Expense) async throws {
        print("[TransactionRepository] Writing Expense to DB: \(expense)")
        try await dbWriter.write { db in
            try expense.save(db)
        }
    }
    
    /// 儲存收入紀錄
    public func saveIncome(_ income: Income) async throws {
        try await dbWriter.write { db in
            try income.save(db)
        }
    }
    
    public func saveTrans(_ trans: Trans) async throws {
        try await dbWriter.write { db in
            try trans.save(db)
        }
    }
    
    public func getDailyTransactions() async throws -> [DailyTrans] {
        try await dbWriter.read { db in
            try DailyTrans.fetchAll(db)
        }
    }
    
    /// 取得所有分類 (Get all categories)
    /// - Parameter type: 分類類型 ("in" 為收入, "out" 為支出)
    public func getCategories(type: String) async throws -> [Category] {
        try await dbWriter.read { db in
            try Category.filter(Column("in_out") == type).fetchAll(db)
        }
    }
    
    /// 取得所有帳戶 (Get all accounts)
    public func getAccounts() async throws -> [Account] {
        try await dbWriter.read { db in
            try Account.fetchAll(db)
        }
    }
    
    /// 取得所有計畫 (Get all plans)
    public func getPlans() async throws -> [Plan] {
        try await dbWriter.read { db in
            try Plan.fetchAll(db)
        }
    }
    
    /// 取得分類與計畫的對應關係 (Get Category-Plan mappings)
    public func getCategoryPlans() async throws -> [CategoryPlan] {
        try await dbWriter.read { db in
            try CategoryPlan.fetchAll(db)
        }
    }
}
