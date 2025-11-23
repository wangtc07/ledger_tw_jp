import XCTest
import GRDB
@testable import MyAppCore

final class IntegrationTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var appDatabase: AppDatabase!
    
    override func setUpWithError() throws {
        dbQueue = try DatabaseQueue()
        appDatabase = try AppDatabase(dbQueue)
    }
    
    func testFullFlow() async throws {
        let db = appDatabase.dbWriter
        
        // 1. Setup Initial Data
        try await db.write { db in
            // Account
            var account = Account(accountName: "Cash", initAmount: 1000)
            try account.save(db)
            
            // Category
            var foodCat = Category(categoryName: "Food", inOut: "OUT")
            try foodCat.save(db)
            
            // Budget
            var budget = Budget(budgetName: "Monthly")
            try budget.save(db)
            
            // Budget Detail
            let budgetDet = BudgetDet(budgetId: budget.id!, budgetMonth: Date(), budgetAmount: 5000)
            try budgetDet.save(db)
            
            // Plan
            var plan = Plan(planName: "Lunch", targetBudget: budget.id!)
            try plan.save(db)
            
            // Plan Detail
            let planDet = PlanDet(planId: plan.id!, planMonth: Date(), planAmount: 3000)
            try planDet.save(db)
        }
        
        // 2. Add Transactions
        let transactionRepo = TransactionRepository(dbWriter: db)
        let accountRepo = AccountRepository(dbWriter: db)
        let transactionUseCase = TransactionUseCase(transactionRepo: transactionRepo, accountRepo: accountRepo)
        
        // Expense
        try await transactionUseCase.addExpense(
            amount: 100,
            categoryId: 1, // Food
            planId: 1, // Lunch
            accountId: 1, // Cash
            date: Date(),
            memo: "Sandwich"
        )
        
        // Income
        try await transactionUseCase.addIncome(
            amount: 500,
            categoryId: 1, // Dummy
            accountId: 1, // Cash
            date: Date(),
            memo: "Bonus"
        )
        
        // 3. Verify Home Data
        let budgetRepo = BudgetRepository(dbWriter: db)
        let homeUseCase = HomeUseCase(budgetRepo: budgetRepo)
        let homeData = try await homeUseCase.getHomeData()
        
        // Verify Account Balance
        // Init 1000 + Income 500 - Expense 100 = 1400?
        // Wait, Account Balance View calculation:
        // total_in (500) - total_out (100) = 400.
        // It doesn't include initAmount in the view currently based on SQL.
        // The SQL `account_balance_view` only sums income and expense.
        // Let's check the view definition in `AppDatabase.swift`.
        // Yes, it sums income and expense.
        
        XCTAssertEqual(homeData.accountBalances.count, 1)
        if let balance = homeData.accountBalances.first {
            XCTAssertEqual(balance.totalIn, 500)
            XCTAssertEqual(balance.totalOut, 100)
            XCTAssertEqual(balance.balAmount, 400)
        }
        
        // Verify Budget List
        XCTAssertEqual(homeData.budgets.count, 1)
        if let budget = homeData.budgets.first {
            XCTAssertEqual(budget.budgetName, "Monthly")
            XCTAssertEqual(budget.curBudget, 5000)
            XCTAssertEqual(budget.curMonSpent, 100)
        }
        
        // Verify Plan List
        XCTAssertEqual(homeData.plans.count, 1)
        if let plan = homeData.plans.first {
            XCTAssertEqual(plan.planName, "Lunch")
            XCTAssertEqual(plan.planAmount, 3000)
            XCTAssertEqual(plan.actualAmount, 100)
            XCTAssertEqual(plan.balance, 2900)
        }
    }
}
