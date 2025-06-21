//
//  Stop.swift
//  TriLive
//
//  Created by Anthony Qin on 6/13/25.
//

struct Stop: Identifiable {
    
    let id: Int //Stop number
    let name: String //Stop name
    let routeList: [Route]

}

struct Route: Identifiable {
    
    let id: Int //MAX route number
    let name: String
    let arrivalTime: Int
    let direction: String
    let realTime: Int
    let isMAX: Bool
    
}


//Maybe we can create different numbers for different MAX line colors
