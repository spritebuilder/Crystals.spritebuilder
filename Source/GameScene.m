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
#import "GameGlobals.h"

#define REFLECTION_ANIM_FRAMES 1500

static __weak GameScene* _currentGameScene;

#pragma mark Intialization

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

#pragma mark Callbacks from Buttons

- (void) pressedPause:(CCButton*) sender
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    self.board.paused = YES;
    self.board.userInteractionEnabled = NO;
    
    _pausedLayer.visible = YES;
}

- (void) pressedContinue
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    self.board.paused = NO;
    self.board.userInteractionEnabled = YES;
    
    _pausedLayer.visible = NO;
}

- (void) pressedGiveUp
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    [self.animationManager runAnimationsForSequenceNamed:@"outro"];
}

#pragma mark Callbacks from Timelines

- (void) startGame
{
    self.board.paused = NO;
}

- (void) exitToMainScene
{
    // Save score
    [GameGlobals globals].lastScore = _board.score;
    [[GameGlobals globals] store];
    
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}

#pragma mark Update

- (void) fixedUpdate:(CCTime)delta
{
    float angle = _frame % REFLECTION_ANIM_FRAMES;
    angle = (angle / (float)REFLECTION_ANIM_FRAMES) * M_PI * 2.0;
    
    CGPoint offset = ccp(sinf(angle)*0.1, cosf(angle)*0.1);
    
    _reflectionMap.position = ccpAdd(ccp(0.5, 0.5), offset);
    
    _frame += 1;
}

#pragma mark Cleanup

- (void) onExit
{
    [Crystal cleanup];
    
    [super onExit];
}

@end
