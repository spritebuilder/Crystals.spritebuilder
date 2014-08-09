//
//  GameGlobals.m
//  Crystals
//
//  Created by Viktor on 8/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameGlobals.h"

static __strong GameGlobals* _globals;

@implementation GameGlobals

+ (GameGlobals*) globals
{
    if (!_globals)
    {
        _globals = [[GameGlobals alloc] init];
    }
    
    return _globals;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    [self load];
    
    return self;
}

- (void) load
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    
    _highScore = [[d objectForKey:@"highScore"] intValue];
    _lastScore = [[d objectForKey:@"lastScore"] intValue];
}

- (void) store
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    
    [d setObject:[NSNumber numberWithInt:_highScore] forKey:@"highScore"];
    [d setObject:[NSNumber numberWithInt:_lastScore] forKey:@"lastScore"];
}

- (void) setLastScore:(int)lastScore
{
    if (lastScore > _highScore)
    {
        _highScore = lastScore;
    }
    _lastScore = lastScore;
}

@end
