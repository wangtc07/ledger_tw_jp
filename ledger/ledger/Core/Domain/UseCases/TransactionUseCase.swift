import Foundation

/// 交易業務邏輯層
/// 負責處理新增支出、收入等業務規則
public struct TransactionUseCase {
    private let transactionRepo: TransactionRepository
    private let accountRepo: AccountRepository
    
    public init(transactionRepo: TransactionRepository, accountRepo: AccountRepository) {
        self.transactionRepo = transactionRepo
        self.accountRepo = accountRepo
    }
    
    /// 新增一筆支出
    /// - Parameters:
    ///   - amount: 金額
    ///   - categoryId: 類別 ID
    ///   - planId: 關聯的計畫 ID (可選)
    ///   - accountId: 支付帳戶 ID
    ///   - date: 日期
    ///   - memo: 備註
    public func addExpense(amount: Int, categoryId: Int64, planId: Int64?, accountId: Int64, date: Date, memo: String?) async throws {
        let expense = Expense(
            payDay: date,
            amount: amount,
            targetCategory: categoryId,
            targetPlan: planId,
            targetAccount: accountId,
            memo: memo
        )
        try await transactionRepo.saveExpense(expense)
    }
    
    public func addIncome(amount: Int, categoryId: Int64, accountId: Int64, date: Date, memo: String?) async throws {
        let income = Income(
            inDay: date,
            amount: amount,
            targetCategory: categoryId,
            targetAccount: accountId,
            memo: memo
        )
        try await transactionRepo.saveIncome(income)
    }
    
    public func getDailyTransactions() async throws -> [DailyTrans] {
        return try await transactionRepo.getDailyTransactions()
    }
}
