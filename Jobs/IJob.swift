
import Foundation
import HealthKit

protocol IJob {
    func execute(anchor: HKQueryAnchor?) -> Void
}
