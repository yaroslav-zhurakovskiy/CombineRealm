//    
//  CombineRealmTests
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import CombineRealm
import RealmSwift
import XCTest
import Combine

class DeleteTests: RealmTestsCase {
    private var observeTokens: [NotificationToken]!
    
    override func setUp() {
        super.setUp()
        
        observeTokens = []
    }
    
    override func tearDown() {
        observeTokens.forEach { $0.invalidate() }
        
        super.tearDown()
    }
    
    func testDeleteFromRealm() throws {
        let delete = Realm.Delete(realm: realm)
        delete.store(in: &cancellables)
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        try realm.write {
            realm.add([todo1, todo2])
        }
        let addedTodos = Array(realm.objects(Todo.self))
        XCTAssertEqual(addedTodos.count, 2)
        assert(addedTodos, contains: [todo1, todo2])
        
        Publishers.Sequence(sequence: [todo1, todo2])
            .subscribe(delete)
        
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 0)
    }
    
    func testDeleteFromDefaultRealm() throws {
        let oldDefaultConfig = Realm.Configuration.defaultConfiguration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            inMemoryIdentifier: #function
        )
        defer {
            let realm = try! createTestRealm(identifier: #function)
            try! realm.write {
                realm.deleteAll()
            }
            Realm.Configuration.defaultConfiguration = oldDefaultConfig
        }
        let delete = Realm.Delete()
        delete.store(in: &cancellables)
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        let realm = try createTestRealm(identifier: #function)
        try realm.write { realm.add([todo1, todo2]) }
        let addedTodos = Array(realm.objects(Todo.self))
        XCTAssertEqual(addedTodos.count, 2)
        assert(addedTodos, contains: [todo1, todo2])
        
        Publishers.Sequence(sequence: [todo1, todo2])
           .subscribe(delete)

        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 0)
    }
    
    func testDeleteFromRealmSugarSyntax() throws {
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        try realm.write {
         realm.add([todo1, todo2])
        }
        let addedTodos = Array(realm.objects(Todo.self))
        XCTAssertEqual(addedTodos.count, 2)
        assert(addedTodos, contains: [todo1, todo2])

        Publishers.Sequence(sequence: [todo1, todo2])
            .delete(from: realm)
            .store(in: &cancellables)

        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 0)
    }
    
    func testDeleteFromDefaultRealmSugarSyntax() throws {
        let oldDefaultConfig = Realm.Configuration.defaultConfiguration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            inMemoryIdentifier: #function
        )
        defer {
            let realm = try! createTestRealm(identifier: #function)
            try! realm.write {
                realm.deleteAll()
            }
            Realm.Configuration.defaultConfiguration = oldDefaultConfig
        }
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        let realm = try createTestRealm(identifier: #function)
        try realm.write { realm.add([todo1, todo2]) }
        let addedTodos = Array(realm.objects(Todo.self))
        XCTAssertEqual(addedTodos.count, 2)
        assert(addedTodos, contains: [todo1, todo2])
        
        Publishers.Sequence(sequence: [todo1, todo2])
            .deleteFromRealm()
            .store(in: &cancellables)

        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 0)
    }
}
