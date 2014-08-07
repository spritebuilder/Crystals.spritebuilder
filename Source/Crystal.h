//
//  Crystal.h
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Crystal : CCSprite

@property (nonatomic,readwrite) int type;
@property (nonatomic,readwrite) int x;
@property (nonatomic,readwrite) int y;

@property (nonatomic,assign) float speed;

+ (Crystal*) crystalOfType:(int)type;

+ (void) cleanup;

- (void) setStartingSpeed;

@end
