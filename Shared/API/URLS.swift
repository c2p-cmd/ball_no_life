//
//  URLS.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 24/01/24.
//

import Foundation

enum URLS {
    static private let base = URL(string: "https://www.balldontlie.io/api/v1/")!
    
    static let teams = base.appending(path: "teams")
    static func specificTeam(id: String) -> URL {
        teams.appending(path: id)
    }
    
    static func players(page: Int = 0, perPage: Int = 25, searchPrompt: String?) -> URL {
        var playersUrl = base.appending(path: "players")
        var items = [
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "per_page", value: perPage.description)
        ]
        
        if let searchPrompt {
            items.append(
                URLQueryItem(name: "search", value: searchPrompt)
            )
        }
        
        return playersUrl.appending(queryItems: items)
    }
    
    static func seasonAverages(season: Int?, playerIds: [Int]) -> URL {
        var url = base.appending(path: "season_averages")
        var queryItems = [URLQueryItem]()
        
        if let season {
            queryItems.append(URLQueryItem(name: "season", value: season.description))
        }
        
        queryItems.append(contentsOf: playerIds.map { URLQueryItem(name: "player_ids[]", value: $0.description) })
        
        if queryItems.isEmpty == false {
            url.append(queryItems: queryItems)
        }
        
        return url
    }
    
    static func playersStats(seasons: [Int]?, playerIds: [Int]) -> URL {
        var url = base.appending(path: "stats")
        var queryItems = [URLQueryItem]()
        
        seasons?.forEach { season in
            queryItems.append(URLQueryItem(name: "seasons[]", value: season.description))
        }
        
        queryItems.append(contentsOf: playerIds.map { URLQueryItem(name: "player_ids[]", value: $0.description) })
        
        if queryItems.isEmpty == false {
            url.append(queryItems: queryItems)
        }
        
        return url
    }
}

enum AppError: Error, LocalizedError, CustomStringConvertible {
    case notFound
    case tooManyRequests
    case jsonConversionError
    case serviceOffline
    case custom(String)
    
    var description: String {
        switch self {
        case .serviceOffline:
            "Service is not available"
        case .tooManyRequests:
            "Too Many Requests"
        case .notFound:
            "Data Not Found"
        case .jsonConversionError:
            "JSON Conversion Error"
        case .custom(let m):
            m
        }
    }
    
    var errorDescription: String? {
        description
    }
}
