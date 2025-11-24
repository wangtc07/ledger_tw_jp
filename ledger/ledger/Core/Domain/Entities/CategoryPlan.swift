import GRDB
import Foundation

/// 類別與計畫的關聯表 (Category-Plan Mapping)
/// 用於在選擇類別時自動帶入對應的計畫
public struct CategoryPlan: Codable, FetchableRecord, PersistableRecord {
    public static var databaseTableName = "category_plan"
    
    /// 類別 ID
    public var category: Int64
    /// 計畫 ID
    public var plan: Int64
    
    public init(category: Int64, plan: Int64) {
        self.category = category
        self.plan = plan
    }
    
    enum CodingKeys: String, CodingKey {
        case category
        case plan
    }
}
