//
//  BookDetail.swift
//  ImplementingInAppPurchases
//

import SwiftUI

struct BookDetail: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var storeManager: StoreManager
    
    var book: Book
    
    var bookIndex: Int {
        userData.books.firstIndex(where: { $0.id == book.id })!
    }
    
    //🧩 Track the content locked state
    @State private var isLocked = true
    
    //🧩 Track the state of whether or not the "insufficient book bucks" alert is showing
    @State private var isShowingInsufficientBookBucksAlert = false
    
    var body: some View {
        VStack {
            RectangleImage(image: book.image)
                .offset(y: 50)
                .padding(.bottom, 50)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(book.title)
                        .font(.title)
                    
                    Button(action: {
                        self.userData.books[self.bookIndex].isFavorite.toggle()
                    }) {
                        if self.userData.books[self.bookIndex].isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "star")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if self.isLocked {
                    //🧩 Show or hide based on whether the user is authorized to access book content
                    HStack {
                        if book.category == Book.Category.collection {
                            HStack {
                                Image(systemName: "book.circle")
                                Text(String(book.bookBuckCost))
                                Button("Redeem Now") {
                                    //🧩 Make sure the user has enough book bucks to redeem the book
                                    let currentOwnedBookBucksQuantity =
                                        self.storeManager.purchasedProductHandler.ownedBookBucks
                                    
                                    if currentOwnedBookBucksQuantity >= self.book.bookBuckCost {
                                        self.storeManager.purchasedProductHandler.describePurchases()
                                        
                                        //🧩 Subtract the cost of the book from the quantity of owned book bucks
                                        self.storeManager.purchasedProductHandler.ownedBookBucks -= self.book.bookBuckCost
                                        
                                        //🧩 Add the book id to the user's list of owned book ids
                                        self.storeManager.purchasedProductHandler.ownedBookIds += [self.book.id]
                                        
                                        //🧩 Unlock the book content
                                        self.isLocked.toggle()
                                        
                                        self.storeManager.purchasedProductHandler.describePurchases()
                                    } else {
                                        //🧩 Alert the user to buy more book bucks in order to redeem
                                        self.isShowingInsufficientBookBucksAlert.toggle()
                                    }
                                }
                            }
                        } else {
                            HStack {
                                Image(systemName: "repeat.1")
                                Text("Season pass required")
                            }
                        }
                        Spacer()
                    }
                }
                
                //🧩 Show or hide based on whether the user is authorized to access book content
                if self.isLocked == false {
                    BookContent()
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitle(Text(book.title), displayMode: .inline)
        //🧩 Enable the ability to show the user an alert prompting them to purchase more book bucks in order to redeem more books
        .alert(isPresented: self.$isShowingInsufficientBookBucksAlert) { () -> Alert in
            Alert(title: Text("Not Enough Book Bucks"), message: Text("You only have \(String(format: "%.1f", self.storeManager.purchasedProductHandler.ownedBookBucks)) book bucks. Purchase more in the store to redeem this title."), dismissButton: .default(Text("OK")))
        }
        //🧩 Set the initial state of whether or not the content is locked when the view appears
        .onAppear {
            //🧩 Without an active subscription or being a "Boundless Bibliophile", the user must own the book in order to unlock content in the "collection"
            if self.book.category == .collection {
                if self.storeManager.purchasedProductHandler.ownedBookIds.contains(where: { (bookId) -> Bool in
                    bookId == self.book.id
                }) {
                    self.isLocked = false
                } else {
                    self.isLocked = true
                }
            }
            
            //🧩 Without an active subscription or being a "Boundless Bibliophile", the user must have a season pass to unlock content in the "seasonal" library
            if self.book.category == .seasonal {
                if self.storeManager.purchasedProductHandler.isActiveSeason1Passholder {
                    self.isLocked = false
                } else {
                    self.isLocked = true
                }
            }
            //🧩 If the user is an active subscriber or is a "Boundless Bibliophile", he/she gets access to everything in the app, which includes all books in the "collection" and all seasonal titles (even if the season is no longer live!)
            if self.storeManager.purchasedProductHandler.isActiveSixMonthSubscriber ||
                self.storeManager.purchasedProductHandler.isActiveAnnualSubscriber ||
                self.storeManager.purchasedProductHandler.isBoundlessBibliophile {
                self.isLocked = false
            }
            
        }
    }
}

struct BookContent: View {
    var body: some View {
        ScrollView([.vertical], showsIndicators: true) {
            Text("""
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. In euismod lacus a porttitor elementum. Etiam quam mauris, maximus eu libero non, semper vestibulum sapien. Proin nec odio tellus. Pellentesque nec purus at ante sodales mattis. Nam viverra, dolor in rutrum congue, libero nunc pharetra sem, quis feugiat nibh turpis ut massa. Proin vehicula neque sed posuere finibus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;

            Quisque scelerisque blandit ultricies. Suspendisse potenti. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec vel mi et urna fringilla lacinia et sit amet dui. Quisque id pretium tellus. Integer porta lacus eu convallis gravida. Fusce finibus lacus nisl, in tincidunt eros vulputate a. Nam molestie ac nunc at varius. Maecenas laoreet sem in convallis pretium. Praesent iaculis, turpis ut ultrices rhoncus, augue mauris vehicula nulla, id feugiat lorem felis mattis mauris.

            Nullam dui elit, porta tempor porta at, venenatis quis felis. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Cras pulvinar sollicitudin porttitor. Sed sodales, metus laoreet maximus imperdiet, elit nibh auctor tellus, sit amet tempus risus justo at lacus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Curabitur elementum nulla at porta volutpat. Mauris dui dolor, porta at interdum semper, pretium vel mauris. Vivamus varius tellus in justo suscipit varius. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Etiam consectetur ornare ligula ut tempus. Nam posuere purus sit amet elit dignissim dapibus.

            Quisque condimentum nisl eu viverra porta. Praesent odio metus, finibus a sapien id, placerat cursus enim. Nullam ex nisl, ultrices et congue vitae, elementum accumsan tortor. Etiam lacinia porta nibh quis porta. Etiam tincidunt felis metus, vitae pellentesque nunc faucibus eu. Vestibulum vitae urna scelerisque dui efficitur consequat sed et urna. Nunc quis nulla ut velit porttitor molestie eget id felis. Proin pellentesque, sem ultrices imperdiet consequat, massa eros elementum nulla, at porta ante tellus vitae elit. Nunc commodo commodo dui vel commodo.

            Suspendisse condimentum, est nec facilisis ornare, eros velit maximus nisl, vitae lacinia nulla nisi vitae quam. Fusce efficitur urna vel semper placerat. Suspendisse sit amet ante a lacus malesuada commodo. Morbi turpis nibh, malesuada ac placerat in, bibendum sit amet tellus. Praesent varius est et velit suscipit tempor. Nunc a consequat enim, vitae rutrum ligula. Cras vel lectus mollis, luctus leo eget, lacinia ligula. Nullam condimentum pellentesque convallis. Cras nisi leo, sodales id cursus in, pellentesque sed purus. Aenean massa diam, rhoncus vel lobortis id, ultrices in mauris. In ut feugiat magna. Etiam at aliquam dolor. Praesent eget libero odio.
            """)
        }
    }
}
struct BookDetail_Previews: PreviewProvider {
    static var previews: some View {
        BookDetail(book: bookData[2])
        .environmentObject(UserData())
    }
}
