//    
//  CombineRealmTests
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import XCTest
import RealmSwift
import Combine

class RealmTestsCase: XCTestCase {
    var realm: Realm!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        do {
            realm = try createTestRealm(identifier: String(describing: type(of: self)))
            cancellables = Set<AnyCancellable>()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }

        do {
            try realm.write {
               realm.deleteAll()
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        super.tearDown()
    }
    
    func setDefaultRealmConfiguration(
        inMemoryIdentifier: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let oldDefaultConfig = Realm.Configuration.defaultConfiguration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
           inMemoryIdentifier: inMemoryIdentifier
        )
        addTeardownBlock {
           do {
               let realm = try createTestRealm(identifier: inMemoryIdentifier)
               try realm.write {
                   realm.deleteAll()
               }
               Realm.Configuration.defaultConfiguration = oldDefaultConfig
           } catch let error {
                XCTFail(error.localizedDescription, file: file, line: line)
           }
        }
    }
}
