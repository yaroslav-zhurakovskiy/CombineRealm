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
        
        realm = try! createTestRealm(identifier: String(describing: type(of: self)))
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }

        try! realm.write {
           realm.deleteAll()
        }
        
        super.tearDown()
    }
}
