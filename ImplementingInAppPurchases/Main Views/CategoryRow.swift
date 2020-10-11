//
//  CategoryRow.swift
//  ImplementingInAppPurchases
//


import SwiftUI

struct CategoryRow: View {
    var categoryName: String
    var items: [Book]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
                
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(self.items) { book in
                        NavigationLink(destination: BookDetail(book: book)) {
                            CategoryItem(book: book)
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

struct CategoryItem: View {
    var book: Book
    
    var body: some View {
        VStack(alignment: .center) {
            book.image
            .renderingMode(.original)
            .resizable()
            .frame(width: 155, height: 155)
            .cornerRadius(5)
            
            Text(book.title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.leading, 15)
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(categoryName: bookData[0].category.rawValue, items: Array(bookData.prefix(4)))
    }
}
