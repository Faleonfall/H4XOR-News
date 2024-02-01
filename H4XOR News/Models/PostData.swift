//
//  PostData.swift
//  H4XOR News
//
//  Created by Volodymyr Kryvytskyi on 15.09.2023.
//

import Foundation

struct Results: Decodable {
    let hits: [Post]
}

struct Post: Decodable, Identifiable {
    var id: String {
        return objectID
    }
    
    let points: Int
    let title: String
    let url: String?
    
    let objectID: String
}
