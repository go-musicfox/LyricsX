//
//  LyricsHUDViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/10.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import EasyPreference

class LyricsHUDViewController: NSViewController {
    
    @IBOutlet weak var lyricsScrollView: ScrollLyricsView!
    
    dynamic var isTracking = true
    
    override func viewWillAppear() {
        view.window?.titlebarAppearsTransparent = true
        view.window?.titleVisibility = .hidden
        view.window?.styleMask.insert(.borderless)
        
        let accessory = self.storyboard?.instantiateController(withIdentifier: "LyricsHUDAccessory") as! LyricsHUDAccessoryViewController
        accessory.layoutAttribute = .right
        view.window?.addTitlebarAccessoryViewController(accessory)
        accessory.trackLyricsButton.bind(NSValueBinding, to: self, withKeyPath: "isTracking", options: nil)
        
        lyricsScrollView.setupTextContents(lyrics: appDelegate()?.mediaPlayerHelper.currentLyrics)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
        nc.addObserver(self, selector: #selector(handleLyricsChange), name: .LyricsChange, object: nil)
        nc.addObserver(self, selector: #selector(handleScrollViewWillStartScroll), name: .NSScrollViewWillStartLiveScroll, object: lyricsScrollView)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - handler
    
    func handleLyricsChange(_ n: Notification) {
        DispatchQueue.main.async {
            self.lyricsScrollView.setupTextContents(lyrics: appDelegate()?.mediaPlayerHelper.currentLyrics)
        }
    }
    
    func handlePositionChange(_ n: Notification) {
        guard isTracking else {
            return
        }
        
        guard let pos = n.userInfo?["position"] as? Double else {
            return
        }
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                context.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
                self.lyricsScrollView.scroll(position: pos)
            })
        }
    }
    
    func handleScrollViewWillStartScroll(_ n: Notification) {
        isTracking = false
    }
    
}

class LyricsHUDAccessoryViewController: NSTitlebarAccessoryViewController {
    
    @IBOutlet weak var trackLyricsButton: NSButton!
    
}
