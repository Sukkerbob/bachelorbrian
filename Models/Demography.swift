
import Foundation

/// This is the data model we use for collecting Demography data. It contains date of birth as well as biological sex.
class Demography {
    
    let Uuid: String;
    let BirthYear : Int?
    let Sex : BiologicalSex
    
    init(uuid: String, birthYear: Int?, sex: BiologicalSex) {
        Uuid = uuid
        BirthYear = birthYear
        Sex = sex
    }
}
