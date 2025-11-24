import SwiftUI
import Combine

@MainActor
public class TransactionViewModel: ObservableObject {
    private let transactionUseCase: TransactionUseCase
    
    // @Published 屬性：當這些值改變時，UI 會自動更新
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var memo: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedAccount: Account?
    @Published var selectedPlan: Plan?
    
    // 資料來源 (Data Sources)
    @Published var categories: [Category] = []
    @Published var accounts: [Account] = []
    @Published var plans: [Plan] = []
    @Published var categoryPlans: [CategoryPlan] = []
    
    // 計算屬性：階層化分類 (Computed property for hierarchical categories)
    // 將分類整理成 父分類 -> 子分類 的順序，方便 Picker 顯示
    var hierarchicalCategories: [Category] {
        let parents = categories.filter { $0.parentCategory == nil }
        var result: [Category] = []
        for parent in parents {
            result.append(parent)
            let children = categories.filter { $0.parentCategory == parent.id }
            result.append(contentsOf: children)
        }
        return result
    }
    
    public init(transactionUseCase: TransactionUseCase) {
        self.transactionUseCase = transactionUseCase
    }
    
    /// 載入所需資料 (Load required data)
    /// 包括分類、帳戶、計畫以及分類與計畫的對應關係
    public func loadData() async {
        do {
            async let fetchedCategories = transactionUseCase.getCategories(type: "out")
            async let fetchedAccounts = transactionUseCase.getAccounts()
            async let fetchedPlans = transactionUseCase.getPlans()
            async let fetchedCategoryPlans = transactionUseCase.getCategoryPlans()
            
            let (cats, accs, pls, catPlans) = try await (fetchedCategories, fetchedAccounts, fetchedPlans, fetchedCategoryPlans)
            
            self.categories = cats
            self.accounts = accs
            self.plans = pls
            self.categoryPlans = catPlans
            
            // Log loaded data (Output to page)
            print("[TransactionViewModel] Loaded Data for UI:")
            print("  - Categories: \(categories)")
            print("  - Accounts: \(accounts)")
            print("  - Plans: \(plans)")
            print("  - CategoryPlans: \(categoryPlans)")
            
            // 設定預設值 (Set defaults)
            if let firstAccount = accounts.first {
                self.selectedAccount = firstAccount
            }
        } catch {
            print("[TransactionViewModel] Failed to load data: \(error)")
        }
    }
    
    /// 選擇分類並自動帶入計畫 (Select category and auto-fill plan)
    /// 選擇分類並自動帶入計畫 (Select category and auto-fill plan)
    public func selectCategory(_ category: Category) {
        self.selectedCategory = category
        autoSelectPlan(for: category)
    }
    
    public func autoSelectPlan(for category: Category) {
        // 自動選擇計畫 (Auto-select plan)
        if let mapping = categoryPlans.first(where: { $0.category == category.id }) {
            if let plan = plans.first(where: { $0.id == mapping.plan }) {
                self.selectedPlan = plan
                print("[TransactionViewModel] Auto-selected plan: \(plan.planName) for category: \(category.categoryName)")
            }
        }
    }
    
    /// 新增收入
    public func addIncome() async {
        // ... (Keep existing logic or update if needed, but focus is on Expense)
    }
    
    /// 新增支出
    public func addExpense() async {
        print("[TransactionViewModel] addExpense called.")
        
        // Log input values (Values to be saved)
        print("[TransactionViewModel] Input Values:")
        print("  - Amount: \(amount)")
        print("  - Date: \(date)")
        print("  - Category: \(selectedCategory?.categoryName ?? "None") (ID: \(selectedCategory?.id ?? -1))")
        print("  - Plan: \(selectedPlan?.planName ?? "None") (ID: \(selectedPlan?.id ?? -1))")
        print("  - Account: \(selectedAccount?.accountName ?? "None") (ID: \(selectedAccount?.id ?? -1))")
        print("  - Memo: \(memo)")
        
        guard let amountInt = Int(amount),
              let category = selectedCategory,
              let account = selectedAccount else {
            print("[TransactionViewModel] Validation failed for addExpense")
            return
        }
        
        do {
            try await transactionUseCase.addExpense(
                amount: amountInt,
                categoryId: category.id ?? 0,
                planId: selectedPlan?.id,
                accountId: account.id ?? 0,
                date: date,
                memo: memo
            )
            print("[TransactionViewModel] addExpense success")
        } catch {
            print("[TransactionViewModel] addExpense failed: \(error)")
        }
    }
}
