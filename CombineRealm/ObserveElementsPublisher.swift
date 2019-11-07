//
//  CombineRealm
//
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import Combine
import RealmSwift

public struct ObserveElementsPublisher<Element: RealmCollectionValue>: Publisher {
    public typealias Results = RealmSwift.Results<Element>
    public typealias Output = [Element]
    public typealias Failure = Error
    
    private let results: Results
    private var lastDemand: Subscribers.Demand?
    
    public init(results: Results) {
        self.results = results
    }
    
    public func receive<S>(
        subscriber: S
    ) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(
            subscription: Subscription(
                results: results,
                subscriber: AnySubscriber(subscriber)
            )
        )
    }
    
    private class Subscription: Combine.Subscription {
        private let results: Results
        private let subscriber: AnySubscriber<Output, Failure>
        
        private var token: NotificationToken?
        
        let combineIdentifier: CombineIdentifier = CombineIdentifier()
        
        init(results: Results, subscriber: AnySubscriber<Output, Failure>) {
            self.results = results
            self.subscriber = subscriber
            self.token = nil
        }
        
        func request(_ demand: Subscribers.Demand) {
            token = results.observe { [weak self] result in
                guard let self = self else { return }

                switch result {
                case let .initial(latestValue):
                  self.update(latestValue)
                case .update(let latestValue, _, _, _):
                  self.update(latestValue)
                case .error(let error):
                  self.token = nil
                  self.subscriber.receive(completion: .failure(error))
                }
            }
        }
        
        func cancel() {
            token?.invalidate()
            token = nil
        }

        private func update(_ results: Results) {
            // TODO: Implement custom Demand
            _ = subscriber.receive(Array(results))
        }
    }
}
