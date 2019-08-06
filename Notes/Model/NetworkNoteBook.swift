import Foundation
import UIKit

 class NetworkNoteBook {
    
    fileprivate let token = "super_duper_secret_token"
    var notes: [Note]?
    var result: String?
    
    struct Gist: Codable {
        let files: [String: GistFile]
        
    }
    
    struct GistFile: Codable {
        let filename: String
        let rawUrl: String
        
        enum CodingKeys: String, CodingKey {
            case filename
            case rawUrl = "raw_url"
        }
    }

    func getContentFromGist(completionHandler: @escaping () -> Void) {
        // First URLSession allow get raw_url
        var rawUrl: String?
        let component = URLComponents(string: "https://api.github.com/gists")
        let url = component?.url
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else { print(error as Any); self.result = "\(String(describing: error))"; completionHandler(); return}
            guard let data = data else { self.result = "no data"; completionHandler(); return }
            guard let gists = try? JSONDecoder().decode([Gist].self, from: data) else {
                print("Parsing error")
                self.result = "parsing error"
                completionHandler()
                return
            }
            for gist in gists {
                if let file = gist.files["ios-course-notes-db"]{
                    rawUrl = file.rawUrl
                }
            }
            
            // Second URLSession allow get data from gist by raw_url
            guard rawUrl != nil else {self.result = "network error"; completionHandler(); return }
            let component = URLComponents(string: rawUrl!)
            let url = component?.url
            
            var urlRequest = URLRequest(url: url!)
            urlRequest.setValue("token \(self.token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else { print(error as Any); self.result = "\(String(describing: error))" ;completionHandler(); return}
                guard let data = data else { self.result = "no data"; completionHandler(); return }
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    self.notes = []
                    for item in json {
                        self.notes?.append(Note.parse(json: item)!)
                    }
                    print("LOADED")
                    print(self.notes!)
                    self.result = "sucsses"
                    completionHandler()
                    
                } catch {
                    print(error)
                    self.result = "empty_file"
                    completionHandler()
                }

            }.resume()
         
        }.resume()
    }
}

