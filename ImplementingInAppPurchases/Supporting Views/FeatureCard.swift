//
//  FeatureCard.swift
//  ImplementingInAppPurchases
//

import SwiftUI

struct FeatureCard: View {
    var book: Book
    
    var body: some View {
        book.featureImage?
            .resizable()
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay(TextOverlay(book: book))
    }
}

struct TextOverlay: View {
    var book: Book
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.title)
                    .bold()
                if book.category == Book.Category.collection {
                    HStack {
                        Image(systemName: "book.circle")
                        Text(String(book.bookBuckCost))
                    }
                } else {
                    HStack {
                        Image(systemName: "repeat.1")
                    }
                }
            }
            .padding()
        }
        .foregroundColor(.white)
    }
}

struct FeatureCard_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCard(book: featuredBooks[0])
    }
}
