//
//  APIManager.swift
//  routing_ios
//
//  Created by Eren on 16.05.2025.
//

import Foundation
import Combine

final class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "http://localhost:8070"
    
    private func logRequest(_ request: URLRequest) {
        print("\n--- API REQUEST ---")
        print("URL: \(request.url?.absoluteString ?? "-")")
        print("Method: \(request.httpMethod ?? "GET")")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("-------------------\n")
    }
    
    private func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        print("\n--- API RESPONSE ---")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status: \(httpResponse.statusCode)")
            print("URL: \(httpResponse.url?.absoluteString ?? "-")")
            print("Headers: \(httpResponse.allHeaderFields)")
        }
        if let data = data, let bodyString = String(data: data, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        print("--------------------\n")
    }

    private func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        logRequest(request)
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { [weak self] output in
                self?.logResponse(output.response, data: output.data, error: nil)
            }, receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.logResponse(nil, data: nil, error: error)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        let request = URLRequest(url: url)
        return dataTaskPublisher(for: request)
    }
    
    func fetchBranches() -> AnyPublisher<[Branch], Error> {
        let url = URL(string: "\(baseURL)/branches")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: [Branch].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchDispatches() -> AnyPublisher<[Dispatch], Error> {
        let url = URL(string: "\(baseURL)/dispatches")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: [Dispatch].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchDispatchById(id: Int) -> AnyPublisher<Dispatch, Error> {
        let url = URL(string: "\(baseURL)/dispatches/\(id)")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: Dispatch.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    func fetchVehicles() -> AnyPublisher<[Vehicle], Error> {
        let url = URL(string: "\(baseURL)/vehicles")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: [Vehicle].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    func fetchDispatchVehicles() -> AnyPublisher<[DispatchVehicle], Error> {
        let url = URL(string: "\(baseURL)/dispatch-vehicles")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: [DispatchVehicle].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCustomers() -> AnyPublisher<[Customer], Error> {
        let url = URL(string: "\(baseURL)/customers")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: [Customer].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createRoutePlan(routeId: Int) -> AnyPublisher<RouteResponse, Error> {
        let url = URL(string: "\(baseURL)/dispatch-vehicles/route/\(routeId)")!
        return dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: RouteResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createDispatch(dispatch: Dispatch) -> AnyPublisher<Dispatch, Error> {
        let url = URL(string: "\(baseURL)/dispatches")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(dispatch)
        return dataTaskPublisher(for: request)
            .map(\ .data)
            .decode(type: Dispatch.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createDispatchVehicle(dispatchVehicle: DispatchVehicle) -> AnyPublisher<DispatchVehicle, Error> {
        let url = URL(string: "\(baseURL)/dispatch-vehicles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(dispatchVehicle)
        return dataTaskPublisher(for: request)
            .map(\ .data)
            .decode(type: DispatchVehicle.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
