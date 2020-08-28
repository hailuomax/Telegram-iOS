//
//  HLMenuInteraction.swift
//  TelegramUI#shared
//
//  Created by fan on 2020/4/24.
//

import Foundation


public class HLMenuInteraction {
    
    let sendMessageWithSignal: ([Any]?, Bool) -> Void
    
    let openGallery: () -> Void
    
    let mediaPickerWillOpen: ()->Void
    
    let mediaPickerWillClose: ()->Void
    
    let openCamera: ()->Void
    
    let openPhoto: ()->Void
    
    let openLocation: ()->Void
    
    let openContact: ()->Void
    
    let openFile: ()->Void
    
    let openRedPacket: ()->Void
    
    let openSuperRedRacket: ()->Void
    
    let openTransfer: ()->Void
    
    let openExchange: ()->Void
    
    let openPoll: ()->Void
    
    public init(sendMessageWithSignal:@escaping ([Any]?, Bool) -> Void ,
                openGallery:@escaping () -> Void,
                mediaPickerWillOpen:@escaping ()->Void,
                mediaPickerWillClose:@escaping ()->Void,
                openCamera:@escaping ()->Void,
                openPhoto:@escaping ()->Void,
                openLocation:@escaping ()->Void,
                openContact:@escaping ()->Void,
                openFile:@escaping ()->Void,
                openRedPacket:@escaping ()->Void,
                openSuperRedRacket:@escaping ()->Void,
                openTransfer:@escaping ()->Void,
                openExchange:@escaping ()->Void,
                openPoll:@escaping ()->Void)
    {
        self.sendMessageWithSignal = sendMessageWithSignal
        self.openGallery = openGallery
        self.mediaPickerWillOpen = mediaPickerWillOpen
        self.mediaPickerWillClose = mediaPickerWillClose
        self.openCamera = openCamera
        self.openPhoto = openPhoto
        self.openLocation = openLocation
        self.openContact = openContact
        self.openFile = openFile
        self.openRedPacket = openRedPacket
        self.openSuperRedRacket = openSuperRedRacket
        self.openTransfer = openTransfer
        self.openExchange = openExchange
        self.openPoll = openPoll
    }
    
    
}
