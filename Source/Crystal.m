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
static CCEffectReflection* _crystalHintEffect = NULL;
static CCEffectBrightness* _lightingEffect = NULL;

@implementation Crystal

+ (CCEffectBrightness*) sharedBrightnessHintEffect
{
    return _lightingEffect;
}

+ (CCEffect*) sharedCrystalEffect
{
    GameScene* gs = [GameScene currentGameScene];
    
    if (!_crystalEffect)
    {
        _crystalEffect = [CCEffectReflection effectWithShininess:1 environment:gs.reflectionMap];
        
        _crystalEffect.fresnelBias = 0.07;
        _crystalEffect.fresnelPower = 0.7;
    }
    
    return _crystalEffect;
}

+ (CCEffect*) sharedCrystalHintEffect
{
    GameScene* gs = [GameScene currentGameScene];
    
    if (!_crystalHintEffect)
    {
        CCEffectReflection *crystalEffect = [CCEffectReflection effectWithShininess:1 environment:gs.reflectionMap];
        
        crystalEffect.fresnelBias = 0.07;
        crystalEffect.fresnelPower = 0.7;
        
        _lightingEffect = [CCEffectBrightness effectWithBrightness:0.5];
        
        _crystalHintEffect = [CCEffectStack effects:crystalEffect,_lightingEffect, nil];
    }
    
    return _crystalHintEffect;
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

- (void) setHintMode:(BOOL)hintMode
{
    if (_hintMode != hintMode)
    {
        if (hintMode)
        {
            self.effect = [Crystal sharedCrystalHintEffect];
        }
        else
        {
            self.effect = [Crystal sharedCrystalEffect];
        }
        
        _hintMode = hintMode;
    }
}

@end
