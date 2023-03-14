//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by AdamRouss on 07.02.2023.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject{
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
