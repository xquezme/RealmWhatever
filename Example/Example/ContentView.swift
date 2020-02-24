//
//  ContentView.swift
//  Example
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import RealmSwift
import RealmWhatever
import SwiftUI

struct ContentView: View {
    @ObservedObject var dogOwners: CombineQueryObservableObject<DogOwnerFactory>

    var body: some View {
        NavigationView {
            List(self.dogOwners.objects) { dogOwner in
                Text("\(dogOwner.name) (\(dogOwner.dogs.first!.name))")
            }
            .navigationBarItems(trailing:
                Button("Add") {
                    let realm = try! Realm()

                    try! realm.write {
                        let doggo = RLMDog()
                        doggo.uuid = UUID().uuidString
                        doggo.name = ["Doggo", "Doge", "Dog"].randomElement()!

                        let doggoOwner = RLMDogOwner()
                        doggoOwner.uuid = UUID().uuidString
                        doggoOwner.name = ["Sergey", "Sergei", "Sergio"].randomElement()!
                        doggoOwner.doggos.append(doggo)

                        realm.add(doggoOwner, update: .all)
                    }
            })
        }
    }
}
