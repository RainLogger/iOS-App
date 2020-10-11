//
//  Store.swift
//  ImplementingInAppPurchases
//

import SwiftUI

struct Store: View {
    
    //🧩 Get an instance of StoreManager for use within the Store View
    //💡 Use the SwiftUI Environment
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        VStack {
            HStack {
                Text("Store")
                    .bold()
                    .font(.title)
                    .padding(.top)
                    .padding(.leading)
                
                Spacer()
            }
            
            Divider()
            
            if self.storeManager.TenBookBucksProduct != nil {
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "book.circle")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text(self.storeManager.TenBookBucksProduct!.localizedTitle)
                            Text(self.storeManager.TenBookBucksProduct!.localizedDescription).font(.caption)
                            Text(self.storeManager.TenBookBucksProduct!.formattedPrice)
                        }
                        
                        Spacer()
                        
                        if self.storeManager.canMakePayments() {
                            Button("Buy") {
                                self.storeManager.buyProduct(self.storeManager.TenBookBucksProduct!)
                            }
                        } else {
                            Text("Not Available")
                        }
                        
                    }
                }
                .padding(.all)
            } else {
                Text("The 10 Book Bucks product is currently unavailable.")
            }
            
            if self.storeManager.SeasonOnePassProduct != nil {
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text(self.storeManager.SeasonOnePassProduct!.localizedTitle)
                            Text(self.storeManager.SeasonOnePassProduct!.localizedDescription).font(.caption)
                            Text(self.storeManager.SeasonOnePassProduct!.formattedPrice)
                        }
                        
                        Spacer()
                        
                        if self.storeManager.canMakePayments() {
                            if self.storeManager.purchasedProductHandler.isActiveSeason1Passholder &&
                                self.storeManager.purchasedProductHandler.seasonIsLive {
                                Image(systemName: "checkmark")
                            } else if self.storeManager.purchasedProductHandler.seasonIsLive == false {
                                Text("Unavailable")
                            } else {
                                Button("Buy") {
                                    self.storeManager.buyProduct(self.storeManager.SeasonOnePassProduct!)
                                }
                            }
                        } else {
                            Text("Not Available")
                        }
                        
                    }
                }
                .padding(.all)
            } else {
                Text("The Season 1 Pass product is currently unavailable.")
            }
            
            if self.storeManager.SixMonthSubscriptionProduct != nil {
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "repeat")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text(self.storeManager.SixMonthSubscriptionProduct!.localizedTitle)
                            Text(self.storeManager.SixMonthSubscriptionProduct!.localizedDescription).font(.caption)
                            Text(self.storeManager.SixMonthSubscriptionProduct!.formattedPrice)
                        }
                        
                        Spacer()
                        
                        if self.storeManager.canMakePayments() {
                            if self.storeManager.purchasedProductHandler.isActiveSixMonthSubscriber {
                                Image(systemName: "checkmark")
                            } else {
                                Button("Buy") {
                                    self.storeManager.buyProduct(self.storeManager.SixMonthSubscriptionProduct!)
                                }
                            }
                        } else {
                            Text("Not Available")
                        }
                        
                    }
                }
                .padding(.all)
            } else {
                Text("The 6 Month Subscription product is currently unavailable.")
            }
            
            if self.storeManager.AnnualSubscriptionProduct != nil {
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "repeat.1")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text(self.storeManager.AnnualSubscriptionProduct!.localizedTitle)
                            Text(self.storeManager.AnnualSubscriptionProduct!.localizedDescription).font(.caption)
                            Text(self.storeManager.AnnualSubscriptionProduct!.formattedPrice)
                        }
                        
                        Spacer()
                        
                        if self.storeManager.canMakePayments() {
                            if self.storeManager.purchasedProductHandler.isActiveAnnualSubscriber {
                                Image(systemName: "checkmark")
                            } else {
                                Button("Buy") {
                                    self.storeManager.buyProduct(self.storeManager.AnnualSubscriptionProduct!)
                                }
                            }
                        } else {
                            Text("Not Available")
                        }
                        
                    }
                }
                .padding(.all)
            } else {
                Text("The Annual Subscription product is currently unavailable.")
            }
            
            if self.storeManager.BoundlessBibliophileProduct != nil {
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "leaf.arrow.circlepath")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text(self.storeManager.BoundlessBibliophileProduct!.localizedTitle)
                            Text(self.storeManager.BoundlessBibliophileProduct!.localizedDescription).font(.caption)
                            Text(self.storeManager.BoundlessBibliophileProduct!.formattedPrice)
                        }
                        
                        Spacer()
                        
                        if self.storeManager.canMakePayments() {
                            if self.storeManager.purchasedProductHandler.isBoundlessBibliophile {
                                Image(systemName: "checkmark")
                            } else {
                                Button("Buy") {
                                    self.storeManager.buyProduct(self.storeManager.BoundlessBibliophileProduct!)
                                }
                            }
                        } else {
                            Text("Not Available")
                        }
                        
                    }
                }
                .padding(.all)
            } else {
                Text("The Boundless Bibliophile product is currently unavailable.")
            }
            
            
            Divider()
            
            VStack {
                Button("Restore Purchases") {
                    self.storeManager.restorePurchases()
                }
                .padding(.top)
            }
            Spacer()
        }
    }
}

struct Store_Previews: PreviewProvider {
    static var previews: some View {
        Store()
    }
}
