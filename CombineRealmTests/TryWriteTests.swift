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

class TryWriteTests: RealmTestsCase {
    private var observeTokens: [NotificationToken]!
    
    override func setUp() {
        super.setUp()
        
        observeTokens = []
    }
    
    override func tearDown() {
        observeTokens.forEach { $0.invalidate() }
        
        super.tearDown()
    }
    
    func testTryWriteToRealm() throws {
        let updatedTitle = "UPDATED"
        let write = Realm.TryWrite<Todo>(realm: realm, writeBlock: { realm, todo in
            todo.title = updatedTitle
            realm.add(todo)
            try throwErrorDummy() // Check if block accepts errors
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
    
    func testTryWriteToDefaultRealm() throws {
        setDefaultRealmConfiguration(inMemoryIdentifier: #function)
        let updatedTitle = "UPDATED"
        let write = Realm.TryWrite<Todo>(writeBlock: { realm, todo in
            todo.title = updatedTitle
            realm.add(todo)
            try throwErrorDummy() // Check if block accepts errors
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
    
    func testTryWriteToRealmSugarSyntax() {
        let updatedTitle = "UPDATED"
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        
        Publishers.Sequence(sequence: [todo1, todo2])
            .tryWrite(to: realm, writeBlock: { realm, todo in
                todo.title = updatedTitle
                realm.add(todo)
                try throwErrorDummy() // Check if block accepts errors
            })
            .store(in: &cancellables)
        
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0].title, updatedTitle)
        XCTAssertEqual(todos[1].title, updatedTitle)
    }
    
    func testTryWriteToDefaultRealmSugarSyntax() throws {
        setDefaultRealmConfiguration(inMemoryIdentifier: #function)
        let updatedTitle = "UPDATED"
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")

        Publishers.Sequence(sequence: [todo1, todo2])
            .tryWriteToRealm { realm, todo in
                todo.title = updatedTitle
                realm.add(todo)
                try throwErrorDummy() // Check if block accepts errors
            }
            .store(in: &cancellables)

        let realm = try createTestRealm(identifier: #function)
        let todos = realm.objects(Todo.self)
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0].title, updatedTitle)
        XCTAssertEqual(todos[1].title, updatedTitle)
    }
    
    func testHandleError() {
        let errorDescription = "Test error"
        let thrownError = NSError(
            domain: "test",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: errorDescription
            ]
        )
        var recordedErors: [Error] = []
        let write = Realm.TryWrite<Todo>(
            realm: realm,
            writeBlock: { _, _ in
                throw thrownError
            },
            handleFailure: { error in
                recordedErors.append(error)
            }
        )

        write.store(in: &cancellables)
       
        Just(Todo("Test"))
           .subscribe(write)
        
        XCTAssertEqual(recordedErors.count, 1)
        XCTAssertEqual(recordedErors[0].localizedDescription, errorDescription)
        XCTAssertEqual(recordedErors[0] as NSError, thrownError)
   }
    
     func testHandleErrorSugarSyntax() {
         let errorDescription = "Test error"
         let thrownError = NSError(
             domain: "test",
             code: 0,
             userInfo: [
                 NSLocalizedDescriptionKey: errorDescription
             ]
         )
         var recordedErors: [Error] = []
  
         Just(Todo("Test"))
            .tryWrite(
                to: realm,
                writeBlock: { _, _ in
                    throw thrownError
                },
                handleFailure: { error in
                    recordedErors.append(error)
                }
            )
            .store(in: &cancellables)
         
         XCTAssertEqual(recordedErors.count, 1)
         XCTAssertEqual(recordedErors[0].localizedDescription, errorDescription)
         XCTAssertEqual(recordedErors[0] as NSError, thrownError)
    }
}
