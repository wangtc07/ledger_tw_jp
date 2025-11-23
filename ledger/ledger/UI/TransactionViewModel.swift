import SwiftUI
import Combine

@MainActor
public class TransactionViewModel: ObservableObject {
    private let transactionUseCase: TransactionUseCase
    
    // @Published 屬性：當這些值改變時，UI 會自動更新
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var memo: String = ""
    @Published var selectedCategoryIndex: Int = 0
    @Published var selectedAccountIndex: Int = 0
    @Published var selectedPlanIndex: Int = 0
    
    // In a real app, these would be fetched from DB
    @Published var categories: [Category] = []
    @Published var accounts: [Account] = []
    @Published var plans: [Plan] = []
    
    public init(transactionUseCase: TransactionUseCase) {
        self.transactionUseCase = transactionUseCase
    }
    
    /// 新增收入
    public func addIncome() async {
        print("[TransactionViewModel] addIncome called. Amount: \(amount), Date: \(date), Category: \(selectedCategoryIndex), Account: \(selectedAccountIndex)")
        guard let amountInt = Int(amount),
              categories.indices.contains(selectedCategoryIndex),
              accounts.indices.contains(selectedAccountIndex) else {
            print("[TransactionViewModel] Validation failed for addIncome")
            return
        }
        
        // In a real app, use the ID, not the index
        let category = categories[selectedCategoryIndex]
        let account = accounts[selectedAccountIndex]
        
        do {
            try await transactionUseCase.addIncome(amount: amountInt, categoryId: category.id ?? 0, accountId: account.id ?? 0, date: date, memo: memo)
            print("[TransactionViewModel] addIncome success")
        } catch {
            print("[TransactionViewModel] addIncome failed: \(error)")
        }
    }
    
    /// 新增支出
    /// 這是非同步函式 (async)，因為資料庫操作需要時間
    public func addExpense() async {
        print("[TransactionViewModel] addExpense called. Amount: \(amount), Date: \(date), Category: \(selectedCategoryIndex), Plan: \(selectedPlanIndex), Account: \(selectedAccountIndex)")
        guard let amountInt = Int(amount),
              categories.indices.contains(selectedCategoryIndex),
              plans.indices.contains(selectedPlanIndex),
              accounts.indices.contains(selectedAccountIndex) else {
            print("[TransactionViewModel] Validation failed for addExpense")
            return
        }
        
        let category = categories[selectedCategoryIndex]
        let plan = plans[selectedPlanIndex]
        let account = accounts[selectedAccountIndex]
        
        do {
            try await transactionUseCase.addExpense(amount: amountInt, categoryId: category.id ?? 0, planId: plan.id ?? 0, accountId: account.id ?? 0, date: date, memo: memo)
            print("[TransactionViewModel] addExpense success")
        } catch {
            print("[TransactionViewModel] addExpense failed: \(error)")
        }
    }
}
