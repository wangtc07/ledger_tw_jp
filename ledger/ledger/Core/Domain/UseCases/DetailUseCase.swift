import Foundation

/// 明細頁面的業務邏輯層
public struct DetailUseCase {
    private let budgetRepo: BudgetRepository
    
    public init(budgetRepo: BudgetRepository) {
        self.budgetRepo = budgetRepo
    }
    
    // 未來可以擴充為根據特定計畫或預算進行篩選
    /// 取得計畫詳細資訊列表
    public func getPlanDetails(month: Date) async throws -> [BudgetPlanListDTO] {
        return try await budgetRepo.getBudgetPlanList(month: month)
    }
}
