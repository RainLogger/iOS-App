//
//  Home.swift
//  ImplementingInAppPurchases
//


import SwiftUI

struct Home: View {
    var categories: [String: [Book]] {
        Dictionary(grouping: bookData, by: { $0.category.rawValue })
    }
    
    
    var featured: [Book] {
        bookData.filter {
            $0.isFeatured
        }
    }
    
    @State var showingStore = false
    
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var storeManager: StoreManager
    
    var profileButton: some View {
        Button(action: {
            self.showingStore.toggle()
        }) {
            Image(systemName: "bag")
                .imageScale(.large)
                .foregroundColor(.secondary)
            .accessibility(label: Text("Store"))
            .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                PageView(featuredBooks.map { FeatureCard(book: $0) })
                    .aspectRatio(3/2, contentMode: .fit)
                    .listRowInsets(EdgeInsets())
                
                ForEach(categories.keys.sorted(), id: \.self) { key in
                    CategoryRow(categoryName: key, items: self.categories[key]!)
                }
                .listRowInsets(EdgeInsets())
            }
            .navigationBarTitle("Featured")
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingStore) {
                Store().environmentObject(self.storeManager)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
        .environmentObject(UserData())
    }
}
