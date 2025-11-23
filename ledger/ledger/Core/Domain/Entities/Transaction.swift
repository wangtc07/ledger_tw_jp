import GRDB
import Foundation

public struct Expense: Codable, FetchableRecord, PersistableRecord {
    public var payDay: Date
    public var amount: Int
    public var targetCategory: Int64?
    public var targetPlan: Int64?
    public var targetAccount: Int64?
    public var memo: String?
    
    public init(payDay: Date, amount: Int, targetCategory: Int64?, targetPlan: Int64?, targetAccount: Int64?, memo: String?) {
        self.payDay = payDay
        self.amount = amount
        self.targetCategory = targetCategory
        self.targetPlan = targetPlan
        self.targetAccount = targetAccount
        self.memo = memo
    }
    
    enum CodingKeys: String, CodingKey {
        case payDay = "pay_day"
        case amount
        case targetCategory = "target_category"
        case targetPlan = "target_plan"
        case targetAccount = "target_account"
        case memo
    }
}

public struct Income: Codable, FetchableRecord, PersistableRecord {
    public var inDay: Date
    public var amount: Int
    public var targetCategory: Int64?
    public var targetAccount: Int64?
    public var memo: String?
    
    public init(inDay: Date, amount: Int, targetCategory: Int64? = 1, targetAccount: Int64?, memo: String?) {
        self.inDay = inDay
        self.amount = amount
        self.targetCategory = targetCategory
        self.targetAccount = targetAccount
        self.memo = memo
    }
    
    enum CodingKeys: String, CodingKey {
        case inDay = "in_day"
        case amount
        case targetCategory = "target_category"
        case targetAccount = "target_account"
        case memo
    }
}

public struct Trans: Codable, FetchableRecord, PersistableRecord {
    public var transferDay: Date
    public var amount: Int
    public var inAccount: Int64?
    public var outAccount: Int64?
    public var memo: String?
    
    public init(transferDay: Date, amount: Int, inAccount: Int64?, outAccount: Int64?, memo: String?) {
        self.transferDay = transferDay
        self.amount = amount
        self.inAccount = inAccount
        self.outAccount = outAccount
        self.memo = memo
    }
    
    enum CodingKeys: String, CodingKey {
        case transferDay = "transfer_day"
        case amount
        case inAccount = "in_account"
        case outAccount = "out_account"
        case memo
    }
}
