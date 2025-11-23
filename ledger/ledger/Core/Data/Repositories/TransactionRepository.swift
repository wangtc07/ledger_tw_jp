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
}
