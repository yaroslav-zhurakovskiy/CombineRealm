//
//  CombineRealmTests
//
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import Combine

final class Recorder<Input, Failure: Error>: Subscriber, Cancellable {
    private var subscription: Subscription?

    let combineIdentifier: CombineIdentifier
    private(set) var recordedValues: [Input]
    private(set) var recordedCompletions: [Subscribers.Completion<Failure>]
     
    init() {
        recordedValues = []
        recordedCompletions = []
        combineIdentifier = CombineIdentifier()
     }
    
     func receive(subscription: Subscription) {
        self.subscription = subscription
        
        subscription.request(.unlimited)
     }
    
     func receive(_ input: Input) -> Subscribers.Demand {
        recordedValues.append(input)
        return .unlimited
     }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        recordedCompletions.append(completion)
    }
    
    func cancel() {
        subscription?.cancel()
    }
}
