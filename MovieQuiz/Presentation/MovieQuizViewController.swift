import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate{
    
    
    // MARK: - Private functions
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButtonBlocking: UIButton!
    @IBOutlet private weak var noButtonBlocking: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswer: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServices?
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        yesButtonBlocking.isEnabled = false
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        
        let givenAnswer = false
        let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        noButtonBlocking.isEnabled = false
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticServicesImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServicesImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
    }
    // MARK: - QuestionFactoryDelegate
    
    func didAlertButtonPressed() {
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
        correctAnswer = 0
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadingIndicator(){
        //activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    
    }
    private func hideLoadingIndicator(){
        //activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    
    private func showAnswerResult(isCorrect:Bool){
        currentQuestionIndex += 1
        if isCorrect {
            correctAnswer += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    
    }
    
    private func showNextQuestionOrResults() {
        self.imageView.layer.borderWidth = 0
        if currentQuestionIndex >= questionsAmount {
            showRezult()
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let model = QuizResultsViewModel(title: "Ошибка",
                                         text: message,
                                         buttonText: "Попробовать ещё раз")
        
        alertPresenter?.showAlert(model: model)
        let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
    }
    
    private func showRezult() {
        
        statisticService?.store(correct: correctAnswer, total: questionsAmount)
        
        if let statService = statisticService {
            let date = statService.bestGame.date
            
            let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
                title: "Раунд окончен!",
                text: "Ваш результат: \(correctAnswer)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
                buttonText: "Сыграть ещё раз"
            )
            alertPresenter?.showAlert(model: alertViewModel)
            let generator = UINotificationFeedbackGenerator()
                       generator.notificationOccurred(.success)
        } else {
            let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
                title: "Раунд окончен!",
                text: "Ваш результат: \(correctAnswer)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            let generator = UINotificationFeedbackGenerator()
                       generator.notificationOccurred(.success)
            alertPresenter?.showAlert(model: alertViewModel)
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        yesButtonBlocking.isEnabled = true
        noButtonBlocking.isEnabled = true
    }
}
