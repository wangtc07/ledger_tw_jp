import SwiftUI

struct CategorySelectionView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.presentationMode) var presentationMode
    
    // 根分類：parentCategory 為 nil 的分類
    // Root categories: Categories where parentCategory is nil
    var rootCategories: [Category] {
        categories.filter { $0.parentCategory == nil }
    }
    
    var body: some View {
        List {
            // 從根分類開始遞迴顯示
            // Start recursive display from root categories
            ForEach(rootCategories) { category in
                CategoryNodeView(category: category, allCategories: categories, selectedCategory: $selectedCategory)
            }
        }
        .navigationTitle("選擇分類")
        .onChange(of: selectedCategory) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CategoryNodeView: View {
    let category: Category
    let allCategories: [Category]
    @Binding var selectedCategory: Category?
    
    // 尋找子分類：在所有分類中，找出 parentCategory 等於目前分類 ID 的項目
    // Find children: Filter all categories where parentCategory equals current category ID
    var children: [Category] {
        allCategories.filter { $0.parentCategory == category.id }
    }
    
    var isSelected: Bool {
        selectedCategory?.id == category.id
    }
    
    var body: some View {
        if children.isEmpty {
            // Leaf node: Just a button to select
            Button(action: {
                selectSelf()
            }) {
                HStack {
                    Text(category.categoryName)
                        .foregroundColor(.primary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        } else {
            // 父節點：使用 DisclosureGroup 顯示展開/收合效果
            // Parent node: Use DisclosureGroup for expand/collapse effect
            DisclosureGroup(
                content: {
                    // 遞迴呼叫：顯示所有子分類
                    // Recursive call: Display all children
                    ForEach(children) { child in
                        CategoryNodeView(category: child, allCategories: allCategories, selectedCategory: $selectedCategory)
                    }
                },
                label: {
                    HStack {
                        Text(category.categoryName)
                            .foregroundColor(.primary)
                            .onTapGesture {
                                selectSelf()
                            }
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            )
        }
    }
    
    private func selectSelf() {
        selectedCategory = category
    }
}
