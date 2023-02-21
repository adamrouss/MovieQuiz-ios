//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by AdamRouss on 20.02.2023.
//

import UIKit

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        if lhs.total == 0 {
            return true
        }
        let lhsRecord  = Double(lhs.correct) / Double(lhs.total)
        let rhsRecord = Double(rhs.correct) / Double(rhs.total)
        return lhsRecord < rhsRecord
    }
}
