//
//  Sender.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/12/4.
//


import UIKit
import MessageKit
import Messages

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var messageId: Int
}
