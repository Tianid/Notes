import Foundation
import UIKit

 class NetworkNoteBook {
    fileprivate var gistId: String?
    var token = ""
    var notes: [Note]?
    var result: NotesBackendResult!
    
    struct Gist: Codable {
        let files: [String: GistFile]
        let id: String
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
        let component = URLComponents(string: GISTS_URL_CONST)
        let url = component?.url
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else { print(error as Any); self.result = .failure(error as! NetworkError); completionHandler(); return}
            guard let data = data else { self.result = .failure(error as! NetworkError); completionHandler(); return }
            guard let gists = try? JSONDecoder().decode([Gist].self, from: data) else {
                print("Parsing error")
                self.result = .failure(error as! NetworkError)
                completionHandler()
                return
            }
            
            for gist in gists {
                if let file = gist.files["ios-course-notes-db"]{
                    rawUrl = file.rawUrl
                    self.gistId = gist.id
                }
            }
            
            // Second URLSession allow get data from gist by raw_url
            guard rawUrl != nil else {self.result = .noGistOrNoNetworkConnection; self.gistId = nil; print(self.result as Any); completionHandler(); return }

            let component = URLComponents(string: rawUrl!)
            let url = component?.url
            
            var urlRequest = URLRequest(url: url!)
            urlRequest.setValue("token \(self.token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else { print(error as Any); self.result = .failure(error as! NetworkError) ;completionHandler(); return}
                guard let data = data else { self.result = .failure(error as! NetworkError); print(self.result as Any); completionHandler(); return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    self.notes = []
                    for item in json {
                        self.notes?.append(Note.parse(json: item)!)
                    }

                    print("ios-course-notes-db WAS LOADED FROM BACKEND")
                    print(self.notes!)
                    self.result = .success
                    completionHandler()
                    
                } catch {
                    print(error)
                    self.result = .emptyFile
                    completionHandler()
                }

            }.resume()
         
        }.resume()
    }
    
    func setContentForGist(notes: [Note], completionHandler: @escaping () -> Void) {
        // Update/create GitHub Gist file
        self.notes = notes
        if self.gistId != nil {
            // if file exist - update it
            var result = [[String: Any]]()
            for value in self.notes! {
                result.append(value.json)
            }
            
            let component = URLComponents(string: "\(GISTS_URL_CONST)/\(self.gistId!)")
            let url = component?.url
            var request = URLRequest(url: url!)
            request.httpMethod = "PATCH"
            request.setValue("token \(self.token)", forHTTPHeaderField: "Authorization")
            let jsonData = try! JSONSerialization.data(withJSONObject: result, options: [])
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["description": "Notes", "files":["ios-course-notes-db":["content": String(data: jsonData, encoding: .utf8)!, "filename":"ios-course-notes-db"]]])
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        print("ios-course-notes-db was UPDATED")
                        self.result = .success
                        completionHandler()
                    default:
                        print("Status: \(response.statusCode)")
                        self.result = .failure(error as! NetworkError)
                        completionHandler()
                        
                    }
                }
            }.resume()
        } else {
            // if file not exist - create file
            var result = [[String: Any]]()
            for value in self.notes! {
                result.append(value.json)
            }
            let component = URLComponents(string: "\(GISTS_URL_CONST)")
            let url = component?.url
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("token \(self.token)", forHTTPHeaderField: "Authorization")
            let jsonData = try! JSONSerialization.data(withJSONObject: result, options: [])
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["description": "Notes", "public":false, "files":["ios-course-notes-db":["content": String(data: jsonData, encoding: .utf8)!]]])
            URLSession.shared.dataTask(with: request) { (data, response, error) in
        
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        guard let data = data else { return }
                        do {
                            let gist = try JSONDecoder().decode(Gist.self, from: data)
                            self.gistId = gist.id
                            print(self.gistId!, "ID FROM CREATING REQUEST")

                        } catch {
                            print(error)
                        }
                        print("ios-course-notes-db was CREATED")
                        self.result = .success
                        completionHandler()
                    default:
                        print("Status: \(response.statusCode)")
                        self.result = .failure(error as! NetworkError)
                        completionHandler()
                    }
                }
            }.resume()
            //completionHandler()
        }
    }
}




