//
//  Crystal.h
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Crystal : CCSprite
{
    BOOL _gameOver;
}


@property (nonatomic,readwrite) int type;
@property (nonatomic,readwrite) int x;
@property (nonatomic,readwrite) int y;

@property (nonatomic,assign) float speed;

@property (nonatomic,assign) float xSpeed;

@property (nonatomic,assign) BOOL hintMode;

+ (Crystal*) crystalOfType:(int)type;

+ (CCEffectBrightness*) sharedBrightnessHintEffect;

+ (void) cleanup;

- (void) setStartingSpeed;

- (void) setupGameOverSpeeds;

@end
