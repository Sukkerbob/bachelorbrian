
import Foundation

protocol IDemographyClient {
    func get(onSuccess: @escaping (Demography) -> Void, onFailure: @escaping () -> Void)
    func save(demography: Demography)
    @discardableResult func delete() -> Bool
}
