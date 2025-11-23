import Foundation

/// 首頁的業務邏輯層
/// 負責聚合首頁所需的各種資料
public struct HomeUseCase {
    private let budgetRepo: BudgetRepository
    
    public init(budgetRepo: BudgetRepository) {
        self.budgetRepo = budgetRepo
    }
    
    /// 首頁資料結構
    public struct HomeData {
        public var accountBalances: [AccountBalance]
        public var budgets: [BudgetListDTO]
        public var plans: [BudgetPlanListDTO]
        public var monthlyIncome: Int
        public var monthlyExpense: Int
    }
    
    /// 取得首頁所需的所有資料
    /// 使用 async let 並發執行多個查詢，提升效能
    public func getHomeData(currentMonth: Date) async throws -> HomeData {
        print("--- [HomeUseCase] Fetching data for: \(currentMonth) ---")
        
        // async let 允許這些任務同時開始執行
        async let balances = budgetRepo.getAccountBalance(month: currentMonth)
        async let budgets = budgetRepo.getBudgetList(month: currentMonth)
        async let plans = budgetRepo.getBudgetPlanList(month: currentMonth)
        async let income = budgetRepo.getMonthlyIncome(month: currentMonth)
        async let expense = budgetRepo.getMonthlyExpense(month: currentMonth)
        
        // await 等待所有任務完成
        let (fetchedBalances, fetchedBudgets, fetchedPlans, fetchedIncome, fetchedExpense) = try await (balances, budgets, plans, income, expense)
        
        print("[HomeUseCase] Monthly Income: \(fetchedIncome)")
        print("[HomeUseCase] Monthly Expense: \(fetchedExpense)")
        print("[HomeUseCase] Account Balances: \(fetchedBalances)")
        print("[HomeUseCase] Budgets: \(fetchedBudgets)")
        print("[HomeUseCase] Plans: \(fetchedPlans)")
        print("---------------------------------------------------")
        
        return HomeData(
            accountBalances: fetchedBalances,
            budgets: fetchedBudgets,
            plans: fetchedPlans,
            monthlyIncome: fetchedIncome,
            monthlyExpense: fetchedExpense
        )
    }
}
