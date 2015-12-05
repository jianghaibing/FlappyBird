//
//  GameScene.swift
//  FlappyBird
//
//  Created by baby on 15/12/5.
//  Copyright (c) 2015年 baby. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var birdNode = SKSpriteNode()
    var bgNode = SKSpriteNode()
    var pipeTop = SKSpriteNode()
    var pipeBottom = SKSpriteNode()
    
    enum ColliderType:UInt32{
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameover = false
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameoverLabel = SKLabelNode()
    var movingObjects = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        
        setupBackground()
        setupBird()
        
        scoreLabel.position = CGPointMake(CGRectGetMidX(frame), frame.height - 70)
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(frame.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        NSTimer.scheduledTimerWithTimeInterval( 3, target: self, selector: "movePies", userInfo: nil, repeats: true)
    }
    
    func movePies(){
        
        let gapHeight = birdNode.size.height * 4
        let offset = CGFloat(arc4random_uniform(UInt32(frame.height/2))) - frame.height/4
        let pipeTopTexture = SKTexture(imageNamed: "pipe1")
        
        let movePipes = SKAction.moveByX(-frame.width * 2, y: 0, duration:NSTimeInterval(frame.width/100))
        let removePies = SKAction.removeFromParent()
        let moveAndRemovePies = SKAction.sequence([movePipes,removePies])
        
        pipeTop = SKSpriteNode(texture: pipeTopTexture)
        pipeTop.position = CGPointMake(CGRectGetMidX(frame) + frame.width, CGRectGetMidY(frame) + pipeTopTexture.size().height/2 + gapHeight/2 + offset)
        pipeTop.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTopTexture.size())
        pipeTop.physicsBody?.dynamic = false
        pipeTop.runAction(moveAndRemovePies)
        pipeTop.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipeTop.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipeTop.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        movingObjects.addChild(pipeTop)
        
        let pipeBottomTexture = SKTexture(imageNamed: "pipe2")
        pipeBottom = SKSpriteNode(texture: pipeBottomTexture)
        pipeBottom.position = CGPointMake(CGRectGetMidX(frame) + frame.width, CGRectGetMidY(frame) - pipeBottomTexture.size().height/2 - gapHeight/2 + offset)
        pipeBottom.physicsBody = SKPhysicsBody(rectangleOfSize: pipeBottomTexture.size())
        pipeBottom.physicsBody?.dynamic = false
        pipeBottom.runAction(moveAndRemovePies)
        pipeBottom.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipeBottom.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipeBottom.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        movingObjects.addChild(pipeBottom)
        
        let gap = SKNode()
        gap.position = CGPointMake(CGRectGetMidX(frame) + frame.width, frame.height/2 + offset)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeTop.size.width/2, gapHeight))
        gap.physicsBody?.dynamic = false
        gap.runAction(moveAndRemovePies)
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        movingObjects.addChild(gap)
        
    }
    
    func setupBackground(){
        let bgTexture = SKTexture(imageNamed: "bg")
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg,replaceBg]))
        for i in 0..<2 {
            bgNode = SKSpriteNode(texture: bgTexture)
            bgNode.position = CGPointMake(bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i), CGRectGetMidY(self.frame))
            bgNode.size.height = frame.height
            bgNode.zPosition = -5
            bgNode.runAction(moveBgForever)
            self.addChild(bgNode)
        }
    }
    
    func setupBird(){
        let birdTexture = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        birdNode = SKSpriteNode(texture: birdTexture)
        let animation = SKAction.animateWithTextures([birdTexture,birdTexture2], timePerFrame: 0.1)
        let makeBirdFlay = SKAction.repeatActionForever(animation)
        birdNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        birdNode.runAction(makeBirdFlay)
        birdNode.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        birdNode.physicsBody?.dynamic = true
        birdNode.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        birdNode.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        birdNode.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(birdNode)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue{
            score++
            scoreLabel.text = "\(score)"
        }else{
            if gameover == false{
                gameover = true
                gameoverLabel.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
                gameoverLabel.fontSize = 40
                gameoverLabel.text = "游戏结束，点击重玩！"
                gameoverLabel.zPosition = 5
                self.addChild(gameoverLabel)
                self.speed = 0
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameover == false{
            birdNode.physicsBody?.velocity = CGVectorMake(0, 0)
            birdNode.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        }else{
            gameover = false
            score = 0
            scoreLabel.text = "0"
            gameoverLabel.removeFromParent()
            movingObjects.removeAllChildren()
            setupBackground()
            birdNode.removeFromParent()
            setupBird()
            self.speed = 1
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
