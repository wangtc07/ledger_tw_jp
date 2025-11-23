import GRDB
import Foundation

public struct Budget: Codable, FetchableRecord, PersistableRecord, Identifiable {
    public var id: Int64?
    public var budgetName: String
    
    public init(id: Int64? = nil, budgetName: String) {
        self.id = id
        self.budgetName = budgetName
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "rowid"
        case budgetName = "budget_name"
    }
}

public struct BudgetDet: Codable, FetchableRecord, PersistableRecord {
    public var budgetId: Int64
    public var budgetMonth: Date
    public var budgetAmount: Int
    
    public init(budgetId: Int64, budgetMonth: Date, budgetAmount: Int) {
        self.budgetId = budgetId
        self.budgetMonth = budgetMonth
        self.budgetAmount = budgetAmount
    }
    
    enum CodingKeys: String, CodingKey {
        case budgetId = "budget"
        case budgetMonth = "budget_month"
        case budgetAmount = "budget_amount"
    }
}
