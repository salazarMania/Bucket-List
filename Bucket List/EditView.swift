//
//  EditView.swift
//  Bucket List
//
//  Created by SANIYA KHATARKAR on 03/10/24.
//

import SwiftUI

struct EditView: View {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss
    var location : Location
    var onSave : (Location) -> Void //closure
    
    @State private var name : String
    @State private var description : String
    
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    TextField("Place name" , text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Nearby ...") {
                    switch loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ")
                            + Text (page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later...")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar{
                Button("Save"){
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name =  name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss ()
                    
                }
            }
            .task{
                await fetchNearbyPlaces()
            }
        }
    }
    init(location : Location, onSave : @escaping(Location) -> Void )
//    The closure escapes from the scope of the method, to the scope of the class. And it can be called later, even on another thread! This could cause problems if not handled properly.
    
    // escaping-> this function will not be called immediately, ask swift to keep the memory alive, stash it away safely, call it later on. this happens in our case wen user presses save
    
    {
        self.location = location
        self.onSave = onSave
        
        //we are creating an instance of the property wrapper, like we did with fetch requests
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
        
    }
    
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            print ("Bad URL : \(urlString)")
            return
        }
        
        //fetch request
        do {
            let(data , _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(Result.self, from: data)
            pages = items.query.pages.values.sorted()
            loadingState = .loaded
            
        } catch {
            loadingState = .failed
        }
    }
}


struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location : Location.example){
            _ in
        }
    }
}
