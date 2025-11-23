import SwiftUI
public import Combine

/// 首頁的視圖模型 (ViewModel)
/// @MainActor 確保所有 UI 更新都在主執行緒進行
@MainActor
public class HomeViewModel: ObservableObject {
    // @Published 當此屬性改變時，會通知 View 重新繪製
    @Published var homeData: HomeUseCase.HomeData?
    @Published var currentMonth: Date = Date()
    
    private let homeUseCase: HomeUseCase
    
    public init(homeUseCase: HomeUseCase) {
        self.homeUseCase = homeUseCase
    }
    
    /// 載入首頁資料
    public func loadData() async {
        print("[HomeViewModel] loadData called for: \(currentMonth)")
        do {
            // 呼叫 UseCase 取得資料，並更新 Published 屬性
            self.homeData = try await homeUseCase.getHomeData(currentMonth: currentMonth)
            print("[HomeViewModel] loadData success")
        } catch {
            print("[HomeViewModel] Error loading home data: \(error)")
        }
    }
    
    public func nextMonth() {
        print("[HomeViewModel] nextMonth called")
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        Task { await loadData() }
    }
    
    public func previousMonth() {
        print("[HomeViewModel] previousMonth called")
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        Task { await loadData() }
    }
}
