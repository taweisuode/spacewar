//
//  GameScene.swift
//  spacewar
//
//  Created by pengge on 15/8/4.
//  Copyright (c) 2015年 pengge. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    var backgroundPic = SKTexture(imageNamed: "background")
    var planeTexture = SKTexture(imageNamed: "Spaceship")//可以在Images.xcassets中找到默认飞船图片
    var EnemyTexture1 = SKTexture(imageNamed: "enemyplane")
    var Enemy1Bullet = SKTexture(imageNamed: "enemybullet1")
    var EnemyTexture2 = SKTexture(imageNamed: "enemyplane2")
    var Enemy2Bullet = SKTexture(imageNamed: "enemybullet2")
    var explosionTexture = SKTexture(imageNamed: "explosion")
    var bombTexture = SKTexture(imageNamed: "bomb")
    var bossplaneTexture = SKTexture(imageNamed: "bossplane")
    //var plane:SKSpriteNode! 要加上'!'不然会报class ‘GamesScene’ has no initializers
    //!的意思是该变量一定不是nil的值
    var plane:SKSpriteNode!
    var Enemyplane1:SKSpriteNode!
    var Enemyplane2:SKSpriteNode!
    var bossplane:SKSpriteNode!
    var isTouched = false
    var timer = NSTimer() //make a timer variable, but don't do anything yet
    let tipstimeInterval:NSTimeInterval = 2.0  //tips消失的时间间隔
    var bulletTime:NSTimeInterval = 0.1   //子弹发射时间间隔
    var lastBullet:NSTimeInterval = 0     //上次发射的时间点
    var Enemy1Time:NSTimeInterval  = 0    //敌机刷新的时间
    var Enemy2Time:NSTimeInterval  = 0    //敌机刷新的时间
    var lastEnemy1:NSTimeInterval  = 0    //上次敌机出现的时间
    var Enemy1BulletTime:NSTimeInterval = 1  //敌机1子弹发射的时间
    var Enemy2BulletTime:NSTimeInterval = 1  //敌机2子弹发射的时间
    var lastEnemy2:NSTimeInterval  = 0    //上次敌机出现的时间
    var LastEnemy1Bullet:NSTimeInterval = 0   //上次敌机1子弹发射的时间点
    var LastEnemy2Bullet:NSTimeInterval = 0   //上次敌机2子弹发射的时间点
    var explodeTime:NSTimeInterval = 0.5  //爆炸持续的时间
    var toucheGap = CGPoint(x: 0, y: 0)
    var score:UInt32 = 0    // 分数初始化
    var scoreLabel:SKLabelNode!
    var tipLabel1:SKLabelNode!
    var gameOver = false
    //添加碰撞标记
    let PlayerCategory:UInt32 = 1<<1
    let BulletCategory:UInt32 = 1<<2
    let EnemyCategory1:UInt32 = 1<<3
    let EnemyBulletCategory:UInt32 = 1<<4
    let bossplaneCategory:UInt32  = 1<<5
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
        */
        //共用一个纹理   公用一个精灵。。
        //var background = SKSpriteNode(texture: backgroundPic)
        //background.position = CGPointMake(size.width/2,size.height/2+150)
        //var screen = UIScreen.mainScreen()
        //println("screen width:\(screen.bounds.size.width),height:\(screen.bounds.size.height)")
        //屏幕长宽  320:568   该背景长宽   320:480
        //println("board width:\(background.size.width),height:\(background.size.height)")
        //background.setScale(screen.bounds.size.width/background.size.width*3)
        //boardSize = spriteBoard.size
        //self.addChild(background)
        //self.background
        //self.addChild(background)
        plane = SKSpriteNode(texture: planeTexture)
        //var plane = SKSpriteNode(imageNamed: "Spaceship")
        plane.position = CGPointMake(size.width * 0.5, size.height * 0.1)
        //添加精灵到页面上
        plane.name = "plane"
        //给我方战机添加物理效果
        plane.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(100,100))//创建物理盒
        plane.physicsBody?.categoryBitMask = PlayerCategory //所属标记
        plane.physicsBody?.collisionBitMask = 0   //碰撞标记
        plane.physicsBody?.contactTestBitMask = EnemyCategory1  //碰撞通知标记
        //plane.physicsBody?.contactTestBitMask = EnemyCategory2  //碰撞通知标记
        self.addChild(plane)
        //plane.xScale是横轴缩放值   
        //plane.yScale是纵轴缩放值
        //plane.setScale()同时设置横轴纵轴
        plane.setScale(0.5)
        //表示碰撞检测代理为当前世界盒，并且重力为0，保证任何物体不会向下掉落。
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0,0)
        scoreLabel = SKLabelNode(text: "SCORE:0")
        scoreLabel.position = CGPointMake(size.width * 0.1, size.height - 50)
        scoreLabel.fontColor = UIColor.greenColor()
        addChild(scoreLabel)
        let Bomb1 = SKSpriteNode(texture: bombTexture)
        //println(count(SKSpriteNode(texture: bombTexture));
        Bomb1.position = CGPointMake(size.width * 0.1 - 50,size.height * 0.1 - 50)
        //Bomb.setScale(0.5)
        Bomb1.name = "Bomb1"
        addChild(Bomb1)
        plane.runAction(SKAction.sequence([SKAction.waitForDuration(10), SKAction.runBlock({
            self.create_tips1()
            //self.addChild(Bomb1)
        })]))
        plane.runAction(SKAction.sequence([SKAction.waitForDuration(20), SKAction.runBlock({
            self.create_tips2()
            //self.addChild(Bomb1)
            self.runAction(SKAction.sequence([SKAction.waitForDuration(5), SKAction.runBlock({
                //self.addChild(Bomb1)
                self.create_bossplane()
            })]))
        })]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        /*
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        
        }*/
        let location:CGPoint! = (touches as NSSet).anyObject()?.locationInNode(self)
        //println(location)
        toucheGap = CGPoint(x: location.x - plane.position.x, y: location.y - plane.position.y)
        
        let node = self.nodeAtPoint(location)
        if(node.name == "Bomb1")
        {
            //println("点到炸弹了")
            clearAllEnemy() //手指点击到飞机
            //Bomb4.removeFromParent()
        }
        
        //let node = self.nodeAtPoint(location)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    /*    if isTouched
        {
            var location:CGPoint! = (touches as NSSet).anyObject()?.locationInNode(self)
            plane.position = CGPointMake(location.x,location.y)
        }
    */
        let location:CGPoint! = (touches as NSSet).anyObject()?.locationInNode(self)
        let xDir = clamp(location.x - toucheGap.x, min: 0, max: size.width)
        let yDir = clamp(location.y - toucheGap.y, min: 0, max: size.height)
        plane.position = CGPoint(x: xDir,y: yDir)
        //plane.position = CGPoint(x:location.x - toucheGap.x,y:location.y - toucheGap.y)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //isTouched = false
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //添加子弹（创建一个shape精灵）
        //println(currentTime)
        if(currentTime > lastBullet + bulletTime && !gameOver)
        {
            lastBullet = currentTime
            createbullet()
        }
        //更新敌机1
        if(currentTime >= lastEnemy1 + Enemy1Time && !gameOver)
        {
            lastEnemy1 = currentTime
            Enemy1Time = NSTimeInterval(arc4random() % 20 + 5) / 10
            createEnemy1()
        }
        //敌机1子弹发射次数
        if(currentTime >= LastEnemy1Bullet + Enemy1BulletTime && !gameOver)
        {
            LastEnemy1Bullet = currentTime
            EnemyBullet1()
        }
        //更新敌机2
        if(currentTime >= lastEnemy2 + Enemy2Time && !gameOver)
        {
            lastEnemy2 = currentTime
            Enemy2Time = NSTimeInterval(arc4random() % 20 + 5) / 6
            createEnemy2()
        }
        //敌机2子弹发射次数
        if(currentTime >= LastEnemy2Bullet + Enemy2BulletTime && !gameOver)
        {
            LastEnemy2Bullet = currentTime
            EnemyBullet2()
        }

        //序列中两个动作，一个是竖向位移场景高度那么长的距离，正值向上负值向下，保证子弹至少能打到屏幕以外才会消失，第二个动作则是将其从场景里移除，同时也就被销毁了。
    }
    //该方法用来在碰撞发生时进行操作，首先进行判断，碰撞涉及的两个标记，是否是子弹和敌人标记。如果是，就杀死一个敌人，移除相关的子弹和击中的敌人。跑起来看看吧，已经比较完整了~
    func didBeginContact(contact: SKPhysicsContact) {
        /*
        if(contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BulletCategory | EnemyCategory1)
        {
            //var contactPoint: CGPoint
            //contactPoint 为记录碰撞物理的位置（x,y）标识
            explode(contact.contactPoint.x,location_y:contact.contactPoint.y)
            //添加分数
            score++
            scoreLabel.text = "SCORE:\(score)"
            //将移除子弹跟敌机
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
        */
        if(contact.bodyA.node?.name == "Bullet" && contact.bodyB.node?.name == "Enemy1")
        {
            explode(contact.contactPoint.x,location_y:contact.contactPoint.y)
            //添加分数
            score = score+100
            scoreLabel.text = "SCORE:\(score)"
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
        }
        if(contact.bodyA.node?.name == "Bullet"  && contact.bodyB.node?.name ==  "Enemy2")
        {
            explode(contact.contactPoint.x,location_y:contact.contactPoint.y)
            //添加分数
            score = score+200
            scoreLabel.text = "SCORE:\(score)"
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
        /*
        if(contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BulletCategory | EnemyCategory2)
        {
            explode(contact.contactPoint.x,location_y:contact.contactPoint.y)
            //添加分数
            score = score+2
            scoreLabel.text = "SCORE:\(score)"
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }*/
        if((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == PlayerCategory | EnemyCategory1) || (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == PlayerCategory | EnemyBulletCategory))
        {
            print("你输了", appendNewline: false)
            explode(contact.contactPoint.x,location_y:contact.contactPoint.y)
            gameOver = true
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            runAction(SKAction.sequence([SKAction.waitForDuration(3), SKAction.runBlock({
                self.resetGame()
            })]))
        }
        /*
        if(contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == PlayerCategory | EnemyCategory2)
        {
            print("你输了");
            explode(contact.contactPoint.x,location_y:contact.contactPoint.y)
            gameOver = true
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            runAction(SKAction.sequence([SKAction.waitForDuration(3), SKAction.runBlock({
                self.resetGame()
            })]))
        }*/
    }
    //飞机无法超过边界的判断
    func clamp(x:CGFloat,min:CGFloat,max:CGFloat) -> CGFloat
    {
        if x <= min
        {
            return min
        }else if x >= max
        {
            return max
        }else
        {
            return x
        }
    }
    //发射子弹的函数
    func createbullet()
    {
        let bullet = SKShapeNode(rectOfSize: CGSizeMake(5,5))
        bullet.position = CGPointMake(plane.position.x,plane.position.y+50)
        bullet.strokeColor = UIColor.clearColor()
        bullet.fillColor = UIColor.greenColor()
        bullet.name = "Bullet"
        //给子弹添加物理效果
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,10))//创建物理盒
        bullet.physicsBody?.categoryBitMask = BulletCategory //所属标记
        bullet.physicsBody?.collisionBitMask = 0   //碰撞标记
        bullet.physicsBody?.contactTestBitMask = EnemyCategory1  //碰撞通知标记
        //bullet.physicsBody?.contactTestBitMask = EnemyCategory2  //碰撞通知标记
        //碰撞消息的产生不受碰撞标记设置的影响，碰撞标记只关系到是否模拟碰撞效果。物理盒大小我们可以自己设定，如果使用了纹理，也可以用纹理的size属性进行设置，就比如接下来的敌人物理盒创建。
        addChild(bullet)
        //让子弹飞一会
        bullet.runAction(SKAction.sequence([SKAction.moveByX(0, y:size.height, duration: 2),
            SKAction.removeFromParent()]))
    }
    //创建敌机1
    func createEnemy1()
    {
        Enemyplane1 = SKSpriteNode(texture: EnemyTexture1)
        let randomX = CGFloat(arc4random()) % size.width
        Enemyplane1.position = CGPointMake(randomX,size.height)
        Enemyplane1.name = "Enemy1"
        //同样 给敌机物理效果
        Enemyplane1.physicsBody = SKPhysicsBody(rectangleOfSize: EnemyTexture1.size())
        Enemyplane1.physicsBody?.categoryBitMask = EnemyCategory1
        Enemyplane1.physicsBody?.collisionBitMask = 0
        Enemyplane1.physicsBody?.contactTestBitMask = PlayerCategory
        Enemyplane1.physicsBody?.contactTestBitMask = BulletCategory
        addChild(Enemyplane1)
        //让敌机飞 这是个队列  先是沿Y轴副方向飞  飞完耗时4秒  然后再删除该精灵
        Enemyplane1.runAction(SKAction.sequence([SKAction.moveByX(0, y:-size.height, duration: 4),
            SKAction.removeFromParent()]))
    }
    //创建敌机1的子弹
    func EnemyBullet1()
    {
        let bullet = SKSpriteNode(texture: Enemy1Bullet)
        bullet.position = CGPointMake(Enemyplane1.position.x,Enemyplane1.position.y-50)
        bullet.name = "Enemy1Bullet"
        //给子弹添加物理效果
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,10))//创建物理盒
        bullet.physicsBody?.categoryBitMask = EnemyBulletCategory //所属敌机子弹标记
        bullet.physicsBody?.collisionBitMask = 0   //碰撞标记
        bullet.physicsBody?.contactTestBitMask = PlayerCategory  //碰撞通知标记
        //bullet.physicsBody?.contactTestBitMask = EnemyCategory2  //碰撞通知标记
        //碰撞消息的产生不受碰撞标记设置的影响，碰撞标记只关系到是否模拟碰撞效果。物理盒大小我们可以自己设定，如果使用了纹理，也可以用纹理的size属性进行设置，就比如接下来的敌人物理盒创建。
        addChild(bullet)
        //让子弹飞一会
        bullet.runAction(SKAction.sequence([SKAction.moveByX(0, y: -size.height, duration: 2),
            SKAction.removeFromParent()]))
    }
    //创建敌机2
    func createEnemy2()
    {
        Enemyplane2 = SKSpriteNode(texture: EnemyTexture2)
        let randomX = CGFloat(arc4random()) % size.width
        Enemyplane2.position = CGPointMake(randomX,size.height)
        Enemyplane2.name = "Enemy2"
        //同样 给敌机物理效果
        Enemyplane2.physicsBody = SKPhysicsBody(rectangleOfSize: EnemyTexture2.size())
        Enemyplane2.physicsBody?.categoryBitMask = EnemyCategory1
        Enemyplane2.physicsBody?.collisionBitMask = 0
        Enemyplane2.physicsBody?.contactTestBitMask = BulletCategory
        Enemyplane2.physicsBody?.contactTestBitMask = PlayerCategory
        addChild(Enemyplane2)
        //让敌机飞 这是个队列  先是沿Y轴副方向飞  飞完耗时6秒  然后再删除该精灵
        Enemyplane2.runAction(SKAction.sequence([SKAction.moveByX(0, y:-size.height, duration: 6),
            SKAction.removeFromParent()]))
    }
    //创建敌机2的子弹  每次发三个  左中右散发
    func EnemyBullet2()
    {
        let bullet = SKSpriteNode(texture: Enemy2Bullet)
        bullet.position = CGPointMake(Enemyplane2.position.x,Enemyplane2.position.y-50)
        bullet.name = "Enemy2Bullet"
        //给子弹添加物理效果
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,10))//创建物理盒
        bullet.physicsBody?.categoryBitMask = EnemyBulletCategory //所属标记
        bullet.physicsBody?.collisionBitMask = 0   //碰撞标记
        bullet.physicsBody?.contactTestBitMask = PlayerCategory  //碰撞通知标记
        //bullet.physicsBody?.contactTestBitMask = EnemyCategory2  //碰撞通知标记
        //碰撞消息的产生不受碰撞标记设置的影响，碰撞标记只关系到是否模拟碰撞效果。物理盒大小我们可以自己设定，如果使用了纹理，也可以用纹理的size属性进行设置，就比如接下来的敌人物理盒创建。
        addChild(bullet)
        //让子弹飞一会
        bullet.runAction(SKAction.sequence([SKAction.moveByX(-size.width, y:-size.height, duration: 2),
            SKAction.removeFromParent()]))
        
        let bullet1 = SKSpriteNode(texture: Enemy2Bullet)
        bullet1.position = CGPointMake(Enemyplane2.position.x,Enemyplane2.position.y-50)
        bullet1.name = "Enemy2Bullet"
        //给子弹添加物理效果
        bullet1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,10))//创建物理盒
        bullet1.physicsBody?.categoryBitMask = EnemyBulletCategory //所属标记
        bullet1.physicsBody?.collisionBitMask = 0   //碰撞标记
        bullet1.physicsBody?.contactTestBitMask = PlayerCategory  //碰撞通知标记
        //bullet.physicsBody?.contactTestBitMask = EnemyCategory2  //碰撞通知标记
        //碰撞消息的产生不受碰撞标记设置的影响，碰撞标记只关系到是否模拟碰撞效果。物理盒大小我们可以自己设定，如果使用了纹理，也可以用纹理的size属性进行设置，就比如接下来的敌人物理盒创建。
        addChild(bullet1)
        //让子弹飞一会
        bullet1.runAction(SKAction.sequence([SKAction.moveByX(0, y:-size.height, duration: 2),
            SKAction.removeFromParent()]))
        
        let bullet2 = SKSpriteNode(texture: Enemy2Bullet)
        bullet2.position = CGPointMake(Enemyplane2.position.x,Enemyplane2.position.y-50)
        bullet2.name = "Enemy2Bullet"
        //给子弹添加物理效果
        bullet2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,10))//创建物理盒
        bullet2.physicsBody?.categoryBitMask = EnemyBulletCategory //所属标记
        bullet2.physicsBody?.collisionBitMask = 0   //碰撞标记
        bullet2.physicsBody?.contactTestBitMask = PlayerCategory  //碰撞通知标记
        //bullet.physicsBody?.contactTestBitMask = EnemyCategory2  //碰撞通知标记
        //碰撞消息的产生不受碰撞标记设置的影响，碰撞标记只关系到是否模拟碰撞效果。物理盒大小我们可以自己设定，如果使用了纹理，也可以用纹理的size属性进行设置，就比如接下来的敌人物理盒创建。
        addChild(bullet2)
        //让子弹飞一会
    bullet2.runAction(SKAction.sequence([SKAction.moveByX(size.width, y:-size.height, duration: 2),
            SKAction.removeFromParent()]))
    }
    //游戏经过多久就会产生个tips
    func create_tips1()
    {
        tipLabel1 = SKLabelNode(text: "tips:you can tap the Bomb to clean all Enemy!")
        tipLabel1.fontSize = 35
        tipLabel1.position = CGPointMake(size.width * 0.5, size.height - 100)
        tipLabel1.fontColor = UIColor.yellowColor()
        addChild(tipLabel1)
        timer = NSTimer.scheduledTimerWithTimeInterval(tipstimeInterval,
            target: self,
            selector: "timerDidEnd:",
            userInfo: nil,
            repeats: false)
        //runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.runBlock({
          //  self.removeFromParent()
        //})]))
    }

    func create_tips2()
    {
        tipLabel1 = SKLabelNode(text: "warming!!The boss is coming!!")
        tipLabel1.fontSize = 40
        tipLabel1.position = CGPointMake(size.width * 0.5, size.height - 100)
        tipLabel1.fontColor = UIColor.redColor()
        addChild(tipLabel1)
        timer = NSTimer.scheduledTimerWithTimeInterval(tipstimeInterval,target: self,selector:"timerDidEnd:",userInfo: nil,repeats: false)
    }
    //经过多久然后让tips消失
    func timerDidEnd(timer:NSTimer){
        //println("hha")
        tipLabel1.removeFromParent()
        //first iteration of timer
        //timerLabel.text = timer.userInfo as? String
    }
    func update() {
        // Something cool
        self.removeFromParent()
    }
    func create_bossplane()
    {
        let bossplane = SKSpriteNode(texture: bossplaneTexture)
        //var randomX = CGFloat(arc4random()) % size.width
        bossplane.position = CGPointMake(size.width * 0.5,size.height - 100)
        bossplane.name = "bossplane"
        bossplane.setScale(3)
        //同样 给敌机物理效果
        bossplane.physicsBody = SKPhysicsBody(rectangleOfSize: EnemyTexture2.size())
        bossplane.physicsBody?.categoryBitMask = bossplaneCategory
        bossplane.physicsBody?.collisionBitMask = 0
        bossplane.physicsBody?.contactTestBitMask = BulletCategory
        bossplane.physicsBody?.contactTestBitMask = PlayerCategory
        addChild(bossplane)

        //让敌机飞 这是个队列  先是沿Y轴副方向飞  飞完耗时6秒  然后再删除该精灵
        //Enemyplane2.runAction(SKAction.sequence([SKAction.moveByX(0, y:-size.height, duration: 6),
        //   SKAction.removeFromParent()]))
    }

    func clearAllEnemy()
    {
        //removeChildrenInArray(planeTexture)
        removeAllChildren()
        score = score + 1000
        scoreLabel.text = "SCORE:\(score)"
        removeAllChildren()
        scoreLabel.position = CGPointMake(size.width * 0.1, size.height - 50)
        scoreLabel.fontColor = UIColor.greenColor()
        addChild(scoreLabel)
        plane.position = CGPointMake(size.width * 0.5, size.height * 0.1)
        self.addChild(plane)
        plane.runAction(SKAction.sequence([SKAction.waitForDuration(10), SKAction.runBlock({
            self.create_tips1()
        })]))
        plane.runAction(SKAction.sequence([SKAction.waitForDuration(20), SKAction.runBlock({
            self.create_tips2()
            self.create_bossplane()
            //self.addChild(Bomb1)
        })]))

        
    }
    //子弹跟敌机碰撞时产生爆炸效果的方法
    func explode(location_x:CGFloat,location_y:CGFloat)
    {
        let explosion = SKSpriteNode(texture: explosionTexture)
        explosion.position = CGPointMake(location_x, location_y)
        addChild(explosion)
        //经过explodeTime的时间 然后爆炸精灵消失
        explosion.runAction(SKAction.sequence([SKAction.waitForDuration(explodeTime), SKAction.runBlock({
            explosion.removeFromParent()
        })]))
    }
    //重置游戏 将分数重置，然后移除所有的精灵  然后重新放置我方飞机的位置
    func resetGame()
    {
        gameOver = false
        score = 0
        scoreLabel.text = "SCORE:\(score)"
        removeAllChildren()
        scoreLabel.position = CGPointMake(size.width * 0.1, size.height - 50)
        scoreLabel.fontColor = UIColor.greenColor()
        addChild(scoreLabel)
        plane.position = CGPointMake(size.width * 0.5, size.height * 0.1)
        self.addChild(plane)
        plane.runAction(SKAction.sequence([SKAction.waitForDuration(10), SKAction.runBlock({
            self.create_tips1()
        })]))
        plane.runAction(SKAction.sequence([SKAction.waitForDuration(20), SKAction.runBlock({
            self.create_tips2()
            self.create_bossplane()
            //self.addChild(Bomb1)
        })]))
    }

}
