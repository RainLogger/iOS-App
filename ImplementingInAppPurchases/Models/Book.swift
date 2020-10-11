//
//  Book.swift
//  ImplementingInAppPurchases
//

import SwiftUI

struct Book: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    fileprivate var imageName: String
    var bookBuckCost: Double
    var category: Category
    var isFeatured: Bool
    var isFavorite: Bool

    var featureImage: Image? {
        guard isFeatured else { return nil}
        
        return Image(
            ImageStore.loadImage(name: "\(imageName)_feature"),
            scale: 2,
            label: Text(verbatim: title))
    }
    
    enum Category: String, CaseIterable, Codable, Hashable {
        case collection = "Collection"
        case seasonal = "Seasonal"
    }
}

extension Book {
    var image: Image {
        ImageStore.shared.image(name: imageName)
    }
}
