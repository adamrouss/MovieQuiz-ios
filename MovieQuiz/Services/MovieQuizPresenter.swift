//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by AdamRouss on 14.03.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Public
    
    var correctAnswers: Int = 0
    weak var viewController: MovieQuizViewControllerProtocol? //
    var questionFactory: QuestionFactoryProtocol? //
    var statisticService: StatisticServices?
    
    // MARK: - INIT
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServicesImplementation()
        questionFactory?.loadData()
    }
    
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
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private methods
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
    }
    
    private func showQuizRezult() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        if let statService = statisticService {
            let date = statService.bestGame.date
            
            let alertViewModel = QuizResultsViewModel (
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
                buttonText: "Сыграть ещё раз"
            )
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            viewController?.showAlert(model: alertViewModel)
        } else {
            let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
                title: "Раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            viewController?.showAlert(model: alertViewModel)
        }
    }
    
    // MARK: - Public methods
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            showQuizRezult()
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.highlightImageBorder(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAlertButtonPressed() {
        questionFactory?.loadData()
        restartGame()
    }
    
    func counterOfQuestions() -> String {
        "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
    
    func switchToNextQuestion () {
        currentQuestionIndex += 1
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
