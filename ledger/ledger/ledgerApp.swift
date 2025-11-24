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
                let count = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM account") ?? 0
                print("[ledgerApp] Account count: \(count)")
                
                if count == 0 {
                    print("[ledgerApp] Database is empty. Attempting to seed data from init_data.sql...")
                    if let sqlPath = Bundle.main.path(forResource: "init_data", ofType: "sql") {
                        print("[ledgerApp] Found init_data.sql at: \(sqlPath)")
                        let sql = try String(contentsOfFile: sqlPath, encoding: .utf8)
                        try db.execute(sql: sql)
                        print("[ledgerApp] Data seeding completed successfully.")
                    } else {
                        print("[ledgerApp] Warning: init_data.sql not found in Bundle.")
                    }
                } else {
                    print("[ledgerApp] Database already has data. Skipping seeding.")
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
