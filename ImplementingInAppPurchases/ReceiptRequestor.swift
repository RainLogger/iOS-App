//
//  ReceiptRequestor.swift
//  ImplementingInAppPurchases
//
import Foundation
import StoreKit

class ReceiptRequestor: NSObject, SKRequestDelegate {
    let receiptRequest = SKReceiptRefreshRequest()
    var completion: () -> Void = {}
    
    override init() {
        super.init()
        self.receiptRequest.delegate = self
    }
    
    func start(completion: @escaping () -> Void = {}) {
        self.receiptRequest.start()
        self.completion = completion
    }
    
    func requestDidFinish(_ request: SKRequest) {
        self.completion()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
