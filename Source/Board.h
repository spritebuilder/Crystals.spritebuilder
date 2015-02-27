//
//  Board.h
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

#define BOARD_WIDTH 8
#define BOARD_HEIGHT 8
#define CRYSTAL_SIZE 40

@class Crystal;

@interface Board : CCEffectNode
{
    // Game state
    Crystal* _board[BOARD_WIDTH][BOARD_HEIGHT];
    NSMutableArray* _fallingCol[BOARD_WIDTH];
    
    BOOL _crystalsLandedThisFrame;
    
    // Counting consecutive moves
    long _numConsecutiveMoves;
    long _lastMoveFrame;
    long _frame;
    
    // Bonus mode
    BOOL _bonusMode;
    long _bonusModeStartFrame;
    CCEffectBrightness* _bonusModeEffect;
    CCParticleSystem* _bonusParticles;
    
    // Game over
    BOOL _gameOver;
    
    // Score & Time
    int _score;
    NSMutableArray* _gameOverCrystals;
    BOOL _startedEndTimer;
    
    // Hint highlights
    BOOL _hintMode;
    NSArray* _hintCrystals;
    long _hintModeStartFrame;
}

@property (nonatomic,readonly) int score;

@end
