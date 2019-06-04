
import Foundation

/// This is the data model we use for collection InBed data. It has a start time and an end time, which can be used to calculate the time in bed (TIB), as well as visualize the data in various ways. In combination with Asleep data, it can be used to calculate sleep efficieny (SE).
class InBed {
    
    let Uuid: String;
    let StartTime: Date;
    let EndTime: Date;

    init(uuid: String, startTime: Date, endTime: Date) {
        Uuid = uuid
        StartTime = startTime;
        EndTime = endTime;
    }
}
