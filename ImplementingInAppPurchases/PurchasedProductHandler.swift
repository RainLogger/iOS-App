//
//  PurchasedProductHandler.swift
//  ImplementingInAppPurchases
//

import Foundation

//🗺 Strategy Map
//  This class will launch its handling capability through a primary "handle" function. It will look at the Product Identifier being passed in from the caller (the Store Manager that just got notified that a payment transaction just came through) and persist the state of the purchase securely to the iOS Keychain on the user's local device.
class PurchasedProductHandler {
    // MARK: Primary Handle Function
    //🧩 Make a function that can take in a product identifier and an App Store Validation Result and persist the state of the purchase for future reference throughout the app
    func handle(_ purchasedProductIdentifier: String, with validationResult: AppStoreValidationResult) {
        // MARK: Book Bucks
        //🧩 If the product being handled is the book bucks product, increment the number of owned book bucks by 10
        if purchasedProductIdentifier == TenBookBucksProductId &&
            validationResult.receipt.inApp.contains(where: {
                (iapTransaction) -> Bool in
                iapTransaction.productId == TenBookBucksProductId
            }) {
            self.ownedBookBucks += 10
        }
        
        // MARK: Season 1 Pass
        //🧩 If the product being handled is the season 1 pass, save the purchase record of the user's season 1 pass
        if purchasedProductIdentifier == SeasonOnePassProductId &&
            validationResult.receipt.inApp.contains(where: { (iapTransaction) -> Bool in
                iapTransaction.productId == SeasonOnePassProductId
            }) {
            self.isActiveSeason1Passholder = true
        }
        
        // MARK: Six Month Subscription
        //🧩 If the product being handled is the Six Month Subscription, save the purchase record of the user's Six Month Subscription
        if purchasedProductIdentifier == SixMonthSubscriptionProductId {
            //🧩 Use the LATEST receipt
            //🧩 Filter out any cancelled subscriptions
            //🧩 Sort the remaining items in the latest receipt by subscription expiration date
            let latestSixMonthSubscriptionTransaction = validationResult.latestReceiptInfo?.filter({ (iapTransaction) -> Bool in
                iapTransaction.cancellationDate == nil &&
                iapTransaction.expiresDate != nil &&
                iapTransaction.productId == SixMonthSubscriptionProductId
            }).sorted(by: { (firstTransaction, secondTransaction) -> Bool in
                firstTransaction.expiresDate! > secondTransaction.expiresDate!
                }).first
            
            //🧩 As long as the expiration date is after today, the subscription is active
            if let expirationDate = latestSixMonthSubscriptionTransaction?.expiresDate {
                self.isActiveSixMonthSubscriber = expirationDate > Date()
            } else {
                self.isActiveSixMonthSubscriber = false
            }
        }
        
        // MARK: Annual Subscription
        //🧩 If the product being handled is the Annual Subscription, save the purchase record of the user's Annual Subscription
        if purchasedProductIdentifier == AnnualSubscriptionProductId {
            // ℹ️ This is the same as the Six Month Subscription, just with changed variable
            // names. In other words, it's a candidate for refactoring... someday! 😃
            let latestAnnualSubscriptionTransaction = validationResult.latestReceiptInfo?.filter({ (iapTransaction) -> Bool in
                iapTransaction.productId == AnnualSubscriptionProductId &&
                    iapTransaction.cancellationDate == nil &&
                    iapTransaction.expiresDate != nil
            }).sorted(by: { (firstTransaction, secondTransaction) -> Bool in
                firstTransaction.expiresDate! > secondTransaction.expiresDate!
                }).first
            
            //🧩 As long as the expiration date is after today, the subscription is active
            if let expirationDate = latestAnnualSubscriptionTransaction?.expiresDate {
                self.isActiveAnnualSubscriber = expirationDate > Date()
            } else {
                self.isActiveAnnualSubscriber = false
            }
        }
        
        // MARK: Boundless Bibliophile
        //🧩 If the product being handled is the Boundless Bibliophile, save the purchase record of the user's Boundless Bibliophile lifetime membership
        if purchasedProductIdentifier == BoundlessBibliophileProductId {
            if validationResult.receipt.inApp.contains(where: { (iapTransaction) -> Bool in
                iapTransaction.productId == BoundlessBibliophileProductId
            }) {
                self.isBoundlessBibliophile = true
            }
        }
    }
    
    // MARK: iCloud Sync
    func updateFromiCloud() {
        let latestOwnedBookBucks = NSUbiquitousKeyValueStore.default.double(forKey: ownedBookBucksKey)
        let latestOwnedBookIds = NSUbiquitousKeyValueStore.default.array(forKey: ownedBookIdsKey) as! [Int]
        let latestActiveSeason1PassholderStatus = NSUbiquitousKeyValueStore.default.bool(forKey: activeSeason1PassholderKey)
        
        self.ownedBookBucks = latestOwnedBookBucks
        self.ownedBookIds = latestOwnedBookIds
        self.isActiveSeason1Passholder = latestActiveSeason1PassholderStatus
    }
    
    // MARK: Keychain
    //ℹ️ The iOS keychain was designed to store things like passwords and certificates, so repurposing it to store product purchase state values instead of "server" names and "account" names will appear odd on the surface
    //💡 Embrace the awkward, and value the fact that you can store these bits of information in an encrypted storage area, thereby increasing the security of your In-App Purchase implementation
    fileprivate let keychainAppIdentifier = "com.pluralsight.ImplementingInAppPurchases"
    
    fileprivate let ownedBookBucksKey = "com.pluralsight.ownedBookBucks"
    fileprivate let ownedBookIdsKey = "com.pluralsight.ownedBookIds"
    fileprivate let activeSeason1PassholderKey = "com.pluralsight.activeSeason1Passholder"
    fileprivate let activeSixMothSubscriberKey = "com.pluralsight.activeSixMonthSubscriber"
    fileprivate let activeAnnualSubscriberKey = "com.pluralsight.activeAnnualSubscriber"
    fileprivate let boundlessBibliophileKey = "com.pluralsight.boundlessBibliophile"
    
    func getValue(forKey keychainItemKey: String) -> String? {
        //🧩 Create a query to find the keychain item
        let searchQuery: [String:Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: keychainAppIdentifier,
            kSecAttrAccount as String: keychainItemKey,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        //🧩 Copy the item out of the keychain
        var keychainItem: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &keychainItem)
        
        //🧩 If the keychain item exists, decode the data value for the keychain item into a String
        guard status != errSecItemNotFound,
            let item = keychainItem as? [String:Any],
            let data = item[kSecValueData as String] as? Data,
            let stringValue = String(data: data, encoding: .utf8)
            else { return nil }
        
        return stringValue
    }
    
    func save(_ value: String, forKey keychainItemKey: String) {
        //🧩 Check to see if the keychain item exists. If it does, update it. Otherwise, add a keychain item for the keychainItemKey.
        if getValue(forKey: keychainItemKey) != nil {
            //🧩 Update existing keychain item
            
            //🧩 Convert the value to "data" using UTF-8 encoding
            if let encodedValue = value.data(using: .utf8) {
                //ℹ️ Updating an existing value in the keychain requires two queries: One to find the keychain item, and one to update the values
                
                //🧩 Create a query to find the keychain item for updating
                let existingItemQuery: [String:Any] = [
                    kSecClass as String: kSecClassInternetPassword,
                    kSecAttrAccount as String: keychainItemKey,
                    kSecAttrServer as String: keychainAppIdentifier
                ]
                
                //🧩 Create a query that expresses the intention to update the value for the item
                let updateItemQuery: [String:Any] = [kSecValueData as String: encodedValue]
                
                //🧩 Initiate the update to the keychain
                SecItemUpdate(existingItemQuery as CFDictionary, updateItemQuery as CFDictionary)
            }
        } else {
            //🧩 Add new keychain item
            //🧩 Convert the value to "data" using UTF-8 encoding
            if let encodedValue = value.data(using: .utf8) {
                //🧩 Create a query to add a keychain item for the first time
                let addItemQuery: [String:Any] = [
                    kSecClass as String: kSecClassInternetPassword,
                    kSecAttrAccount as String: keychainItemKey,
                    kSecAttrServer as String: keychainAppIdentifier,
                    kSecValueData as String: encodedValue
                ]
                
                //🧩 Initiate adding the item to the keychain
                SecItemAdd(addItemQuery as CFDictionary, nil)
            }
        }
    }
    
    // MARK: Product Purchase State
    var ownedBookBucks: Double {
        get {
            //🧩 Make sure the keychain item exists
            guard let currentBookBucksQuantityString =
                getValue(forKey: ownedBookBucksKey) else { return 0 }
            
            //🧩 Convert it to a Double and return
            guard let currentBookBucksQuantity = Double(currentBookBucksQuantityString) else { return 0 }
            
            return currentBookBucksQuantity
        }
        
        set {
            save(String(newValue), forKey: ownedBookBucksKey)
            
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: ownedBookBucksKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
    
    var ownedBookIds: [Int] {
        get {
            //🧩 Make sure the keychain item exists
            guard let ownedBookIdsString = getValue(forKey: ownedBookIdsKey) else {
                return []
            }
            
            //🧩 Convert it into an array of Ints and return
            let ownedBookIds = ownedBookIdsString.components(separatedBy: ",").compactMap {
                bookId in
                return Int(bookId)
            }
            return ownedBookIds
        }
        
        set {
            //🧩 Convert the array of Ints into a comma-separated String
            let ownedBookIdsString = newValue.compactMap {
                bookId in
                return String(bookId)
            }.joined(separator: ",")
            
            save(ownedBookIdsString, forKey: ownedBookIdsKey)
            
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: ownedBookIdsKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
    
    // ℹ️ Logic for non-renewing subscriptions is likely to be very different across applications.  You're in full control of what happens - you get to decide the "active" period for the product on your own.
    var isActiveSeason1Passholder: Bool {
        get {
            //🧩 The season must be "live" for the user to be an active passholder
            guard seasonIsLive else {
                self.isActiveSeason1Passholder = false
                return false
            }
            
            //🧩 Make sure the keychain item exists
            guard let activeSeason1PassholderString = getValue(forKey: activeSeason1PassholderKey)
                else { return false }
            
            //🧩 Convert it to a Bool and return
            guard let isActiveSeason1Passholder = Bool(activeSeason1PassholderString)
                else { return false }
            
            return isActiveSeason1Passholder
        }
        
        set {
            save(String(newValue), forKey: activeSeason1PassholderKey)
            
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: activeSeason1PassholderKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
    
    var seasonIsLive: Bool {
        get {
            // ℹ️ A "Season" of content for THIS app is valid from March 14 thru June 28 (math nerds, you know what I'm tauin' about 🤓)
            
            //🧩 Create the appropriate date formatter to turn strings into date objects
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let seasonStartDateString = "2020-03-14"
            let seasonStartDate = dateFormatter.date(from: seasonStartDateString)!
            
            let seasonEndDateString = "2020-06-28"
            let seasonEndDate = dateFormatter.date(from: seasonEndDateString)!
            
            let today = Date()
            
            //🧩 Create a range of dates encompassing the season start and end date
            //🧩 Check to see if that range contains today's date
            
            let isLive = (seasonStartDate...seasonEndDate).contains(today)
            
            return isLive
        }
    }
    
    var isActiveSixMonthSubscriber: Bool {
        get {
            //🧩 Make sure the keychain item exists
            guard let activeSixMonthSubscriberString = getValue(forKey: activeSixMothSubscriberKey) else { return false }
            
            //🧩 Convert it to a Bool and return
            guard let isActiveSubscriber = Bool(activeSixMonthSubscriberString) else { return false }
            
            return isActiveSubscriber
        }
        
        set {
            save(String(newValue), forKey: activeSixMothSubscriberKey)
        }
    }
    
    var isActiveAnnualSubscriber: Bool {
        get {
            //🧩 Make sure the keychain item exists
            guard let activeAnnualSubscriberString = getValue(forKey: activeAnnualSubscriberKey) else { return false }
            
            //🧩 Convert it to a Bool and return
            guard let isActiveSubscriber = Bool(activeAnnualSubscriberString) else { return false }
            
            return isActiveSubscriber
        }
        
        set {
            save(String(newValue), forKey: activeAnnualSubscriberKey)
        }
    }
    
    var isBoundlessBibliophile: Bool {
        get {
            //🧩 Make sure the keychain item exists
            guard let boundlessBibliophileString = getValue(forKey: boundlessBibliophileKey) else { return false }
            
            //🧩 Convert it to a Bool and return
            guard let isBoundlessBibliophile = Bool(boundlessBibliophileString) else { return false }

            return isBoundlessBibliophile
        }
        
        set {
            save(String(newValue), forKey: boundlessBibliophileKey)
        }
    }
}

// MARK: Testing Conveniences
//💡 Could be convenient for testing to have a way to see the values of all the products in the keychain as they are [right now]
extension PurchasedProductHandler {
    func describePurchases() {
        print("ownedBookBucks: \(self.ownedBookBucks)")
        print("ownedBookIds: \(self.ownedBookIds)")
        print("isActiveSeason1Passholder: \(self.isActiveSeason1Passholder)")
        print("isActiveSixMonthSubscriber: \(self.isActiveSixMonthSubscriber)")
        print("isActiveAnnualSubscriber: \(self.isActiveAnnualSubscriber)")
        print("isBoundlessBibliophile: \(self.isBoundlessBibliophile)")
    }
}
