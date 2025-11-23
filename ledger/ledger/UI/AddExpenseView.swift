import SwiftUI

public struct AddExpenseView: View {
    // @Environment(\.presentationMode) 用來控制視圖的顯示狀態，例如關閉目前頁面
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: TransactionViewModel
    
    // Need to inject dependencies properly in a real app
    public init(appDatabase: AppDatabase?) {
        guard let appDatabase = appDatabase else {
            // Handle error or use preview mock
            fatalError("AppDatabase is missing")
        }
        let repo = TransactionRepository(dbWriter: appDatabase.dbWriter)
        let accountRepo = AccountRepository(dbWriter: appDatabase.dbWriter)
        let useCase = TransactionUseCase(transactionRepo: repo, accountRepo: accountRepo)
        _viewModel = StateObject(wrappedValue: TransactionViewModel(transactionUseCase: useCase))
    }
    
    public var body: some View {
        // Form 提供標準的表單樣式
        Form {
            // DatePicker 日期選擇器
            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            #if os(iOS)
            TextField("Amount", text: $viewModel.amount)
                .keyboardType(.numberPad)
            #else
            TextField("Amount", text: $viewModel.amount)
            #endif
            TextField("Memo", text: $viewModel.memo)
            
            Button("Save") {
                // Task 用於在按鈕點擊時執行非同步程式碼
                Task {
                    await viewModel.addExpense()
                    // 關閉目前視圖，返回上一頁
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Add Expense")
    }
}
