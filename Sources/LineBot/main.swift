import Vapor


let drop = try Droplet()
let endpoint = "https://api.line.me/v2/bot/message/reply"
let accessToken = "+/MorVuHNlwb49eAcx1XP3rLdHkJQ3RzNc20Gd8K2FE4+fRYQSUcoC/5JJ0LBWTZ6uj6lTIIn9hEMIc4LkGkyp2bHKfOS0J5/r2hAaty/Ooqeto9A2Swy4gPHsdX+r8GP0YB6fPQ1r7ITT4gg7LCkwdB04t89/1O/w1cDnyilFU="

drop.get("hello") { req in
    print(req)
    return "Hello Vapor!!!"
}

drop.post("callback"){ req in
    print(req);
    
    guard let object = req.data["events"]?.array?.first?.object else{
        return Response(status: .ok, body: "this message is not supported")
    }
    
    guard let message = object["message"]?.object?["text"]?.string, let replyToken = object["replyToken"]?.string else{
        return Response(status: .ok, body: "this message is not supported")
    }
    
    print("-----------------");
    print(message);
    
    var requestData: JSON = JSON()
    try requestData.set("replyToken", replyToken)
    try requestData.set("messages", [
        ["type": "text", "text": message]
        ])
    
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

