//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by AdamRouss on 14.03.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServices?
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak viewController] in
            viewController?.showQuiz(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func switchToNextQuestion () {
        currentQuestionIndex += 1
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
    }
    
    private func highlightImageBorder(isCorrect: Bool) {
        switchToNextQuestion()
        switch isCorrect {
        case true:
            correctAnswers += 1
            viewController?.imageView.layer.borderColor = UIColor.ypGreen.cgColor
            viewController?.imageView.layer.borderWidth = 8
        case false:
            viewController?.imageView.layer.borderColor = UIColor.ypRed.cgColor
            viewController?.imageView.layer.borderWidth = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        viewController?.imageView.layer.borderWidth = 0
        
        if isLastQuestion() {
            showQuizRezult()
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showQuizRezult() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        if let statService = statisticService {
            let date = statService.bestGame.date
            
            let alertViewModel = QuizResultsViewModel (
                title: "Раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
                buttonText: "Сыграть ещё раз"
            )
            let generator = UINotificationFeedbackGenerator()
                                  generator.notificationOccurred(.success)
            viewController?.alertPresenter?.showAlert(model: alertViewModel)
        } else {
            let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
                title: "Раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            viewController?.alertPresenter?.showAlert(model: alertViewModel)
        }
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        highlightImageBorder(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAlertButtonPressed() {
        restartGame()
        questionFactory?.loadData()
    }
    
    func counterOfQuestions() -> String {
        "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
        let generator = UIImpactFeedbackGenerator(style: .medium)
                           generator.impactOccurred()
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
        let generator = UIImpactFeedbackGenerator(style: .medium)
                           generator.impactOccurred()
    }
}
