//
//  Message_.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/12/4.
//

import UIKit
import MessageKit
import Messages
import InputBarAccessoryView

struct Message_: MessageType{
    // var channelId: String
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
