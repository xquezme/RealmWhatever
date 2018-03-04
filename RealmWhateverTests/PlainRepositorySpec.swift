//
//  PlainRepositorySpec.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Quick
import Nimble
@testable import RealmWhatever
import RealmSwift
import RxSwift

class PlainRepositorySpec: QuickSpec {
    override func spec() {
        describe("Plain Repository") {
            let uuid = UUID()
            let repository = UserRepository()

            beforeEach {
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                    let user = RLMUser()
                    user.uuid = uuid.uuidString
                    realm.add(user)
                }
            }

            it("should store same user") {
                expect(repository.count(.byUUID(uuid: uuid))).to(equal(1))
                expect(repository.queryOne(.byUUID(uuid: uuid))).toNot(beNil())
                expect(repository.queryOne(.byUUID(uuid: uuid))?.uuid).to(equal(uuid))
            }
        }
    }
}
