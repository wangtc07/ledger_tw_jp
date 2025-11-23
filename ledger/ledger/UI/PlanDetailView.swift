import SwiftUI

public struct PlanDetailView: View {
    // 從上一頁傳入的資料，不需要 @State 或 @Binding，因為只是唯讀顯示
    let plan: BudgetPlanListDTO
    
    public init(plan: BudgetPlanListDTO) {
        self.plan = plan
    }
    
    public var body: some View {
        VStack {
            Text(plan.planName)
                .font(.largeTitle)
            
            HStack {
                Text("Plan: \(plan.planAmount)")
                Spacer()
                Text("Actual: \(plan.actualAmount)")
            }
            .padding()
            
            List {
                // Here we should list the transactions for this plan
                // We need to fetch them using DetailUseCase or TransactionUseCase
                Text("Transaction 1")
                Text("Transaction 2")
            }
        }
        .navigationTitle(plan.planName)
        .onAppear {
            print("[PlanDetailView] View appeared for plan: \(plan.planName)")
        }
    }
}
