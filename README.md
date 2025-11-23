# Ledger iOS App (記帳本應用程式)

這是一個使用 Swift 與 SwiftUI 開發的 iOS 記帳應用程式，採用模組化架構與 SQLite 資料庫。

## 專案大綱 (Project Outline)

本專案旨在開發一款個人財務管理 App，核心功能包含：
- **多帳戶管理**：支援現金、銀行帳戶、投資帳戶等。
- **預算控制**：可設定每月預算，並追蹤累積預算與實際支出的差異。
- **支出計畫**：預算底下可細分具體的支出計畫 (Plan)，精確管理資金流向。
- **收支記錄**：快速記錄收入與支出。
- **視覺化儀表板**：首頁提供當月收支概況、預算執行進度條。

專案採用 **Clean Architecture** 分層架構，將核心邏輯與資料層封裝於 `Core` 資料夾中，確保邏輯的可測試性與重用性。

## 如何啟動部署 (How to Start)

### 環境需求
- Xcode 14.0 或以上
- iOS 16.0 或以上
- Swift 5.9+

### 啟動步驟

#### 1. 設定專案
1. **開啟專案**：使用 Xcode 開啟 `ledger/ledger.xcodeproj`。
2. **加入 GRDB 套件**：
   - 在 Xcode 中，選擇專案設定 > `Package Dependencies`。
   - 點擊 `+` 新增套件：`https://github.com/groue/GRDB.swift.git`。
   - 將 `GRDB` 加入至 `ledger` target。
3. **加入初始資料**：
   - 確保 `database/init_data.sql` 已加入至專案的 `Resources` 群組中。
   - 確認該檔案在 Target Membership 中已勾選 `ledger`。

#### 2. 執行 App
1. **選擇模擬器**：在 Xcode 頂部工具列選擇一款模擬器 (例如 `iPhone 15 Pro`)。
2. **執行**：按下 `Cmd + R`。
3. **初始資料**：首次啟動時，App 會自動讀取 `init_data.sql` 並寫入資料庫。若您看到空白頁面，請嘗試切換月份至 **2026年1月** (預設資料日期)。

## 功能介紹 (Features)

### 1. 首頁 (Dashboard)
- **月份切換**：左右切換月份，查看不同月份的收支狀況。
- **收支概況**：頂部顯示當月總收入、總支出與結餘。
- **預算列表**：
  - 顯示各預算項目的累積預算與當月支出進度條。
  - 點擊預算卡片可展開查看底下的「支出計畫」詳情。

### 2. 明細頁 (Detail)
- **計畫詳情**：點擊首頁的支出計畫，進入明細頁查看交易紀錄。

### 3. 記帳功能 (Transaction)
- **新增支出**：輸入日期、金額、備註，選擇分類與計畫。
- **新增收入**：輸入日期、金額、備註，選擇存入帳戶。

## 開發規範與技術棧 (Development Standards & Tech Stack)

### 技術棧 (Tech Stack)
- **語言**：Swift
- **UI 框架**：SwiftUI
- **資料庫**：SQLite (透過 [GRDB.swift](https://github.com/groue/GRDB.swift) 套件)
- **架構**：
  - **Clean Architecture**：
    - `Domain Layer`: Entities, UseCases (純 Swift 邏輯)
    - `Data Layer`: Repositories, DTOs, Database (實作資料存取)
  - **MVVM**：View 與 ViewModel 綁定。

### 目錄結構
```
ledger/
  ledger/
    Core/               # 核心邏輯層
      Data/             # 資料層 (Database, Repositories, DTOs)
      Domain/           # 領域層 (Entities, UseCases)
    UI/                 # 視圖層 (Views, ViewModels)
    Resources/          # 資源檔 (init_data.sql)
    ledgerApp.swift     # App 入口點
```

### 開發規範 (Development Guidelines)
1. **註解**：所有 `public` 元件須加上繁體中文註解。
2. **非同步處理**：全面使用 Swift Concurrency (`async`/`await`)。
3. **資料庫存取**：必須透過 `UseCase` -> `Repository` -> `AppDatabase` 的路徑進行存取。

