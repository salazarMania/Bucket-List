//
//  ContentView-ViewModel.swift
//  Bucket List
//
//  Created by SANIYA KHATARKAR on 16/10/24.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    @MainActor class ViewModel :  ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        
        @Published private(set) var locations : [Location]
        
        @Published var selectedPlace : Location?
        @Published var isUnlocked = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavePlaces")
        
        init(){
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save(){
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation(){
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location : Location){
            guard let selectedPlace = selectedPlace else {return}
            
            if let index = locations.firstIndex(of: selectedPlace){
                locations[index] = location
                save()
            }
        }
        
        func authenticate(){
            let context = LAContext()
            var error : NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){success , authenticationError in
                    if success {
                        Task{
                            @MainActor in
                            self.isUnlocked = true
                            }
                    }else{
                        //error
                    }
                }
            }else{
                //no biometrics
            }
        }
    }
}

//writing this separately in a model helps to test the model

//private set - reading is fine, read all you want to, but only the class itself can write location

//to store file with strong encryption - .completeFileProtection
