//
//  SearchResult.swift
//  PicsumPhotosApp
//
//  Created by Артем Ропавка on 14.11.2021.
//

import Foundation

struct SearchResult: Decodable {
    let total: Int
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Decodable {
    let width: Int
    let height: Int
    let urls: [URLKing.RawValue:String]
    
    
    enum URLKing: String {
        case raw
        case full
        case regular
        case small
        case thumb
    }
}
