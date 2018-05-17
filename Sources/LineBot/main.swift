import Vapor
import Foundation
import JSON


public func randomInt(range:Int) -> Int {
    #if os(Linux)
        return Glibc.random() % range
    #else
        return Int(arc4random_uniform(UInt32(range)))
    #endif
}


//struct button: Codable {
//    let type: String = "uri"
//    let label: String = "Open"
//    var uri: String
//
//    init(uri: String){
//        self.uri = uri
//    }
//}
//
//struct column: Codable {
//    var imageUrl: String
//    var action: button
//
//    init(imageUrl: String, action: button) {
//        self.imageUrl = imageUrl
//        self.action = action
//    }
//}
//
//
//struct template: Codable {
//    let type: String = "image_carousel"
//    var columns: [column]
//
//    init(columns: [column] = [column]()) {
//        self.columns = columns
//    }
//
//    mutating func addColumn(relative column: column) {
//        columns.append(column)
//    }
//}
//
//
//struct imageCarousel: Codable {
//    let type: String = "template"
//    var template: template
//
//    init(template: template) {
//        self.template = template
//    }
//}




let drop = try Droplet()
let endpoint = "https://api.line.me/v2/bot/message/reply"
let accessToken = "OoFdWpqFaiTweCAZ78pVaxcGsNJrzBob0MFrQxHjbmFZmf3Hf1Mr0Z3Rt+CNdWBPHDAPkdCIlLOFfgfPcb22SPqx67yqhD+GBcwWhijCFmwUznCZxhe6Y8cM/HYp/JCyR/7pWcr17f+mab4gBM3ZtgdB04t89/1O/w1cDnyilFU="

let push = "https://api.line.me/v2/bot/message/push"


drop.get("hello") { req in
    print(req)
    return "Hello Vapor!!!"
}

drop.post("callback"){ req in
    print(req);
    
    guard let object = req.data["events"]?.array?.first?.object else{
        return Response(status: .ok, body: "this message is not supported")
    }
    
//    guard let message = object["message"]?.object?["text"]?.string, let replyToken = object["replyToken"]?.string else{
//        return Response(status: .ok, body: "this message is not supported")
//    }
    
    guard let message = object["message"]?.object?["text"]?.string else {
        return Response(status: .ok, body: "this message is not supported")
    }
        
    guard let replyToken = object["replyToken"]?.string else {
        return Response(status: .ok, body: "this message is not supported")
    }
        
    guard let userID = object["source"]?.object?["userId"]?.string else {
            return Response(status: .ok, body: "this message is not supported")
    }

            
    print("-----------------");
    print(message);
    
    var responseData: JSON = JSON()
    
    // push Data
    var pushData: JSON = JSON()
    
    if (message == "抽"){
        
        let imgur = try drop.client.get("https://api.imgur.com/3/album/mgKOf/images", query: [
            
            :],[
                "Authorization" : "Client-ID e9a5ed48901c361"
            ])
        guard let imgurData = imgur.data["data"]?.array else {
            return Response(status: .ok, body: "this message is not supported")
        }
        
        let temp = randomInt(range: imgurData.count)
        
        guard let picture = imgurData[temp].object?["link"] else {
            return Response(status: .ok, body: "this message is not supported")
        }
        
        try responseData.set("replyToken", replyToken)
        try responseData.set("messages", [
            ["type": "image",
             "originalContentUrl": picture,
             "previewImageUrl": picture]
            ])
        
        try pushData.set("to", userID)
        try pushData.set("messages", [
            ["type": "text", "text": "我他媽的成功啦！！！"]
            ])
        
    } else if (message == "給我妹子"){
        
        var index: String = ""
        var beautyPageArray = [String]()
        var imgurUrlArray = [String]()
        
        // 取得表特最新頁面的index
        let indexHtml = try drop.client.get("https://www.ptt.cc/bbs/Beauty/index.html")
        
        let indexHtmlString = indexHtml.description
        let indexRange = indexHtmlString.range(of: ".html\">&lsaquo; 上頁")
        if let range = indexRange {
            let number = indexHtmlString.prefix(upTo: range.lowerBound)
            guard let lastNum = Int(number.suffix(4)) else {
                return Response(status: .ok, body: "this message is not supported")
            }
            index = String(lastNum + 1)
            print(index)  // 取得當前的index
        }
        
        // 撈出所有貼文
        let beauty = try drop.client.get("https://www.ptt.cc/bbs/Beauty/index\(index).html")
        var beautyString = beauty.description
        
        while(beautyString.contains("<a href=\"/bbs/Beauty/")){
            let beautyRange = beautyString.range(of: "<a href=\"/bbs/Beauty/")
            let lessBeauty = beautyString.suffix(from: (beautyRange?.upperBound)!)
            let imgurKey = String(lessBeauty.prefix(29))
            beautyPageArray.append(imgurKey)
            beautyString = String(lessBeauty)
        }
        
        // 將公告文排除
        var i = 0
        for imgur in beautyPageArray {
            if(imgur.contains("公告")||imgur.contains("帥哥")){
                beautyPageArray.remove(at: i)
                continue
            } else {
                let imgurKey = String(imgur.prefix(18))
                beautyPageArray.remove(at: i)
                beautyPageArray.insert(imgurKey, at: i)
            }
            i = i + 1
        }
        
        // 撈出每則貼文的imgur網址
        for imgurUrl in beautyPageArray {
            let beauty = try drop.client.get("https://www.ptt.cc/bbs/Beauty/\(imgurUrl).html")
            var beautyString = beauty.description
            
            while(beautyString.contains("imgur.com/")){
                let beautyRange = beautyString.range(of: "imgur.com/")
                let lessBeauty = beautyString.suffix(from: (beautyRange?.upperBound)!)
                let imgurKey = String(lessBeauty.prefix(7))
                if(imgurKey != "min/emb"){
                    let url = "https://i.imgur.com/\(imgurKey).jpg"
                    imgurUrlArray.append(url)
                }
                beautyString = String(lessBeauty)
            }
        }
        
        // 將重複的值去掉
        var dictInts = Dictionary<String, String>()
        for number in imgurUrlArray {
            dictInts[String(number)] = number
        }
        var result = [String]()
        for value in dictInts.values {
            result.append(value)
        }
        
        
        //        // 點擊連結的網址
        //        let imageButton = button(uri: "https://www.google.com.tw")
        //
        //        // 從陣列中隨機抽出圖片
        //        let column1 = column(imageUrl: result[randomInt(range: result.count)], action: imageButton)
        //        let column2 = column(imageUrl: result[randomInt(range: result.count)], action: imageButton)
        //        let column3 = column(imageUrl: result[randomInt(range: result.count)], action: imageButton)
        //
        //        var temp = template()
        //        temp.addColumn(relative: column1)
        //        temp.addColumn(relative: column2)
        //        temp.addColumn(relative: column3)
        //
        //        let carousel = imageCarousel(template: temp)
        //
        //        let encoder = JSONEncoder()
        //        let data = try! encoder.encode(carousel)
        //        guard let string = String(data: data, encoding: .utf8) else {
        //            return Response(status: .ok, body: "this message is not supported")
        //        }
        let mainPage = "https://www.ptt.cc/bbs/Beauty/index.html"
        //        let picture1 = result[randomInt(range: result.count)]
        //        let picture2 = result[randomInt(range: result.count)]
        //        let picture3 = result[randomInt(range: result.count)]
        
        try responseData.set("replyToken", replyToken)
        try responseData.set("messages", [
            ["type": "template",
             "altText": "this is a image carousel template",
             "template": [
                "type": "image_carousel",
                "columns": [
                    ["imageUrl": result[randomInt(range: result.count)],
                     "action": ["type": "uri",
                                "label": "Open",
                                "uri": mainPage]],
                    ["imageUrl": result[randomInt(range: result.count)],
                     "action": ["type": "uri",
                                "label": "Open",
                                "uri": mainPage]],
                    ["imageUrl": result[randomInt(range: result.count)],
                     "action": ["type": "uri",
                                "label": "Open",
                                "uri": mainPage]],
                    ["imageUrl": result[randomInt(range: result.count)],
                     "action": ["type": "uri",
                                "label": "Open",
                                "uri": mainPage]],
                    ["imageUrl": result[randomInt(range: result.count)],
                     "action": ["type": "uri",
                                "label": "Open",
                                "uri": mainPage]]
                ]
                ]]
            ])
        
        print(responseData)
        
        
    } else if (message.contains("黑人")||message.contains("歐郎")||message.contains("黑鬼")){
        
        try responseData.set("replyToken", replyToken)
        try responseData.set("messages", [
            ["type": "text", "text": "承翰歐巴，有人叫你～"]
            ])
    } else if (message == "你是誰"){
        try responseData.set("replyToken", replyToken)
        try responseData.set("messages", [
            ["type": "text", "text": "\(userID)"]
            ])
    }


    let response: Response = try drop.client.post(
        endpoint,
        query: ["name": "mybot"],
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ],
        responseData
    )

    print(response)
    return Response(status: .ok, body: "reply")
}




try drop.run()

