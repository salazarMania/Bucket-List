//
//  Location.swift
//  Bucket List
//
//  Created by SANIYA KHATARKAR on 03/10/24.
//

import Foundation
import MapKit

struct Location : Identifiable, Codable, Equatable {
    var id: UUID
    var name : String
    var description : String
    let latitude : Double
    let longitude : Double
    
    var coordinate : CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "where Queen Elizabeth live with her dorgis", latitude: 51.501, longitude: -0.141)
    
    static func == (lhs : Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
