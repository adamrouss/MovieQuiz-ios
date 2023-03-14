//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by AdamRouss on 14.03.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject, UIViewController {
    func didAlertButtonPressed()
    func showQuiz(quiz step: QuizStepViewModel)
    func showNetworkError(message: String)
}

