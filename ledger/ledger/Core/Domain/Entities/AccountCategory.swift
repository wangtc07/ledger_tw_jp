import GRDB
import Foundation

public struct Account: Codable, FetchableRecord, PersistableRecord, Identifiable {
    public var id: Int64?
    public var accountName: String
    public var initAmount: Int
    public var invest: Bool
    
    public init(id: Int64? = nil, accountName: String, initAmount: Int, invest: Bool = false) {
        self.id = id
        self.accountName = accountName
        self.initAmount = initAmount
        self.invest = invest
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "rowid"
        case accountName = "account_name"
        case initAmount = "init_amount"
        case invest
    }
}

public struct Category: Codable, FetchableRecord, PersistableRecord, Identifiable {
    public var id: Int64?
    public var categoryName: String
    public var inOut: String // "in" or "out"
    public var parentCategory: Int64?
    
    public init(id: Int64? = nil, categoryName: String, inOut: String, parentCategory: Int64? = nil) {
        self.id = id
        self.categoryName = categoryName
        self.inOut = inOut
        self.parentCategory = parentCategory
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "rowid"
        case categoryName = "category_name"
        case inOut = "in_out"
        case parentCategory = "parent_category"
    }
}
