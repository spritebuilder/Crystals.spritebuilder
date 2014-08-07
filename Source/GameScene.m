//
//  GameScene.m
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "Crystal.h"
#import "Board.h"

#define REFLECTION_ANIM_FRAMES 1500

static __weak GameScene* _currentGameScene;

@implementation GameScene

+ (GameScene*) currentGameScene
{
    return _currentGameScene;
}

- (void) didLoadFromCCB
{
    _currentGameScene = self;
    
    self.board.paused = YES;
}

- (void) pressedPause:(CCButton*) sender
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}

- (void) fixedUpdate:(CCTime)delta
{
    float angle = _frame % REFLECTION_ANIM_FRAMES;
    angle = (angle / (float)REFLECTION_ANIM_FRAMES) * M_PI * 2.0;
    
    CGPoint offset = ccp(sinf(angle)*0.1, cosf(angle)*0.1);
    
    _reflectionMap.position = ccpAdd(ccp(0.5, 0.5), offset);
    
    _frame += 1;
}

- (void) startGame
{
    self.board.paused = NO;
}

- (void) onExit
{
    [Crystal cleanup];
    
    [super onExit];
}

@end
