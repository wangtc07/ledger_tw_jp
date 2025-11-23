import SwiftUI
import Combine

public struct HomeView: View {
    @Environment(\.appDatabase) var appDatabase
    @StateObject var viewModel: HomeViewModel
    
    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Top Summary Area
                    VStack(spacing: 16) {
                        // Income/Expense/Balance Row (收入/支出/結餘列)
                        HStack {
                            // 當月收入
                            VStack {
                                Text("當月收入")
                                    .font(.caption) // 字體大小: caption
                                    .foregroundColor(.gray) // 字體顏色: 灰色
                                Text("\(viewModel.homeData?.monthlyIncome ?? 0)")
                                    .font(.headline) // 字體大小: headline
                                    .foregroundColor(.blue) // 字體顏色: 藍色
                            }
                            Spacer() // 彈性空間
                            // 當月支出
                            VStack {
                                Text("當月支出")
                                    .font(.caption) // 字體大小: caption
                                    .foregroundColor(.gray) // 字體顏色: 灰色
                                Text("\(viewModel.homeData?.monthlyExpense ?? 0)")
                                    .font(.headline) // 字體大小: headline
                                    .foregroundColor(.red) // 字體顏色: 紅色
                            }
                            Spacer() // 彈性空間
                            // 當月結餘
                            VStack {
                                Text("當月結餘")
                                    .font(.caption) // 字體大小: caption
                                    .foregroundColor(.gray) // 字體顏色: 灰色
                                Text("\((viewModel.homeData?.monthlyIncome ?? 0) - (viewModel.homeData?.monthlyExpense ?? 0))")
                                    .font(.headline) // 字體大小: headline
                            }
                        }
                        .padding(.horizontal) // 水平方向內距
                        
                        Divider()
                        
                        // Month Selector (月份選擇器)
                        HStack {
                            Button(action: viewModel.previousMonth) {
                                Image(systemName: "chevron.left") // 圖示: 向左箭頭
                            }
                            Spacer() // 彈性空間
                            Text(viewModel.currentMonth, style: .date)
                                .font(.headline) // 字體大小: headline
                            Spacer() // 彈性空間
                            Button(action: viewModel.nextMonth) {
                                Image(systemName: "chevron.right") // 圖示: 向右箭頭
                            }
                        }
                        .padding(.horizontal) // 水平方向內距
                    }
                    .padding(.vertical) // 垂直方向內距
                    .background(Color.white) // 背景顏色: 白色
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5) // 陰影效果
                    
                    // Budget List (預算列表)
                    ScrollView {
                        VStack(spacing: 16) {
                            if let data = viewModel.homeData {
                                if data.budgets.isEmpty {
                                    // Empty State (無資料狀態)
                                    VStack {
                                        Spacer()
                                        Text("沒有資料")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                            .padding()
                                        Spacer()
                                    }
                                    .frame(height: 200) // Give it some height
                                } else {
                                    // Budget Cards (預算卡片)
                                    ForEach(data.budgets, id: \.budgetName) { budget in
                                        BudgetCard(budget: budget, plans: data.plans)
                                    }
                                }
                            } else {
                                // Loading State (載入中狀態)
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                }
                
                // Floating Action Buttons (懸浮按鈕)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            // Add Income Button (新增收入按鈕)
                            NavigationLink(destination: AddIncomeView(appDatabase: appDatabase)) {
                                Image(systemName: "plus") // 圖示: 加號
                                    .font(.title) // 字體大小: title
                                    .foregroundColor(.white) // 字體顏色: 白色
                                    .frame(width: 56, height: 56) // 按鈕大小: 56x56
                                    .background(Color.blue) // 背景顏色: 藍色
                                    .clipShape(Circle()) // 形狀: 圓形
                                    .shadow(radius: 4) // 陰影半徑: 4
                            }
                            
                            // Add Expense Button (新增支出按鈕)
                            NavigationLink(destination: AddExpenseView(appDatabase: appDatabase)) {
                                Image(systemName: "minus") // 圖示: 減號
                                    .font(.title) // 字體大小: title
                                    .foregroundColor(.white) // 字體顏色: 白色
                                    .frame(width: 56, height: 56) // 按鈕大小: 56x56
                                    .background(Color.red) // 背景顏色: 紅色
                                    .clipShape(Circle()) // 形狀: 圓形
                                    .shadow(radius: 4) // 陰影半徑: 4
                            }
                        }
                        .padding() // 內距
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                print("[HomeView] View appeared, loading data...")
                await viewModel.loadData()
            }
        }
    }
}

struct BudgetCard: View {
    let budget: BudgetListDTO
    let plans: [BudgetPlanListDTO]
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Budget Header
            HStack {
                Text(budget.budgetName)
                    .font(.headline)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            // Budget Progress Bar (預算進度條)
            VStack(spacing: 4) {
                HStack {
                    Text("累積預算: \(budget.cumulativeBudget)")
                        .font(.caption) // 字體大小: caption
                        .foregroundColor(.gray) // 字體顏色: 灰色
                    Spacer() // 彈性空間
                    Text("\(budget.curMonSpent) / \(budget.curBudget)")
                        .font(.caption) // 字體大小: caption
                        .foregroundColor(.gray) // 字體顏色: 灰色
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background Bar (背景條)
                        Rectangle()
                            .frame(width: geometry.size.width, height: 20) // 高度: 20
                            .opacity(0.3) // 透明度: 0.3
                            .foregroundColor(.gray) // 顏色: 灰色
                        
                        // Progress Bar (進度條)
                        Rectangle()
                            .frame(width: min(CGFloat(budget.curMonSpent) / CGFloat(max(budget.curBudget, 1)) * geometry.size.width, geometry.size.width), height: 20) // 計算進度寬度
                            .foregroundColor(budget.curMonSpent > budget.curBudget ? .red : .blue) // 超支顯示紅色，否則藍色
                        
                            // Text Overlay (文字覆蓋)
                            HStack {
                                // Percentage (百分比)
                                let percentage = budget.curBudget > 0 ? Int(Double(budget.curMonSpent) / Double(budget.curBudget) * 100) : 0
                                Text("\(percentage)%")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.leading, 6)
                                
                                Spacer()
                                
                                // Balance (餘額)
                                let balance = budget.curBudget - budget.curMonSpent
                                Text("\(balance)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 6)
                            }
                        .frame(width: geometry.size.width, height: 20)
                    }
                    .cornerRadius(10) // 圓角: 10
                }
                .frame(height: 20) // 高度: 20
            }
            
            // Plans List (Expanded) (展開後的計畫列表)
            if isExpanded {
                Divider()
                
                // Filter plans for this budget (篩選此預算下的計畫)
                let budgetPlans = plans.filter { $0.targetBudgetID == budget.budgetID }
                
                if budgetPlans.isEmpty {
                    Text("無支出計畫")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 4)
                } else {
                    ForEach(budgetPlans, id: \.planName) { plan in
                        VStack(spacing: 4) {
                            HStack {
                                Text(plan.planName)
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            // Bar (進度條)
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background (背景)
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 16) // 高度: 16
                                        .opacity(0.3) // 透明度: 0.3
                                        .foregroundColor(.gray) // 顏色: 灰色
                                    
                                    // Foreground (前景)
                                    let percentage = plan.planAmount > 0 ? Int(Double(plan.actualAmount) / Double(plan.planAmount) * 100) : 0
                                    Rectangle()
                                        .frame(width: min(CGFloat(plan.actualAmount) / CGFloat(max(plan.planAmount, 1)) * geometry.size.width, geometry.size.width), height: 16) // 計算進度寬度
                                        .foregroundColor(percentage > 100 ? .red : .blue) // 超過100%顯示紅色，否則藍色
                                    
                                    // Text Overlay (文字覆蓋)
                                    HStack {
                                        // Percentage (百分比)
                                        Text("\(percentage)%")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.leading, 6)
                                        
                                        Spacer()
                                        
                                        // Balance (餘額)
                                        Text("\(plan.balance)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.trailing, 6)
                                    }
                                    .frame(width: geometry.size.width, height: 16)
                                }
                                .cornerRadius(8) // 圓角: 8
                            }
                            .frame(height: 16) // 高度: 16
                        }
                        .padding(.vertical, 4) // 垂直方向內距: 4
                    }
                }
            }
        }
        .padding() // 內距
        .background(Color.white) // 背景顏色: 白色
        .cornerRadius(12) // 圓角: 12
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // 陰影效果
    }
}


