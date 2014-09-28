//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#if __CC_PLATFORM_IOS
#import "StoreKitDelegate.h"
#endif
#import "MainScene.h"
#import "GameGlobals.h"

@implementation MainScene

- (void) didLoadFromCCB
{
    [OALSimpleAudio sharedInstance];
    
    [[CCDirector sharedDirector] setDisplayStats:YES];
    
    // Popuplate score labels
    GameGlobals* g = [GameGlobals globals];
    
    _lblHighScore.string = [NSString stringWithFormat:@"%d",g.highScore];
    _lblLastScore.string = [NSString stringWithFormat:@"%d",g.lastScore];
    
#if __CC_PLATFORM_IOS
    [[StoreKitDelegate alloc] init];
#endif
}

- (void) pressedPlay:(CCButton*)button
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    [self.animationManager runAnimationsForSequenceNamed:@"outro"];
}

- (void) outroCompleted
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"GameScene"]];
}

@end
