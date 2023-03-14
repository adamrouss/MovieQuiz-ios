//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by AdamRouss on 14.03.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func showAlert(model:QuizResultsViewModel)
    func highlightImageBorder(isCorrect: Bool)
    func showQuiz(quiz step: QuizStepViewModel)
    func showNetworkError(message: String)
}

