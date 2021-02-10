/**
 Protocols provide an easy interface to swap Epic objects with your own.
 */

import Foundation

protocol ThrottleProtocol {
    init(interval: TimeInterval)

    func throttle(block: (() -> Void)?)
}
