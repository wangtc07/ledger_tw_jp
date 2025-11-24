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
        VStack(spacing: 0) {
            formContent
            saveButton
        }
        .navigationTitle("新增支出")
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    private var formContent: some View {
        Form {
            Section {
                // Date (日期)
                HStack {
                    Text("日期")
                    Spacer()
                    DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }
                // Amount (金額)
                HStack {
                    Text("金額")
                    Spacer()
                    TextField("0", text: $viewModel.amount)
                        .keyboardType(.numberPad) // 數字鍵盤
                        .multilineTextAlignment(.trailing) // 靠右對齊
                }
                // Category (分類)
                NavigationLink(destination: CategorySelectionView(categories: viewModel.categories, selectedCategory: $viewModel.selectedCategory)) {
                    HStack {
                        Text("分類")
                        Spacer()
                        if let category = viewModel.selectedCategory {
                            Text(category.categoryName)
                                .foregroundColor(.primary)
                        } else {
                            Text("請選擇分類")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onChange(of: viewModel.selectedCategory) { category in
                    if let category = category {
                        viewModel.autoSelectPlan(for: category)
                    }
                }
                // Plan (Auto-filled but editable) (計畫 - 自動帶入但可修改)
                Picker("計畫", selection: $viewModel.selectedPlan) {
                    Text("無計畫").tag(nil as Plan?)
                    ForEach(viewModel.plans) { plan in
                        Text(plan.planName).tag(plan as Plan?)
                    }
                }
                // Account (帳戶)
                Picker("帳戶", selection: $viewModel.selectedAccount) {
                    Text("請選擇帳戶").tag(nil as Account?)
                    ForEach(viewModel.accounts) { account in
                        Text(account.accountName).tag(account as Account?)
                    }
                }
                // Memo (備註)
                TextField("備註", text: $viewModel.memo)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
    
    // Save Button (保存按鈕)
    // 獨立放在底部，全寬顯示
    private var saveButton: some View {
        Button(action: {
            Task {
                await viewModel.addExpense()
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Text("保存")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
        }
    }
}
