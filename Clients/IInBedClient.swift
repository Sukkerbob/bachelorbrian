
import Foundation

protocol IInBedClient {
    func get(onSuccess: @escaping ([InBed]) -> Void, onFailure: @escaping () -> Void)
    @discardableResult func save(inBedData: [InBed]) -> Bool
    @discardableResult func delete() -> Bool
}
