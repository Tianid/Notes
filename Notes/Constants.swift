import Foundation

public let OAUTH_ACCESS_TOKEN_URL_CONST = "https://github.com/login/oauth/access_token"
public let OAUTH_AUTHORIZE_URL_CONST = "https://github.com/login/oauth/authorize"
public let GISTS_URL_CONST = "https://api.github.com/gists"
public let CLIENT_ID_CONST = ""
public let CLIENT_SECRET_CONST = ""
public let SCHEME_CONST = "login"


enum NotesBackendResult {
    case success
    case failure(NetworkError)
    case noData
    case noGistOrNoNetworkConnection
    case emptyFile
}

enum BackgroundContextAction {
    case Create
    case Update
}



