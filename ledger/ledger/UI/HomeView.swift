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
                        // Income/Expense/Balance Row
                        HStack {
                            VStack {
                                Text("當月收入")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(viewModel.homeData?.monthlyIncome ?? 0)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            VStack {
                                Text("當月支出")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(viewModel.homeData?.monthlyExpense ?? 0)")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            VStack {
                                Text("當月結餘")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\((viewModel.homeData?.monthlyIncome ?? 0) - (viewModel.homeData?.monthlyExpense ?? 0))")
                                    .font(.headline)
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        // Month Selector
                        HStack {
                            Button(action: viewModel.previousMonth) {
                                Image(systemName: "chevron.left")
                            }
                            Spacer()
                            Text(viewModel.currentMonth, style: .date)
                                .font(.headline)
                            Spacer()
                            Button(action: viewModel.nextMonth) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    
                    // Budget List
                    ScrollView {
                        VStack(spacing: 16) {
                            if let data = viewModel.homeData {
                                if data.budgets.isEmpty {
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
                                    ForEach(data.budgets, id: \.budgetName) { budget in
                                        BudgetCard(budget: budget, plans: data.plans)
                                    }
                                }
                            } else {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                }
                
                // Floating Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            NavigationLink(destination: AddIncomeView(appDatabase: appDatabase)) {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            NavigationLink(destination: AddExpenseView(appDatabase: appDatabase)) {
                                Image(systemName: "minus")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                        .padding()
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
            
            // Budget Progress Bar
            VStack(spacing: 4) {
                HStack {
                    Text("累積預算: \(budget.cumulativeBudget)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(budget.curMonSpent) / \(budget.curBudget)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(budget.curMonSpent) / CGFloat(max(budget.curBudget, 1)) * geometry.size.width, geometry.size.width), height: 8)
                            .foregroundColor(budget.curMonSpent > budget.curBudget ? .red : .blue)
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
            
            // Plans List (Expanded)
            if isExpanded {
                Divider()
                ForEach(plans.filter { $0.planName.contains(budget.budgetName) }, id: \.planName) { plan in // Naive filtering
                    NavigationLink(destination: PlanDetailView(plan: plan)) {
                        VStack(spacing: 4) {
                            HStack {
                                Text(plan.planName)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(plan.actualAmount) / \(plan.planAmount)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 6)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                    
                                    Rectangle()
                                        .frame(width: min(CGFloat(plan.actualAmount) / CGFloat(max(plan.planAmount, 1)) * geometry.size.width, geometry.size.width), height: 6)
                                        .foregroundColor(plan.actualAmount > plan.planAmount ? .red : .blue)
                                }
                                .cornerRadius(3)
                            }
                            .frame(height: 6)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}


