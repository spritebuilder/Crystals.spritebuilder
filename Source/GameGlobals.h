//
//  GameGlobals.h
//  Crystals
//
//  Created by Viktor on 8/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameGlobals : NSObject

@property (nonatomic,readonly) int highScore;
@property (nonatomic,assign) int lastScore;

+ (GameGlobals*) globals;

- (void) store;

@end
