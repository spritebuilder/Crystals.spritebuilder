//
//  PauseLayer.m
//  Crystals
//
//  Created by Viktor on 8/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "PauseLayer.h"
#import "GameScene.h"

@implementation PauseLayer

- (void) pressedContinue:(CCButton*)button
{
    [[GameScene currentGameScene] pressedContinue];
}

- (void) pressedGiveUp:(CCButton*)button
{
    [[GameScene currentGameScene] pressedGiveUp];
}

@end
