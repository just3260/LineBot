import Vapor


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
             "originalContentUrl": "https://evobsession.com/wp-content/uploads/2017/01/Tesla-Model-3-red.png",
             "previewImageUrl": "https://www.google.com.tw/url?sa=i&rct=j&q=&esrc=s&source=images&cd=&cad=rja&uact=8&ved=0ahUKEwi_94uZ5PjYAhXKyrwKHSzYCjsQjRwIBw&url=https%3A%2F%2Feucbeniki.sio.si%2Ffizika9%2F174%2Findex4.html&psig=AOvVaw2xDZL6ry45eRC9o7hQZ-cF&ust=1517164442331891"]
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

