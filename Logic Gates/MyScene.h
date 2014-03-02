//
//  MyScene.h
//  Logic Gates
//

//  Copyright (c) 2014 Edward Peiliang Guo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Wire.h"

@class Wire;
@class SelectionSprite;
@interface MyScene : SKScene<wireProtocol>{
    CGPoint lastTouchLocation;
}

@property SKNode *dragingObject;
@property Wire* dragWire;
@property SKSpriteNode* ModeChanger;
@property SKSpriteNode* selectionMenu;
@property SKSpriteNode* selectSp;
@end
