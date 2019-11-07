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

class WriteTests: RealmTestsCase {
    private var observeTokens: [NotificationToken]!
    
    override func setUp() {
        super.setUp()
        
        observeTokens = []
    }
    
    override func tearDown() {
        observeTokens.forEach { $0.invalidate() }
        
        super.tearDown()
    }
    
    func testWriteToRealm() throws {
        let updatedTitle = "UPDATED"
        let write = Realm.Write<Todo>(realm: realm, writeBlock: { realm, todo in
            todo.title = updatedTitle
            realm.add(todo)
        })
        write.store(in: &cancellables)
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        
        Publishers.Sequence(sequence: [todo1, todo2])
            .subscribe(write)
        
        
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0].title, updatedTitle)
        XCTAssertEqual(todos[1].title, updatedTitle)
    }
    
    func testWriteToDefaultRealm() throws {
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
        let updatedTitle = "UPDATED"
        let write = Realm.Write<Todo>(writeBlock: { realm, todo in
            todo.title = updatedTitle
            realm.add(todo)
        })
        write.store(in: &cancellables)
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")

        Publishers.Sequence(sequence: [todo1, todo2])
            .subscribe(write)


        let realm = try createTestRealm(identifier: #function)
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0].title, updatedTitle)
        XCTAssertEqual(todos[1].title, updatedTitle)
    }
    
    func testWriteToRealmSugarSyntax() {
        let updatedTitle = "UPDATED"
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        
        Publishers.Sequence(sequence: [todo1, todo2])
            .write(to: realm, writeBlock: { realm, todo in
                todo.title = updatedTitle
                realm.add(todo)
            })
            .store(in: &cancellables)
        
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0].title, updatedTitle)
        XCTAssertEqual(todos[1].title, updatedTitle)
    }
    
    func testWriteToDefaultRealmSugarSyntax() throws {
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
        let updatedTitle = "UPDATED"
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")

        Publishers.Sequence(sequence: [todo1, todo2])
            .writeToRealm { realm, todo in
                todo.title = updatedTitle
                realm.add(todo)
            }
            .store(in: &cancellables)


        let realm = try createTestRealm(identifier: #function)
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0].title, updatedTitle)
        XCTAssertEqual(todos[1].title, updatedTitle)
    }
}
