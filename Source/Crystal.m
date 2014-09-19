//
//  Crystal.m
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Crystal.h"
#import "GameScene.h"

static CCEffectReflection* _crystalEffect = NULL;

@implementation Crystal

+ (CCEffect*) sharedCrystalEffect
{
    GameScene* gs = [GameScene currentGameScene];
    
    if (!_crystalEffect)
    {
//        _crystalEffect = [CCEffectReflection effectWithShininess:1 environment:gs.reflectionMap];
        
//        _crystalEffect.fresnelBias = 0.07;
//        _crystalEffect.fresnelPower = 0.7;
    }
    
    return _crystalEffect;
}

+ (void) cleanup
{
    _crystalEffect = NULL;
}

- (id) initWithType:(int)type
{
    self = [super initWithImageNamed:[NSString stringWithFormat:@"Sprites/crystal-%d.png", type]];
    
    if (!self) return NULL;
    
    // Setup glass effect
    self.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"Sprites/crystal-%d-normal.png", type]];
    
    self.effect = [Crystal sharedCrystalEffect];
    
    self.anchorPoint = ccp(0, 0);
    
    // Remember type
    _type = type;
    
    [self setStartingSpeed];
    
    return self;
}

- (void) setStartingSpeed
{
    _speed = -0.6;
}

+ (Crystal*) crystalOfType:(int)type
{
    return [[Crystal alloc] initWithType:type];
}

- (void) fixedUpdate:(CCTime)delta
{
    if (_gameOver)
    {
        _speed -= 0.1;
    }
    else
    {
        if (_speed < 0) _speed -= 0.6;
    }
}

- (void) setupGameOverSpeeds
{
    _speed = CCRANDOM_MINUS1_1() * 4;
    _xSpeed = CCRANDOM_MINUS1_1() * 4;
    
    _gameOver = YES;
}

@end
