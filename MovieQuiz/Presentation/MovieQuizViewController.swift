import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Private
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Public
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var noButtonBlocking: UIButton!
    @IBOutlet var yesButtonBlocking: UIButton!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        showLoadingIndicator()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    func showAlert(model:QuizResultsViewModel) {
        
        let alert = UIAlertController(title: model.title,
                                      message: model.text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.didAlertButtonPressed()
        }
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "GameResults" // ДЛЯ ТЕСТОВ
        present(alert, animated: true, completion: nil)
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
        counterLabel.text = presenter?.counterOfQuestions()
        yesButtonBlocking.isEnabled = true
        noButtonBlocking.isEnabled = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = QuizResultsViewModel(title: "Ошибка",
                                         text: message,
                                         buttonText: "Попробовать ещё раз")
        showAlert(model: model)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        presenter?.switchToNextQuestion()
        switch isCorrect {
        case true:
            presenter?.correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.borderWidth = 8
        case false:
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            imageView.layer.borderWidth = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak presenter] in
            guard let presenter = presenter else { return }
            self.imageView.layer.borderWidth = 0
            presenter.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
        yesButtonBlocking.isEnabled = false
        noButtonBlocking.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
        yesButtonBlocking.isEnabled = false
        noButtonBlocking.isEnabled = false
    }
}
