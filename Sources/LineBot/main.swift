import Vapor


public func randomInt(range:Int) -> Int {
    #if os(Linux)
        return Glibc.random() % range
    #else
        return Int(arc4random_uniform(UInt32(range)))
    #endif
}

let drop = try Droplet()
let endpoint = "https://api.line.me/v2/bot/message/reply"
let accessToken = "uNha8IMsykz/XoGmQhuWyvqVc6Ta36vi1yVCx16jH6Dfwu17iaJrQXZqipY8fgvMrxrxvtNcRKpVpmP/XyUtewpgpm40oQFxPSbaZDUbqb+mKSydSvjDgtbBxnKD+w/VrLugyzamDrBmgG7lw4lV/wdB04t89/1O/w1cDnyilFU="

drop.get("hello") { req in
    print(req)
    return "Hello Vapor!!!"
}

drop.post("callback"){ req in
    print(req);
    
    guard let object = req.data["events"]?.array?.first?.object else{
        return Response(status: .ok, body: "this message is not supported")
    }
    
    guard var message = object["message"]?.object?["text"]?.string, let replyToken = object["replyToken"]?.string else{
        return Response(status: .ok, body: "this message is not supported")
    }
    
    print("-----------------");
    print(message);
    
    
    if (message.contains("黑人")){
        message = "是誰在講話？！"
    }
    
    var requestData: JSON = JSON()
    
    if (message == "抽"){
        try requestData.set("replyToken", replyToken)
        try requestData.set("messages", [
            ["type": "image",
             "originalContentUrl": "https://i.imgur.com/FYKYN6u.jpg",
             "previewImageUrl": "https://i.imgur.com/FYKYN6u.jpg"]
            ])
    } else if (message == "❤️"){
        
        let imgur = try drop.client.get("https://api.imgur.com/3/album/Ne2W5/images", query: [
            
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
        
        try requestData.set("replyToken", replyToken)
        try requestData.set("messages", [
            ["type": "image",
             "originalContentUrl": picture,
             "previewImageUrl": picture]
            ])
        
        
        
    } else if (message == "給我妹子"){
        
//        return Response(status: .ok, body: "reply")
        
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
            if(imgur.contains("公告")){
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
        
        // 從陣列中隨機抽出圖片
        let picture1 = result[randomInt(range: result.count)]
        let picture2 = result[randomInt(range: result.count)]
        let picture3 = result[randomInt(range: result.count)]
        
        try requestData.set("replyToken", replyToken)
        try requestData.set("messages", [
            ["type": "text", "text": "好的，老爺 我去物色一下妹子.."],
            ["type": "image",
             "originalContentUrl": picture1,
             "previewImageUrl": picture1
            ],["type": "image",
               "originalContentUrl": picture2,
               "previewImageUrl": picture2
            ],["type": "image",
               "originalContentUrl": picture3,
               "previewImageUrl": picture3
            ]])

        
    } else {
        try requestData.set("replyToken", replyToken)
        try requestData.set("messages", [
            ["type": "text", "text": message]
            ])
    }
    
    let response: Response = try drop.client.post(
        endpoint,
        query: ["name": "mybot"],
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ],
        requestData
    )
    
    return Response(status: .ok, body: "reply")
}




try drop.run()

