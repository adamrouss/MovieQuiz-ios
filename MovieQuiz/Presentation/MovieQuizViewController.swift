import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    private var presenter = MovieQuizPresenter()
    var alertPresenter: AlertPresenter?
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var noButtonBlocking: UIButton!
    @IBOutlet var yesButtonBlocking: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        
        presenter.statisticService = StatisticServicesImplementation()
        presenter.viewController = self
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)
        presenter.questionFactory?.loadData()
        
        showLoadingIndicator()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didAlertButtonPressed() {
        presenter.didAlertButtonPressed()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
        func showQuiz(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = presenter.counterOfQuestions()
        yesButtonBlocking.isEnabled = true
        noButtonBlocking.isEnabled = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = QuizResultsViewModel(title: "Ошибка",
                                         text: message,
                                         buttonText: "Попробовать ещё раз")
        alertPresenter?.showAlert(model: model)
        let generator = UINotificationFeedbackGenerator()
                          generator.notificationOccurred(.error)
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        yesButtonBlocking.isEnabled = false
        noButtonBlocking.isEnabled = false
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButtonBlocking.isEnabled = false
        noButtonBlocking.isEnabled = false
        presenter.yesButtonClicked()
    }
}
