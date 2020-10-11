//
//  RectangleImage.swift
//  ImplementingInAppPurchases
//

import SwiftUI

struct RectangleImage: View {
    var image: Image
    
    var body: some View {
        image
        .clipShape(Rectangle())
        .overlay(Rectangle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
        
    }
}

struct RectangleImage_Previews: PreviewProvider {
    static var previews: some View {
        RectangleImage(image: ImageStore.shared.image(name: "catch-10110"))
    }
}
