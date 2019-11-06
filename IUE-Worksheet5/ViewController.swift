//
//  ViewController.swift
//  IUE-Worksheet5
//
//  Created by formando on 06/11/2019.
//  Copyright © 2019 pt.ipleiria. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
     
    
    @IBOutlet weak var bottomView: UIView!
    enum State {
        case closed
        case open
    }
    let bottomViewOpenedHeight: CGFloat = 400
    let bottomViewClosedHeight: CGFloat = 50.0
    var bottomViewIsOpened: Bool = false
    var nextBottomViewState: State {
        return bottomViewIsOpened ? .closed : .open }
    var runningAnimations = [UIViewPropertyAnimator]()
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
    }
    
    @IBAction func handlePinch(recognizer:UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(
                x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    @IBAction func handleRotate(recognizer:UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0 }
    }
    
    @IBAction func handleBottomViewTap(recognizer:UITapGestureRecognizer) {
        switch recognizer.state {
    case .ended:
        animateOrReverseRunningTransition(state: nextBottomViewState, duration: 0.9)
    default: break
        }
        
    }
    
    
    private func animateTransitionIfNeeded (state: State, duration:TimeInterval) {
        if runningAnimations.isEmpty {
        let frameAnimator = UIViewPropertyAnimator(duration: duration,
                                                   dampingRatio: 1) {
                                                    switch state {
                                                    case .open:
                                                        self.bottomView.frame.origin.y =
                                                            self.view.frame.height - self.bottomViewOpenedHeight
                                                    case .closed:
                                                        self.bottomView.frame.origin.y =
                                                            self.view.frame.height - (self.view.window?.safeAreaInsets.bottom ?? 0) -
                                                            self.bottomViewClosedHeight
                                                    }
        }
        frameAnimator.addCompletion({ _ in
            self.bottomViewIsOpened = !self.bottomViewIsOpened
            self.runningAnimations.removeAll()
            
        })
        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)
        }
        
    }
    
    private func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimations.isEmpty { animateTransitionIfNeeded(state: state, duration: duration)
        } else {
            bottomViewIsOpened = !bottomViewIsOpened
            for animator in runningAnimations {
                animator.isReversed = !animator.isReversed
                
            }
            
        }
        
    }
    
    var bottomViewAnimationsProgressWhenInterrupted:CGFloat = 0
    
  
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
       }
    
    
    @IBAction private func handleBottomPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextBottomViewState, duration: 0.9)
        case .changed:
            var fractionComplete = translation.y / bottomViewOpenedHeight
            fractionComplete = bottomViewIsOpened ? fractionComplete :
                -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default: break
        }
        
    }
    private func startInteractiveTransition(state:State, duration:TimeInterval) {
        if runningAnimations.isEmpty {
        animateTransitionIfNeeded(state: state, duration: duration)
            
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            bottomViewAnimationsProgressWhenInterrupted = animator.fractionComplete
        }
        
    }
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + bottomViewAnimationsProgressWhenInterrupted
       
         }
    }
   
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        }
    }
    
    
    
    
    
    

    
}

