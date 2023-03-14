//
//  StaticServiceProtocol.swift
//  MovieQuiz
//
//  Created by AdamRouss on 14.03.2023.
//

import UIKit

protocol StatisticServices {
    
    var totalAccurancy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount:Int)
}
