import GRDB
import Foundation

public struct DailyTrans: Codable, FetchableRecord, PersistableRecord {
    public var noteDate: Date
    public var inAmount: Int?
    public var outAmount: Int?
    public var inAccountName: String?
    public var outAccountName: String?
    public var categoryName: String?
    public var memo: String?
    
    enum CodingKeys: String, CodingKey {
        case noteDate = "note_date"
        case inAmount = "in_amount"
        case outAmount = "out_amount"
        case inAccountName = "in_account_name"
        case outAccountName = "out_account_name"
        case categoryName = "category_name"
        case memo
    }
    
    public static let databaseTableName = "daily_trans_view"
}

public struct BudgetBalance: Codable, FetchableRecord, PersistableRecord {
    public var budgetName: String
    public var curMonth: String
    public var totalBudget: Int?
    public var totalAmount: Int
    public var balAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case budgetName = "budget_name"
        case curMonth = "cur_month"
        case totalBudget = "total_budget"
        case totalAmount = "total_amount"
        case balAmount = "bal_amount"
    }
    
    public static let databaseTableName = "budget_balance_view"
}

public struct AccountBalance: Codable, FetchableRecord, PersistableRecord {
    public var curMonth: String
    public var totalIn: Int?
    public var totalOut: Int?
    public var balAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case curMonth = "cur_month"
        case totalIn = "total_in"
        case totalOut = "total_out"
        case balAmount = "bal_amount"
    }
    
    public static let databaseTableName = "account_balance_view"
}

public struct BudgetListDTO: Codable, FetchableRecord {
    public var budgetName: String
    public var month: Date
    public var curBudget: Int
    public var cumulativeBudget: Int
    public var curMonSpent: Int
    
    enum CodingKeys: String, CodingKey {
        case budgetName = "budget_name"
        case month
        case curBudget = "cur_budget"
        case cumulativeBudget = "cumulative_budget"
        case curMonSpent = "cur_mon_spent"
    }
}

public struct BudgetPlanListDTO: Codable, FetchableRecord {
    public var planName: String
    public var month: Date
    public var planAmount: Int
    public var actualAmount: Int
    public var balance: Int
    
    enum CodingKeys: String, CodingKey {
        case planName = "plan_name"
        case month
        case planAmount = "plan_amount"
        case actualAmount = "actual_amount"
        case balance
    }
}
