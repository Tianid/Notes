import UIKit
import Foundation
import WebKit

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?
    
    private let webView = WKWebView()
    private let clientId = "clientId" // здесь должен быть client_id вашего зарегистрированного приложения
    private let client_secret = "client_secret" // здесь должен быть client_secret вашего зарегистрированного приложения
    private let sheme = "login" // здесь должен быть callback URL вашего зарегистрированнаого приложения (пример: при регистрации я указал его как login://host, поэтому в поле sheme указываем: let sheme = "login")
    private var authCode = ""
    
    var completion: (() -> ())?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        var urlComponents = URLComponents(string: "https://github.com/login/oauth/authorize")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: "\(clientId)"),
            URLQueryItem(name: "scope", value: "gist")
        ]
        let request = URLRequest(url: urlComponents!.url!)
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private var tokenGetRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token") else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "\(clientId)"),
            URLQueryItem(name: "client_secret", value: "\(client_secret)"),
            URLQueryItem(name: "code", value: "\(authCode)")
        ]
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        return request
    }
}

extension AuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == self.sheme {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            
            if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                authCode = code
                guard let request = tokenGetRequest else { return }
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else { return }
                    guard let token = json["access_token"] as? String else { return }

                    self.delegate?.handleTokenChanged(token: token)
                    self.completion!()
                }.resume()
            }
            dismiss(animated: true, completion: nil)
        }
        defer {
            decisionHandler(.allow)
        }
    }
}
