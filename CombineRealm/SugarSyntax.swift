//    
//  CombineRealm
//    
//  Created by Yaroslav Zhurakovskiy on 07.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import RealmSwift

public extension Results {
    func observeElementsPublisher() -> ObserveElementsPublisher<Element> {
        return ObserveElementsPublisher(results: self)
    }
    
    func observeChangePublisher() -> ObserveChangePublisher<Element> {
        return ObserveChangePublisher(results: self)
    }
}

public extension Realm {
    func objectsPublisher<Element: Object>(_ type: Element.Type) -> ObserveElementsPublisher<Element> {
        return objects(type).observeElementsPublisher()
    }
}

public extension RealmSwift.Object {
    func observePublisher() -> ObserveObjectPublisher {
        return ObserveObjectPublisher(object: self)
    }
}
