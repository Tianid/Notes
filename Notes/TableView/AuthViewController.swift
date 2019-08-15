import UIKit
import Foundation
import WebKit

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?
    private let webView = WKWebView()
    private var authCode = ""
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        var urlComponents = URLComponents(string: OAUTH_AUTHORIZE_URL_CONST)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: "\(CLIENT_ID_CONST)"),
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
        guard var urlComponents = URLComponents(string: OAUTH_ACCESS_TOKEN_URL_CONST) else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "\(CLIENT_ID_CONST)"),
            URLQueryItem(name: "client_secret", value: "\(CLIENT_SECRET_CONST)"),
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
        if let url = navigationAction.request.url, url.scheme == SCHEME_CONST {
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
