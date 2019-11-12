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

class AddTests: RealmTestsCase {
    private var observeTokens: [NotificationToken]!
    
    override func setUp() {
        super.setUp()
        
        observeTokens = []
    }
    
    override func tearDown() {
        observeTokens.forEach { $0.invalidate() }
        
        super.tearDown()
    }
    
    func testAddToRealm() throws {
        let add = Realm.Add(realm: realm)
        add.store(in: &cancellables)
        
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        
        Publishers.Sequence(sequence: [todo1, todo2])
            .subscribe(add)
        
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        assert(Array(todos), contains: [todo1, todo2])
    }
    
    func testAddToDefaultRealm() throws {
        setDefaultRealmConfiguration(inMemoryIdentifier: #function)
        let add = Realm.Add()
        add.store(in: &cancellables)
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        Publishers.Sequence(sequence: [todo1, todo2])
           .subscribe(add)

        let realm = try createTestRealm(identifier: #function)
        let todos = realm.objects(Todo.self)
        assert(Array(todos), contains: [todo1, todo2])
    }
    
    func testAddRealmSugarSyntax() {
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
      
        Publishers.Sequence(sequence: [todo1, todo2])
            .add(to: realm)
            .store(in: &cancellables)
          
        let todos = realm.objects(Todo.self)
        assert(Array(todos), contains: [todo1, todo2])
    }
    
    func testAddToDefaultRealmSugarSyntax() throws {
        setDefaultRealmConfiguration(inMemoryIdentifier: #function)
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
      
        Publishers.Sequence(sequence: [todo1, todo2])
            .addToRealm()
            .store(in: &cancellables)
          
        let realm = try createTestRealm(identifier: #function)
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        assert(Array(todos), contains: [todo1, todo2])
    }
}
