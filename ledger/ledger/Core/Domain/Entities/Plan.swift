import GRDB
import Foundation

public struct Plan: Codable, FetchableRecord, PersistableRecord, Identifiable, Hashable {
    public var id: Int64?
    public var planName: String
    public var targetBudget: Int64
    
    public init(id: Int64? = nil, planName: String, targetBudget: Int64) {
        self.id = id
        self.planName = planName
        self.targetBudget = targetBudget
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "rowid"
        case planName = "plan_name"
        case targetBudget = "target_budget"
    }
}

public struct PlanDet: Codable, FetchableRecord, PersistableRecord {
    public static var databaseTableName = "plan_det"
    
    public var planId: Int64
    public var planMonth: Date
    public var planAmount: Int
    
    public init(planId: Int64, planMonth: Date, planAmount: Int) {
        self.planId = planId
        self.planMonth = planMonth
        self.planAmount = planAmount
    }
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan"
        case planMonth = "plan_month"
        case planAmount = "plan_amount"
    }
}
