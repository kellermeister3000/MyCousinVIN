//
//  ContentView.swift
//  MyCousinVIN
//
//  Created by Philip Keller on 2/1/25.
//

import SwiftUI

struct Vehicle: Codable {
    // Add these properties
    var ModelYear: String?
    var Make: String?
    var Model: String?
    var Color: String?
    
    // Add other properties as needed
    var Results: [Vehicle]?
}

struct ContentView: View {
    // Add these state properties
    @State private var vinInput = ""
    @State private var vehicleData: Vehicle?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        VStack {
            // Add VIN input field and search button
            TextField("Enter VIN", text: $vinInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Search") {
                Task {
                    await fetchVehicleData()
                }
            }
            .disabled(vinInput.isEmpty || isLoading)
            
            // Add loading indicator
            if isLoading {
                ProgressView()
            } else if let vehicle = vehicleData {
                // Display vehicle information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Year: \(vehicle.ModelYear ?? "N/A")")
                    Text("Make: \(vehicle.Make ?? "N/A")")
                    Text("Model: \(vehicle.Model ?? "N/A")")
                    Text("Color: \(vehicle.Color ?? "N/A")")
                }
                .padding()
            }
        }
        .onAppear {
            // Fetch vehicle data when view appears
            Task {
                await fetchVehicleData()
            }
        }
    }
    
    // Add this function to fetch vehicle data
    func fetchVehicleData() async {
        isLoading = true
        defer { isLoading = false }
        
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/\(vinInput)?format=json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(Vehicle.self, from: data)
            
            // Update UI on main thread
            await MainActor.run {
                self.vehicleData = decodedResponse.Results?.first
            }
        } catch {
            print("Error fetching vehicle data: \(error)")
            self.error = error
        }
    }
}

#Preview {
    ContentView()
}
