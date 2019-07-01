import Foundation
import UIKit


extension Note {
    var json: [String: Any] {
        get {
            var dict: [String: Any] = [:]
            dict.updateValue(uid, forKey: "uid")
            dict.updateValue(title, forKey: "title")
            dict.updateValue(content, forKey: "content")
            if color != UIColor.white {
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                let rgba:[CGFloat] = [r,g,b,a]
                dict.updateValue(rgba, forKey: "color")
            }
            if importance.rawValue != "common" {
                dict.updateValue(importance.rawValue, forKey: "importance")
            }
            guard selfDestructionDate != nil else {
                return dict
            }
            dict.updateValue(selfDestructionDate!.timeIntervalSince1970 , forKey: "selfDestructionDate")

            return dict
        }
    }
    static func parse (json: [String: Any]) -> Note? {
        var note:Note?
        var uid:String?
        var title:String?
        var content:String?
        var color:UIColor?
        var importance:Importance?
        var selfDestructionDate:Date?
        
        for key in json.keys{
            switch key {
            case "uid": uid = json[key] as? String
            case "title": title = json[key] as? String
            case "content": content = json[key] as? String
            case "color": let rgba = json[key] as! Array<CGFloat>
            color = UIColor.init(red: rgba[0] , green: rgba[1] , blue: rgba[2] , alpha: rgba[3] )
            case "importance": importance = Importance(rawValue: json[key] as! Importance.RawValue)
            case "selfDestructionDate": selfDestructionDate = Date(timeIntervalSince1970: json[key] as! TimeInterval)
            default:
                break
            }
        }
        
        if color == nil {
            color = UIColor.white
        }
        
        guard importance != nil else {
            return Note(uid: uid!, title: title!, content: content!, color: color!, importance: Importance.common, selfDestructionDate: selfDestructionDate)
        }
        
        note = Note(uid: uid!, title: title!, content: content!, color: color!, importance: Importance(rawValue: (importance?.rawValue)!)!, selfDestructionDate: selfDestructionDate)
        return note
    }
}
