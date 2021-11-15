//
//  LoginViewController.swift
//  Google_Maps
//
//  Created by iMac on 14.11.2021.
//

import UIKit

class LoginViewController: UIViewController {

    let userRepository = UserRepository()

    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!

    var onLogin: (() -> Void)?
    var onRecover: (() -> Void)?
    var onRegistration: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldState()
        addObservers()
        print("github")
    }


    @IBAction func login(_ sender: Any) {
        guard
            let login = loginView.text,
            let password = passwordView.text,
            let user = try? userRepository.compareUserData(login: login, password: password),
            !user.isEmpty
         else {
            showTextFields()
             return
         }
 // Сохраним флаг, показывающий, что мы авторизованы
         UserDefaults.standard.set(true, forKey: "isLogin")
 // Перейдём к главному сценарию
        onLogin?()
    }

    @IBAction func recovery(_ sender: Any) {
        onRecover?()

    }

    @IBAction func registration(_ sender: Any) {
        onRegistration?()
    }

    // состояние полей textField - скрытие текста, автокоррекция:
    func textFieldState() {
        passwordView.isSecureTextEntry = true
        passwordView.autocorrectionType = .no
        loginView.autocorrectionType = .no
    }
    // Подписка на уведомления (приложение не активно - активно)
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(hideTextFields), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showTextFields), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    // скрыть логин и пароль
    @objc func hideTextFields() {
        self.passwordView.text = "SECURITY"
        self.loginView.text = "SECURITY"
        self.passwordView.isSecureTextEntry = false

    }
    // повтор регистрации
    @objc func showTextFields() {
        let alert = UIAlertController(title: "Error", message: "Повторите ввод", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            self.passwordView.text = ""
            self.loginView.text = ""
            self.passwordView.isSecureTextEntry = true
        }
        alert.addAction(action)
        present(alert, animated: true)

    }
}


