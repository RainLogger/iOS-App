//
//  SKProductExtensions.swift
//  ImplementingInAppPurchases
//

import Foundation
import StoreKit

//🧩 Extend SKProduct to include a formattedPrice variable
extension SKProduct {
    var formattedPrice: String {
        get {
            //🧩 Create a NumberFormatter
            let numberFormatter = NumberFormatter()
            
            //🧩 Set the price locale and number style
            numberFormatter.locale = self.priceLocale
            numberFormatter.numberStyle = .currency
            
            return numberFormatter.string(from: self.price) ?? ""
        }
    }
}
