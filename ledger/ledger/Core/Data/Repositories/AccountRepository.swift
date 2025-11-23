import GRDB
import Foundation

/// 帳戶相關的資料倉庫
/// 負責帳戶的增刪改查 (CRUD)
public struct AccountRepository {
    private let dbWriter: any DatabaseWriter
    
    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }
    
    /// 取得所有帳戶
    public func getAllAccounts() async throws -> [Account] {
        try await dbWriter.read { db in
            try Account.fetchAll(db)
        }
    }
    
    /// 新增或更新帳戶
    /// - Parameter account: 要儲存的帳戶實體 (inout 因為可能會更新 ID)
    public func saveAccount(_ account: inout Account) async throws {
        // 使用 dbWriter.write 進行寫入操作，這會確保執行緒安全
        let savedAccount = try await dbWriter.write { [account] db in
            let account = account
            try account.save(db)
            return account
        }
        account = savedAccount
    }
    
    public func deleteAccount(_ account: Account) async throws {
        try await dbWriter.write { db in
            _ = try account.delete(db)
        }
    }
}
