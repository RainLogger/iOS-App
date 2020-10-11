//
//  StoreManager.swift
//  ImplementingInAppPurchases
//

import Foundation
import StoreKit

let SixMonthSubscriptionProductId = "com.pluralsight.6monthsubscription"
let TenBookBucksProductId = "com.pluralsight.10bookbucks"
let AnnualSubscriptionProductId = "com.pluralsight.annualsubscription"
let BoundlessBibliophileProductId = "com.pluralsight.boundlessbibliophile"
let SeasonOnePassProductId = "com.pluralsight.season1pass"

//🧩 Make StoreManager an ObservableObject to support SwiftUI
class StoreManager: NSObject, ObservableObject {
    var productsRequest = SKProductsRequest(productIdentifiers: Set([
    SixMonthSubscriptionProductId,
    TenBookBucksProductId,
    AnnualSubscriptionProductId,
    BoundlessBibliophileProductId,
    SeasonOnePassProductId
    ]))
    
    var SixMonthSubscriptionProduct: SKProduct?
    var TenBookBucksProduct: SKProduct?
    var AnnualSubscriptionProduct: SKProduct?
    var BoundlessBibliophileProduct: SKProduct?
    var SeasonOnePassProduct: SKProduct?
    
    let receiptRequestor = ReceiptRequestor()
    let purchasedProductHandler = PurchasedProductHandler()
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func getProducts() {
        self.productsRequest.delegate = self
        self.productsRequest.start()
    }
    
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        //🤔 How do you know if the payment succeeded?
        //ℹ️ SKPaymentTransactionObserver
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        self.SixMonthSubscriptionProduct = products.first { (product) -> Bool in
            product.productIdentifier == SixMonthSubscriptionProductId
        }
        
        self.TenBookBucksProduct = products.first(where: { (product) -> Bool in
            product.productIdentifier == TenBookBucksProductId
        })
        
        self.AnnualSubscriptionProduct = products.first(where: { (product) -> Bool in
            product.productIdentifier == AnnualSubscriptionProductId
        })
        
        self.BoundlessBibliophileProduct = products.first(where: { (product) -> Bool in
            product.productIdentifier == BoundlessBibliophileProductId
        })
        
        self.SeasonOnePassProduct = products.first(where: { (product) -> Bool in
            product.productIdentifier == SeasonOnePassProductId
        })
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // ℹ️ Use for development-time troubleshooting
        print(error.localizedDescription)
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //🧩 Loop over the transactions
        for transaction in transactions {
            //🧩 Look at the state of each transaction
            switch transaction.transactionState {
            case .purchased, .restored:
                //🧩 Validate the receipt
                if let receiptData = AppStoreReceiptValidator.loadReceipt() {
                    AppStoreReceiptValidator.validate(receiptData) {
                        validationResult in

                        //🧩 Unlock the purchased content
                        if validationResult.statusDescription == .valid {
                            self.purchasedProductHandler.describePurchases()
                            
                            self.purchasedProductHandler.handle(transaction.payment.productIdentifier, with: validationResult)
                            
                            self.purchasedProductHandler.describePurchases()
                        }
                    }
                } else {
                    self.receiptRequestor.start {
                        if let receiptData = AppStoreReceiptValidator.loadReceipt() {
                            AppStoreReceiptValidator.validate(receiptData) {
                                validationResult in
                                print(validationResult)
                                //🧩 Unlock the purchased content
                            }
                        }
                    }
                }
                //🧩 Finish the transaction (always!)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                //🧩 Log the error
                print("Error: \(String(describing: transaction.error?.localizedDescription))")
                //🧩 Finish the transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    
}
