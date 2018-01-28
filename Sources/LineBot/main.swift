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
    
    print(response)
    return Response(status: .ok, body: "reply")
}




try drop.run()

