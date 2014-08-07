//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void) didLoadFromCCB
{
    [[CCDirector sharedDirector] setDisplayStats:YES];
}

- (void) pressedPlay:(CCButton*)button
{
    [self.animationManager runAnimationsForSequenceNamed:@"outro"];
}

- (void) outroCompleted
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"GameScene"]];
}

@end
