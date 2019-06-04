
import Foundation
import HealthKit

protocol IAsleepClient {
    func get(onSuccess: @escaping ([Asleep]) -> Void, onFailure: @escaping () -> Void)
    @discardableResult func save(asleepData: [Asleep]) -> Bool
    @discardableResult func delete() -> Bool
}
