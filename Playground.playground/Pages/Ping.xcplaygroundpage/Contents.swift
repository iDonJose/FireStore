/*:
 ## `ping()`
 Pings a MutableProperty.
 > Method exists for MutableProperty<()> & MutableProperty<()?>.
 */

import ReactiveSwifty_iOS
import ReactiveSwift
import Result


/// Property
let didTap = MutableProperty<()>(())

didTap.signal.observeValues { print("Did tap") }

didTap.ping()
didTap.ping()
didTap.ping()

//: < [Summary](Summary) | [Next](@next) >
