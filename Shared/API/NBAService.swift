//
//  NBAService.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 24/01/24.
//

import Foundation

actor NBAService {
    static let shared = NBAService()
    
    func fetchAllTeams(
        cachePolicy: URLRequest.CachePolicy,
        httpResponseClosure: ((HTTPURLResponse) -> Void)? = nil
    ) async throws -> [Team] {
        do {
            let request = URLRequest(url: URLS.teams, cachePolicy: cachePolicy)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                httpResponseClosure?(httpResponse)
                
                switch httpResponse.statusCode {
                case 500, 503:
                    throw AppError.serviceOffline
                case 429:
                    throw AppError.tooManyRequests
                case 404:
                    throw AppError.notFound
                default:
                    break
                }
            }
            
            guard let list = try? JSONDecoder().decode(TeamList.self, from: data) else {
                throw AppError.jsonConversionError
            }
            
            return list.data
        } catch {
            throw AppError.custom(error.localizedDescription)
        }
    }
    
    func fetchAllPlayers(
        searchPrompt: String? = nil,
        page: Int = 0,
        perPage: Int = 25,
        cachePolicy: URLRequest.CachePolicy,
        httpResponseClosure: ((HTTPURLResponse) -> Void)? = nil
    ) async throws -> PlayerList {
        do {
            let request = URLRequest(url: URLS.players(page: page, perPage: perPage, searchPrompt: searchPrompt), cachePolicy: cachePolicy)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                httpResponseClosure?(httpResponse)
                
                switch httpResponse.statusCode {
                case 500, 503:
                    throw AppError.serviceOffline
                case 429:
                    throw AppError.tooManyRequests
                case 404:
                    throw AppError.notFound
                default:
                    break
                }
            }
            
            guard let list = try? JSONDecoder().decode(PlayerList.self, from: data) else {
                throw AppError.jsonConversionError
            }
            
            return list
        } catch {
            throw AppError.custom(error.localizedDescription)
        }
    }
    
    func fetchPlayerStats(
        page: Int = 0,
        perPage: Int = 25,
        seasons: [Int]?,
        playerIds: [Int],
        startDate: String?,
        endDate: String?,
        cachePolicy: URLRequest.CachePolicy,
        httpResponseClosure: ((HTTPURLResponse) -> Void)? = nil
    ) async throws -> PlayerStatsList {
        do {
            let request = URLRequest(
                url: URLS.playersStats(page: page, perPage: perPage, seasons: seasons, playerIds: playerIds, startDate: startDate, endDate: endDate),
                cachePolicy: cachePolicy
            )
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                httpResponseClosure?(httpResponse)
                
                switch httpResponse.statusCode {
                case 500, 503:
                    throw AppError.serviceOffline
                case 429:
                    throw AppError.tooManyRequests
                case 404:
                    throw AppError.notFound
                default:
                    break
                }
            }
            
            do {
                let list = try JSONDecoder().decode(PlayerStatsList.self, from: data)
                return list
            } catch {
                if let decodeError = error as? DecodingError {
                    print(decodeError)
                }
                throw AppError.jsonConversionError
            }
        } catch {
            throw AppError.custom(error.localizedDescription)
        }
    }
}
