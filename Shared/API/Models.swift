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
    let currentPage, perPage: Int?
    let nextPage, totalPages, totalCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case currentPage = "current_page"
        case nextPage = "next_page"
        case perPage = "per_page"
        case totalCount = "total_count"
    }
    
    static var `default`: PlayerMeta {
        PlayerMeta(
            currentPage: 0,
            perPage: 25,
            nextPage: nil,
            totalPages: nil,
            totalCount: nil
        )
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
    let team: Team?
    
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

// MARK: - PlayerStatsList
struct PlayerStatsList: Codable {
    let data: [PlayerStats]
    let meta: PlayerMeta
}

// MARK: - PlayerStat
struct PlayerStats: Identifiable, Codable, Comparable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case ast
        case blk
        case dreb
        case fg3Pct = "fg3_pct"
        case fg3a
        case fg3m
        case fgPct = "fg_pct"
        case fga
        case fgm
        case ftPct = "ft_pct"
        case fta
        case ftm
        case id
        case min
        case oreb
        case pf
        case player
        case pts
        case reb
        case stl
        case team
        case turnover
    }
    
    let ast: Int
    let blk: Int
    let dreb: Int
    let fg3Pct: Double?
    let fg3a: Int
    let fg3m: Int
    let fgPct: Double
    let fga: Int
    let fgm: Int
    let ftPct: Double
    let fta: Int
    let ftm: Int
    let id: Int
    let min: String
    let oreb: Int
    let pf: Int
    let player: Player
    let pts: Int
    let reb: Int
    let stl: Int
    let team: Team
    let turnover: Int
    
    var fg3PctValue: Double {
        self.fg3Pct ?? Double(fg3m / fg3a)
    }
    
    static func < (lhs: PlayerStats, rhs: PlayerStats) -> Bool {
        lhs.player.firstName < rhs.player.firstName
    }
    
    static func random(
        astRange: Range<Int>,
        blkRange: Range<Int>,
        fgRange: Range<Int>,
        ftRange: Range<Int>,
        fg3Range: Range<Int>,
        ptsRange: Range<Int>,
        rebRange: Range<Int>
    ) -> PlayerStats {
        let fgm = (0..<fgRange.upperBound).randomElement()!
        let fga = fgRange.randomElement()!
        
        let ftm = (0...ftRange.upperBound).randomElement()!
        let fta = ftRange.randomElement()!
        
        let fg3m = (0...fg3Range.upperBound).randomElement()!
        let fg3a = fg3Range.randomElement()!
        
        return PlayerStats(
            ast: astRange.randomElement()!,
            blk: blkRange.randomElement()!,
            dreb: rebRange.randomElement()!,
            fg3Pct: Double(fg3m / fg3a),
            fg3a: fg3a,
            fg3m: fg3m,
            fgPct: Double(fgm / fga),
            fga: fga,
            fgm: fgm,
            ftPct: Double(ftm / fta),
            fta: fta,
            ftm: ftm,
            id: 69,
            min: (1...30).randomElement()!.description,
            oreb: rebRange.randomElement()!,
            pf: (0...3).randomElement()!,
            player: .dummy,
            pts: ptsRange.randomElement()!,
            reb: rebRange.randomElement()!,
            stl: (0...5).randomElement()!,
            team: .dummy,
            turnover: 3
        )
    }
    
    static var dummy: PlayerStats {
        PlayerStats(
            ast: 6,
            blk: 1,
            dreb: 7,
            fg3Pct: 4/5,
            fg3a: 5,
            fg3m: 4,
            fgPct: 4/7,
            fga: 7,
            fgm: 4,
            ftPct: 0,
            fta: 2,
            ftm: 0,
            id: 14073288,
            min: "35",
            oreb: 0,
            pf: 1,
            player: .dummy,
            pts: 17,
            reb: 7,
            stl: 3,
            team: .dummy,
            turnover: 3
        )
    }
}

// MARK: - Progress State enum
enum ProgressState<Value: Decodable> {
    case loading
    case error(Error)
    case data(Value)
}
