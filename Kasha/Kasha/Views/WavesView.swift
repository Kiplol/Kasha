//
//  WavesView.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/7/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class WavesView: UIView {
    
    // MARK: - ivars
    @IBInspectable var playingWaveHeight: CGFloat = 20.0
    @IBInspectable var stoppedWaveHeight: CGFloat = 5.0
    @IBInspectable var speed: CGFloat = 1.0
    @IBInspectable var numberOfWaves: CGFloat = 2.0
    private var displayLink: CADisplayLink?
    @IBInspectable var waveColor: UIColor = .kashaPrimary
    private var isRunning: Bool = false
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.startDiplayLink()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            self.stopDisplayLink()
        }
    }
    
    func start() {
        guard !self.isRunning else {
            return
        }
        self.isRunning = true
    }
    
    func stop() {
        guard self.isRunning else {
            return
        }
        self.isRunning = false
    }
    
    private func startDiplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(WavesView.displayLinkTick))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    private func stopDisplayLink() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    @objc func displayLinkTick() {
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        
        let t: CGFloat = CGFloat(Date().timeIntervalSince1970)
        
        let firstPath = UIBezierPath()
        firstPath.move(to: CGPoint(x: 0.0, y: rect.height))
        let waveHeight = self.isRunning ? self.playingWaveHeight : self.stoppedWaveHeight
        let maxWaveHeight = max(self.playingWaveHeight, self.stoppedWaveHeight)
        
        var secondPathPoints: [CGPoint] = []
        
        let strideSize = max(1.0, width / 100.0)
        for x in stride(from: 0.0, through: width, by: strideSize) {
            //First wave
            let progress = x / width
            let angle = progress * (2.0 * CGFloat.pi * self.numberOfWaves)
            let y = (sin(angle + (t * self.speed)) * waveHeight) + maxWaveHeight
            firstPath.addLine(to: CGPoint(x: x, y: y))
            
            //Second wave
            let secondWaveAngle = progress * (2.0 * CGFloat.pi * self.numberOfWaves)
            let secondY = (cos(secondWaveAngle + (t * 1.75 * self.speed)) * waveHeight) + maxWaveHeight
            secondPathPoints.append(CGPoint(x: x, y: secondY))
        }
        firstPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
        firstPath.close()
        self.waveColor.alpha(0.5).setFill()
        firstPath.fill()
        
        let secondPath = UIBezierPath()
        secondPath.move(to: CGPoint(x: 0.0, y: rect.height))
        secondPathPoints.forEach {
            secondPath.addLine(to: $0)
        }
        secondPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
        secondPath.close()
        self.waveColor.setFill()
        secondPath.fill()
    }
    
}
