//
//  MapFileScene.m
//  Logic Gates
//
//  Created by edguo on 2014-03-21.
//  Copyright (c) 2014 Edward Peiliang Guo. All rights reserved.
//

#import "MapFileScene.h"

@implementation MapFileScene{
    SKScene *mScene;
    CircuitMap* mMap;
    CGFloat yLength;
}
-(id)initWithSize:(CGSize)size MainScene:(SKScene*)mainScene Map:(CircuitMap*)map{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor yellowColor];
        
        mScene = mainScene;
        mMap = map;
        
        mMap.fileIOMenu = self;
        
        //BackButton
        self.backButton = [[SKSpriteNode alloc]initWithColor:[SKColor grayColor] size:CGSizeMake(45, 45)];
        self.backButton.position = CGPointMake(40, self.size.height - 40);
        [self addChild:self.backButton];
        
        //AddButton
        self.addButton = [[SKSpriteNode alloc]initWithColor:[SKColor blackColor] size:CGSizeMake(45, 45)];
        self.addButton.position = CGPointMake(40, 40);
        [self addChild:self.addButton];
        
        self.buttonMap = [SKNode node];
        [self addChild:self.buttonMap];
        
        [self performSelectorInBackground:@selector(setupButtons) withObject:nil];
        
    }
    return self;
}

-(void)setupButtons{
    CGFloat yPos = 0;
    CGSize buttonSize = CGSizeMake(self.size.width-120, 36);
    for (NSUInteger i = 1; i  < [mMap.filesList count]; i++) {
        NSString* name = [mMap.filesList objectAtIndex:i];
        ButtonSprite* button = [[ButtonSprite alloc]initWithName:name buttonID:i];
        button.size = buttonSize;
        button.position = CGPointMake(0, yPos);
        [self.buttonMap addChild:button];
        yPos -= 60.0;
        
        if (i == 1) {
            self.buttonMap.position = CGPointMake(self.size.width/2 + 40, self.size.height-30);
        }
    }
    yLength = -yPos;
}

-(void)didMoveToView:(SKView *)view{
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.swipeRecognizer = swipeGestureRecognizer;
    self.tapRecognizer = tapGestureRecognizer;
    
}

-(void)presentMainScene{
    [self.view removeGestureRecognizer:self.swipeRecognizer];
    [self.view removeGestureRecognizer:self.tapRecognizer];
    [self.view presentScene:mScene];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            [self presentMainScene];
        }
    }
}

-(void)buttonTouchUp:(NSUInteger)index{
    ButtonSprite* newSelectButton;
    
    for (ButtonSprite*button in self.buttonMap.children) {
        if (button.button_id>index && button.button_id<=self.selectButton.button_id) {
            SKAction* action = [SKAction moveByX:0 y:50 duration:0.2];
            [button runAction:action];
        } else if (self.selectButton){
            if (button.button_id<=index && button.button_id>self.selectButton.button_id){
                [button runAction:[SKAction moveByX:0 y:-50 duration:0.2]];
            }
        }
        if (button.button_id == index) {
            newSelectButton = button;
        }
    }
    if (index != 0) {
        if (index == self.selectButton.button_id) {
            self.selectButton = nil;
            SKNode* saveButton = [self childNodeWithName:@"save"];
            SKNode* loadButton = [self childNodeWithName:@"load"];
            SKNode* removeButton = [self childNodeWithName:@"remove"];
            
            SKAction* fade = [SKAction fadeOutWithDuration:0.2];
            SKAction* remove = [SKAction removeFromParent];
            SKAction* actions = [SKAction sequence:@[fade,remove]];
            
            [saveButton runAction:actions];
            [loadButton runAction:actions];
            [removeButton runAction:actions];
            
        } else {
            self.selectButton = newSelectButton;
            
            CGFloat posX = self.selectButton.position.x - self.selectButton.size.width/2 + 25;
            CGFloat posY = self.selectButton.position.y - self.selectButton.size.height/2 - 20;
            
            SKSpriteNode* saveButton = [SKSpriteNode spriteNodeWithImageNamed:@"save_button"];
            saveButton.name = @"save";
            saveButton.position = CGPointMake(posX, posY);
            [self.buttonMap addChild:saveButton];
            
            posX += 60;
            SKSpriteNode* loadButton = [SKSpriteNode spriteNodeWithImageNamed:@"load_button"];
            loadButton.name = @"load";
            loadButton.position = CGPointMake(posX, posY);
            [self.buttonMap addChild:loadButton];
            
            posX += 60;
            SKSpriteNode* removeButton = [SKSpriteNode spriteNodeWithImageNamed:@"remove_button"];
            removeButton.name = @"remove";
            removeButton.position = CGPointMake(posX, posY);
            [self.buttonMap addChild:removeButton];
        }
    }else{
        if (self.selectButton) {
            SKNode* saveButton = [self childNodeWithName:@"save"];
            SKNode* loadButton = [self childNodeWithName:@"load"];
            SKNode* removeButton = [self childNodeWithName:@"remove"];
            
            SKAction* fade = [SKAction fadeOutWithDuration:0.2];
            SKAction* remove = [SKAction removeFromParent];
            SKAction* actions = [SKAction sequence:@[fade,remove]];
            
            [saveButton runAction:actions];
            [loadButton runAction:actions];
            [removeButton runAction:actions];
        }
        self.selectButton = nil;
    }
}

-(void)setupAddAlertView{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"New Save File"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"cancel"
                                             otherButtonTitles:@"save", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"Enter a name";
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"New Save File"]) {
        if (buttonIndex == 1) {
            UITextField* textField = [alertView textFieldAtIndex:0];
            [self saveMapWithFileName:textField.text];
        }
        
    }
}

-(void)saveMapWithFileName:(NSString*)name{
    [mMap performSelectorInBackground:@selector(saveMap:) withObject:name];
}

-(void)loadMapWithFileName:(NSString*)name{
    [mMap killAllGates];
    [mMap performSelectorInBackground:@selector(loadMap:) withObject:name];
}

-(void)removeMapWithFileName:(NSString*)name{
    [mMap performSelectorInBackground:@selector(removeMapFile:) withObject:name];
}

-(void)handleTapFrom:(UITapGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint pointInScene = [self convertPointFromView:[recognizer locationInView:self.view]];
        SKNode* node = [self nodeAtPoint:pointInScene];
        if (node) {
            if ([node.name isEqualToString:@"BUTTON"]) {
                ButtonSprite* button;
                if ([node isKindOfClass:[ButtonSprite class]]) {
                    button = (ButtonSprite*)node;
                }else if([node isKindOfClass:[SKLabelNode class]]){
                    button = (ButtonSprite*)node.parent;
                }
                if (button) {
                    [self buttonTouchUp:button.button_id];
                }
            } else if ([node isEqual:self.addButton]){
                
                [self setupAddAlertView];
                
            } else if ([node isEqual:self.backButton]){
                
                [self presentMainScene];
                
            } else if ([node.name isEqualToString:@"save"] && self.selectButton){
                
                NSString*name = [mMap.filesList objectAtIndex:self.selectButton.button_id];
                [self saveMapWithFileName:name];
                
            } else if ([node.name isEqualToString:@"load"] && self.selectButton){
                
                NSString*name = [mMap.filesList objectAtIndex:self.selectButton.button_id];
                [self loadMapWithFileName:name];
                
            } else if ([node.name isEqualToString:@"remove"] && self.selectButton){
                
                NSString*name = [mMap.filesList objectAtIndex:self.selectButton.button_id];
                [self removeMapWithFileName:name];
                
            }
        }
        
    }
    
}

-(void)fileDidSave{
    
}

-(void)fileDidLoad{
    
}

-(void)filesListDidUpdate{
    
}

@end
