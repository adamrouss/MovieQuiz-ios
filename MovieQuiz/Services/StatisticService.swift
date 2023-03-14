//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by AdamRouss on 18.02.2023.
//

import UIKit


final class StatisticServicesImplementation: StatisticServices {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccurancy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        
        if bestGame < newGame {
            bestGame = newGame
        }
        if gamesCount != 0 {
            totalAccurancy = (totalAccurancy + Double(newGame.correct) / Double(newGame.total))/2.0
        } else {
            totalAccurancy = (Double(newGame.correct) / Double(newGame.total))
        }
        gamesCount += 1
    }
}
