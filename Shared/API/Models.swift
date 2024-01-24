//
//  Models.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 24/01/24.
//

import Foundation

// MARK: - Team JSON Models
struct TeamList: Codable {
    let data: [Team]
    
    static var dummy: TeamList {
        TeamList(data: [.dummy])
    }
}

struct Team: Identifiable, Codable, Comparable, Equatable {
    let id: Int
    let abbreviation: String
    let city: String
    let conference: String
    let division: String
    let fullName: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case abbreviation = "abbreviation"
        case city = "city"
        case conference = "conference"
        case division = "division"
        case fullName = "full_name"
        case name = "name"
    }
    
    static func < (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    static var dummy: Team {
        Team(
            id: 14,
            abbreviation: "LAL",
            city: "Los Angeles",
            conference: "West",
            division: "Pacific",
            fullName: "Los Angeles Lakers",
            name: "Lakers"
        )
    }
}

// MARK: - Player JSON Models
struct PlayerList: Codable {
    let data: [Player]
    let meta: PlayerMeta
    
    static var placeholder: PlayerList {
        PlayerList(
            data: [
                .dummy
            ],
            meta: PlayerMeta(currentPage: 50, perPage: 2, nextPage: 1, totalPages: 25, totalCount: 9_999)
        )
    }
}

struct PlayerMeta: Codable {
    let currentPage, perPage: Int
    let nextPage, totalPages, totalCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case currentPage = "current_page"
        case nextPage = "next_page"
        case perPage = "per_page"
        case totalCount = "total_count"
    }
}

struct Player: Identifiable, Codable, Comparable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let position: String
    let heightFeet: Double?
    let heightInches: Double?
    let weightPounds: Double?
    let team: Team
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case position = "position"
        case heightFeet = "height_feet"
        case heightInches = "height_inches"
        case weightPounds = "weight_pounds"
        case team = "team"
    }
    
    static var dummy: Player {
        Player(
            id: 237,
            firstName: "Lebron",
            lastName: "James",
            position: "F",
            heightFeet: 6,
            heightInches: 8,
            weightPounds: 250,
            team: .dummy
        )
    }
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Progress State enum
enum ProgressState<Value: Decodable> {
    case loading
    case error(Error)
    case data(Value)
}
