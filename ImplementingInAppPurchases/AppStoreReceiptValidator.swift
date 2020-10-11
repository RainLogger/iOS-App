//
//  AppStoreReceiptValidator.swift
//  ImplementingInAppPurchases
//

import Foundation

struct AppStoreReceiptValidator {
    static func loadReceipt() -> Data? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL
            else { return nil }
        
        guard (try? receiptURL.checkResourceIsReachable()) != nil
            else { return nil }
        
        guard let receiptData = try? Data(contentsOf: receiptURL)
            else { return nil }
        
        return receiptData
    }
    
    static func validate(_ receiptData: Data, completion: @escaping (AppStoreValidationResult) -> Void = {_ in}) {
        //🧩 Prepare an HTTP Request and configure it to communicate with your server-side function URL
        var request = URLRequest(url: URL(string: "https://psiap.azurewebsites.net/api/ValidateAppStoreReceipt?code=HLHhx4bBrtXZPLJv/QpN4qygxWSRSmo6hAaHfza2fFacEEqnRUX5yw==")!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = receiptData.base64EncodedData()
        
        //🧩 Prepare a URLSession data task
        let task = URLSession.shared.dataTask(with: request){ (responseData, urlResponse, error) in
            
            guard let appStoreValidationResultJSON = responseData else { return }
            
            let decoder = JSONDecoder()
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            do {
                let validationResult = try decoder.decode(AppStoreValidationResult.self, from: appStoreValidationResultJSON)
                //🤔 How do you get the validation result back to the caller of the validate function?
                    //🧩 Design and call a completion closure ✅
                completion(validationResult)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        //🧩‼️ Resume the task!
        task.resume()
    }
}


// https://developer.apple.com/documentation/appstorereceipts/responsebody
struct AppStoreValidationResult: Decodable {
    let environment: String?
    let latestReceipt: String?
    let latestReceiptInfo: [InAppPurchaseTransaction]?
    let pendingRenewalInfo: [PendingRenewalInformation]?
    let receipt: Receipt
    let status: Int
    var statusDescription: ReceiptStatusDescription {
        get {
            return ReceiptStatusDescription(rawValue: self.status) ?? .unknown
        }
    }
}

// https://developer.apple.com/documentation/appstorereceipts/responsebody/receipt
struct Receipt: Decodable {
    let adamId: Double
    let appItemId: Double
    let applicationVersion: String
    let bundleId: String
    let downloadId: Int
    let expirationDate: Date?
    let expirationDateMs: String?
    let expirationDatePst: String?
    let inApp: [InAppPurchaseTransaction]
    let originalApplicationVersion: String
    let originalPurchaseDate: String
    let originalPurchaseDateMs: String
    let originalPurchaseDatePst: String
    let preorderDate: Date?
    let preorderDateMs: String?
    let preorderDatePst: Date?
    let receiptCreationDate: Date
    let receiptCreationDateMs: String
    let receiptCreationDatePst: Date
    let receiptType: String
    let requestDate: Date
    let requestDateMs: String
    let requestDatePst: Date
    let versionExternalIdentifier: Int
}

// https://developer.apple.com/documentation/appstorereceipts/responsebody/latest_receipt_info
struct InAppPurchaseTransaction: Decodable {
    let cancellationDate: Date?
    let cancellationDateMs: String?
    let cancellationDatePst: Date?
    let cancellationReason: String?
    let expiresDate: Date?
    let expiresDateMs: String?
    let expiresDatePst: Date?
    let isInIntroOfferPeriod: String?
    let isTrialPeriod: String?
    let originalPurchaseDate: Date
    let originalPurchaseDateMs: String
    let originalPurchaseDatePst: Date
    let originalTransactionId: String
    let productId: String
    let promotionalOfferId: String?
    let purchaseDate: Date
    let purchaseDateMs: String
    let purchaseDatePst: Date
    let quantity: String
    let transactionId: String
    let webOrderLineItemId: String?
}

// https://developer.apple.com/documentation/appstorereceipts/responsebody/pending_renewal_info
struct PendingRenewalInformation: Decodable {
    let autoRenewProductId: String?
    let autoRenewStatus: String
    let expirationIntent: String?
    let gracePeriodExpiresDate: Date?
    let gracePeriodExpiresDateMs: String?
    let gracePeriodExpiresDatePst: Date?
    let isInBillingRetryPeriod: String?
    let originalTransactionId: String
    let priceConsentStatus: String?
    let productId: String
}

// https://developer.apple.com/documentation/appstorereceipts/status
public enum ReceiptStatusDescription: Int {
    // valid status
    case valid = 0
    
    // The request to the App Store was not made using the HTTP POST request method.
    case appStoreRequestNotHTTPPost = 21000
    
    // The data in the receipt-data property was malformed or the service experienced a temporary issue.  Try again.
    case malformedOrMissingReceiptData = 21002
    
    // The receipt could not be authenticated.
    case receiptCouldNotBeAuthenticated = 21003
    
    // The shared secret you provided does not match the shared secret on file for your account.
    case sharedSecretDoesNotMatch = 21004
    
    // The receipt server was temporarily unable to provide the receipt. Try again.
    case receiptServerUnavailable = 21005
    
    // This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions.
    case iOS6StyleSubscriptionExpired = 21006 // Legacy
    
    // This receipt is from the test environment, but it was sent to the production environment for verification.
    case testReceiptSentToProduction = 21007
    
    // This receipt is from the production environment, but it was sent to the test environment for verification.
    case productionReceiptSentToTest = 21008
    
    // Internal data access error. Try again later.
    case internalDataAccessError = 21009
    
    // The user account cannot be found or has been deleted.
    case userAccountNotFoundOrDeleted = 21010
    
    case unknown
}
