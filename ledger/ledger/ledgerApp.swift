//
//  ledgerApp.swift
//  ledger
//
//  Created by ジェ on 2025/11/23.
//

import SwiftUI
import GRDB

@main
struct ledgerApp: App {
    let appDatabase: AppDatabase
    
    init() {
        do {
            // 取得 App 的文件目錄路徑
            let documentsPath = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // 設定資料庫檔案路徑
            let dbPath = documentsPath.appendingPathComponent("db.sqlite").path
            // 建立資料庫連線佇列
            let dbQueue = try DatabaseQueue(path: dbPath)
            // 初始化 AppDatabase (包含遷移)
            self.appDatabase = try AppDatabase(dbQueue)
            
            // Seed data if empty
            try appDatabase.dbWriter.write { db in
                if try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM account") == 0 {
                    if let sqlPath = Bundle.main.path(forResource: "init_data", ofType: "sql") {
                        let sql = try String(contentsOfFile: sqlPath, encoding: .utf8)
                        try db.execute(sql: sql)
                    } else {
                        print("Warning: init_data.sql not found in Bundle")
                    }
                }
            }
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // 注入 ViewModel 與 UseCase
            HomeView(viewModel: HomeViewModel(
                homeUseCase: HomeUseCase(
                    budgetRepo: BudgetRepository(dbWriter: appDatabase.dbWriter)
                )
            ))
            .environment(\.appDatabase, appDatabase)
        }
    }
}
