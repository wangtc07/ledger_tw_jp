import SwiftUI

/// 定義 AppDatabase 的環境鍵 (EnvironmentKey)
/// 這是 SwiftUI 依賴注入的一種方式，讓子視圖可以存取資料庫
struct AppDatabaseKey: EnvironmentKey {
    static let defaultValue: AppDatabase? = nil
}

extension EnvironmentValues {
    /// 提供方便的存取屬性，讓 View 可以透過 @Environment(\.appDatabase) 取得
    public var appDatabase: AppDatabase? {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}
