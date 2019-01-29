//
//  PlainRepositorySpec.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import RxSwift
@testable import RealmWhatever

class PlainRepositorySpec: QuickSpec {
    override func spec() {
        describe("Query One") {
            let uuid = UUID()
            let repository = UserRepository()

            beforeEach {
                Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "PlainRepositorySpec"
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()

                    let user = RLMUser()
                    user.uuid = uuid.uuidString
                    user.age = 50
                    user.name = "Alpha"
                    realm.add(user)
                }
            }

            it("should query one user by uuid") {
                let user = try! repository.queryOne(.byUUID(uuid: uuid), factory: UserFactory())

                expect { user }.toNot(beNil())
                expect { user!.uuid }.to(equal(uuid))
                expect { user!.name }.to(equal("Alpha"))
                expect { user!.age }.to(equal(50))
            }

            it("should query one user by age") {
                let user = try! repository.queryOne(.byAge(age: 50), factory: UserFactory())

                expect { user }.toNot(beNil())
                expect { user!.uuid }.to(equal(uuid))
                expect { user!.name }.to(equal("Alpha"))
                expect { user!.age }.to(equal(50))
            }
        }

        describe("Query") {
            let repository = UserRepository()

            beforeEach {
                Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "PlainRepositorySpec"
                let realm = try! Realm()

                try! realm.write {
                    realm.deleteAll()

                    let user = RLMUser()
                    user.uuid = UUID().uuidString
                    user.age = 50
                    user.name = "Alpha"
                    realm.add(user)

                    let user2 = RLMUser()
                    user2.uuid = UUID().uuidString
                    user2.age = 50
                    user2.name = "Beta"
                    realm.add(user2)

                    let user3 = RLMUser()
                    user3.uuid = UUID().uuidString
                    user3.age = 50
                    user3.name = "Omega"
                    realm.add(user3)
                }
            }

            it("should query user by age with pin policy") {
                let user = try! repository.queryOne(.byAgeSortedByName(age: 50), pinPolicy: .beginning, factory: UserFactory())
                let user3 = try! repository.queryOne(.byAgeSortedByName(age: 50), pinPolicy: .end, factory: UserFactory())

                expect { try repository.count(.byAgeSortedByName(age: 50)) }.to(equal(3))

                expect { user }.toNot(beNil())
                expect { user!.age }.to(equal(50))
                expect { user!.name }.to(equal("Alpha"))

                expect { user3 }.toNot(beNil())
                expect { user3!.age }.to(equal(50))
                expect { user3!.name }.to(equal("Omega"))
            }

            it("should query user by age with with limit, offset, and pin policy beginning") {
                let user = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        limit: 1, offset: 0, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                ).first
                let user2 = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        limit: 1, offset: 1, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                ).first
                let user3 = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        limit: 1, offset: 2, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                ).first

                expect { user }.toNot(beNil())
                expect { user!.age }.to(equal(50))
                expect { user!.name }.to(equal("Alpha"))

                expect { user2 }.toNot(beNil())
                expect { user2!.age }.to(equal(50))
                expect { user2!.name }.to(equal("Beta"))

                expect { user3 }.toNot(beNil())
                expect { user3!.age }.to(equal(50))
                expect { user3!.name }.to(equal("Omega"))
            }

            it("should query user by age with with limit, offset, and pin policy end") {
                let user = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        limit: 1, offset: 0, pinPolicy: .end
                    ),
                    factory: UserFactory()
                ).first
                let user2 = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        limit: 1, offset: 1, pinPolicy: .end
                    ),
                    factory: UserFactory()
                ).first
                let user3 = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        limit: 1, offset: 2, pinPolicy: .end
                    ),
                    factory: UserFactory()
                ).first

                expect { user }.toNot(beNil())
                expect { user!.age }.to(equal(50))
                expect { user!.name }.to(equal("Omega"))

                expect { user2 }.toNot(beNil())
                expect { user2!.age }.to(equal(50))
                expect { user2!.name }.to(equal("Beta"))

                expect { user3 }.toNot(beNil())
                expect { user3!.age }.to(equal(50))
                expect { user3!.name }.to(equal("Alpha"))
            }

            it("should query user by age with offset = 0, and pin policy beginning") {
                let users = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        offset: 0, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                )

                expect { users }.toNot(beNil())
                expect { users.count }.to(equal(3))

                expect { users[0].age }.to(equal(50))
                expect { users[0].name }.to(equal("Alpha"))

                expect { users[1].age }.to(equal(50))
                expect { users[1].name }.to(equal("Beta"))

                expect { users[2].age }.to(equal(50))
                expect { users[2].name }.to(equal("Omega"))
            }

            it("should query user by age with offset = 1, and pin policy beginning") {
                let users = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        offset: 1, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                )

                expect { users }.toNot(beNil())
                expect { users.count }.to(equal(2))

                expect { users[0].age }.to(equal(50))
                expect { users[0].name }.to(equal("Beta"))

                expect { users[1].age }.to(equal(50))
                expect { users[1].name }.to(equal("Omega"))
            }

            it("should query user by age with offset = 2, and pin policy beginning") {
                let users = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        offset: 2, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                )

                expect { users }.toNot(beNil())
                expect { users.count }.to(equal(1))

                expect { users[0].age }.to(equal(50))
                expect { users[0].name }.to(equal("Omega"))
            }

            it("should query user by age with offset = 3, and pin policy beginning") {
                let users = try! repository.query(
                    .byAgeSortedByName(age: 50),
                    cursor: .init(
                        offset: 3, pinPolicy: .beginning
                    ),
                    factory: UserFactory()
                )

                expect { users }.toNot(beNil())
                expect { users.count }.to(equal(0))
            }
        }
    }
}
