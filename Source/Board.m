//
//  Board.m
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Board.h"
#import "GameScene.h"
#import "Crystal.h"

#define FRAMES_UNTIL_CONSECUTIVE_MOVES_RESET 60
#define FRAMES_UNTIL_HINT 180
#define MAX_CONSECUTIVE_MOVES 5
#define BONUS_MODE_NUM_CYCLE_FRAMES 60
#define GAME_DURATION (60 * 60 + 130)

@implementation Board

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    for (int i = 0; i < BOARD_WIDTH; i++)
    {
        _fallingCol[i] = [NSMutableArray array];
        
        for (int j = 0; j < BOARD_HEIGHT; j++)
        {
            _board[i][j] = NULL;
        }
    }
    
    _gameOverCrystals = [NSMutableArray array];
    
    return self;
}

- (void) didLoadFromCCB
{
    self.userInteractionEnabled = YES;
    _bonusModeEffect = [CCEffectBrightness effectWithBrightness:0.0];
    
    _bonusParticles.zOrder = 2;
    [_bonusParticles stopSystem];
    
    [self resetScore];
}

- (void) fixedUpdate:(CCTime)delta
{
    if (_gameOver)
    {
        [self animateGameOver];
        return;
    }
    
    _crystalsLandedThisFrame = NO;
    
    for (int i = 0; i < BOARD_WIDTH; i++)
    {
        // Add crystals
        if ([self numCrystalsInCol:i] < BOARD_HEIGHT)
        {
            // There is space to add crystals
            float distanceFromTop = (BOARD_HEIGHT * CRYSTAL_SIZE) - [self topCrystalPosInCol:i];
            if (distanceFromTop >= CRYSTAL_SIZE)
            {
                // We can add a falling crystal
                [self addCrystalInCol:i];
            }
        }
        
        // Move falling crystals
        [self moveFallingCrystalsInCol:i];
        
        [self solidifyCrystalsInCol:i];
    }
    
    // Check for possible moves
    if (_crystalsLandedThisFrame && ![self hasPossibleMoves])
    {
        [self makePossibleMove];
    }
    
    // Play sounds for crystals that's landing
    if (_crystalsLandedThisFrame)
    {
        int num = CCRANDOM_0_1()*4;
        [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"Sounds/tap-%d.wav",num]];
    }
    
    // Reset consecutive moves if player plays to slow
    if (_frame - _lastMoveFrame > FRAMES_UNTIL_CONSECUTIVE_MOVES_RESET)
    {
        _numConsecutiveMoves = 0;
        [self endBonusMode];
    }
    
    // Animate bonus mode
    [self animateBonusMode];
    
    [self updateTimeDisplay];
    
    if (_frame - _lastMoveFrame > FRAMES_UNTIL_HINT)
    {
        [self startHintMode];
    }
    
    [self animateHintMode];
    
    // Increment frame count
    _frame++;
}

#pragma mark Handle Touches
- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint loc = [touch locationInNode:self];
    
    // Calc x and y in matrix
    int x = ((int)loc.x)/CRYSTAL_SIZE;
    int y = ((int)loc.y)/CRYSTAL_SIZE;
    
    // Find the crystals connected to the touch
    NSArray* crystals = [self connectedCrystalsAtPosX:x Y:y];
    
    if (crystals.count >= 3)
    {
        // End hint mode
        [self endHintMode];
        
        [self removeCrystals:crystals];
        
        // Increment consecutive moves
        _numConsecutiveMoves++;
        if (_numConsecutiveMoves > MAX_CONSECUTIVE_MOVES) _numConsecutiveMoves = MAX_CONSECUTIVE_MOVES;
        
        _lastMoveFrame = _frame;
        
        // Play sound effect
        [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"Sounds/gem-%d.wav", (int)_numConsecutiveMoves-1]];
        
        if (_numConsecutiveMoves == MAX_CONSECUTIVE_MOVES && !_bonusMode)
        {
            [self startBonusMode];
        }
        
        // Add score
        int score = (int)crystals.count;
        if (_bonusMode) score *= 3;
        
        [self addScore:score];
    }
    else
    {
        // Tapped a non-combination
        _numConsecutiveMoves = 0;
        [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/miss.wav"];
        
        [self endBonusMode];
    }
}

#pragma mark Game Modes

- (void) startBonusMode
{
    _bonusMode = YES;
    
    self.effect = _bonusModeEffect;
    _bonusModeStartFrame = _frame;
    
    [_bonusParticles resetSystem];
}

- (void) endBonusMode
{
    _bonusMode = NO;
    
    [_bonusParticles stopSystem];
}

- (void) animateBonusMode
{
    if (!_bonusMode)
    {
        if (self.effect)
        {
            // Fade out the effect
            float brighness = _bonusModeEffect.brightness;
            
            brighness -= 0.5 / (float)BONUS_MODE_NUM_CYCLE_FRAMES;
            
            if (brighness > 0)
            {
                _bonusModeEffect.brightness = brighness;
            }
            else
            {
                self.effect = NULL;
            }
        }
        
        return;
    }
    
    long frame = _frame - _bonusModeStartFrame;
    
    // Normalized position in brightness cycle
    float cyclePos = frame % BONUS_MODE_NUM_CYCLE_FRAMES;
    cyclePos = cyclePos / (float) BONUS_MODE_NUM_CYCLE_FRAMES;
    
    if (cyclePos < 0.5)
    {
        _bonusModeEffect.brightness = cyclePos;
    }
    else
    {
        _bonusModeEffect.brightness = 1.0 - cyclePos;
    }
}

- (void) startHintMode
{
    if (_hintMode) return;
    
    for (Crystal* crystal in _hintCrystals)
    {
        crystal.hintMode = YES;
    }
    
    _hintMode = YES;
    _hintModeStartFrame = _frame;
}

- (void) animateHintMode
{
    if (!_hintMode) return;
    
    long frame = _frame - _hintModeStartFrame;
    
    // Normalized position in brightness cycle
    float cyclePos = frame % BONUS_MODE_NUM_CYCLE_FRAMES;
    cyclePos = cyclePos / (float) BONUS_MODE_NUM_CYCLE_FRAMES;
    
    if (cyclePos < 0.5)
    {
        [Crystal sharedBrightnessHintEffect].brightness = cyclePos;
    }
    else
    {
        [Crystal sharedBrightnessHintEffect].brightness = 1.0 - cyclePos;
    }
}

- (void) endHintMode
{
    if (!_hintMode) return;
    
    for (Crystal* crystal in _hintCrystals)
    {
        crystal.hintMode = NO;
    }
    
    _hintMode = NO;
}

#pragma mark Actions on Board

- (void) addCrystalInCol:(int)col
{
    int type = CCRANDOM_0_1()*5;
    
    Crystal* crystal = [Crystal crystalOfType:type];
    crystal.position = ccp(col * CRYSTAL_SIZE, CRYSTAL_SIZE * BOARD_HEIGHT);
    
    [self addChild:crystal];
    [_fallingCol[col] addObject:crystal];
}

- (void) moveFallingCrystalsInCol:(int)col
{
    for (Crystal* crystal in _fallingCol[col])
    {
        crystal.position = ccpAdd(crystal.position, ccp(0, crystal.speed));
    }
}

- (void) solidifyCrystalsInCol:(int)col
{
    BOOL solidifiedCrystal = NO;
    
    Crystal* crystal = [self bottomFallingCrystalInCol:col];
    
    float fixedTop = [self numFixedCrystalsInCol:col] * CRYSTAL_SIZE;
    
    if (crystal && crystal.position.y <= fixedTop)
    {
        // Needs to be solidified, remove from falling
        [_fallingCol[col] removeObject:crystal];
        
        // Insert into board
        int j;
        for (j = 0; _board[col][j] != NULL; j++);
        
        _board[col][j] = crystal;
        crystal.position = ccp(col*CRYSTAL_SIZE, j*CRYSTAL_SIZE);
        
        // Remember position
        crystal.x = col;
        crystal.y = j;
        
        solidifiedCrystal = YES;
    }
    
    if (solidifiedCrystal)
    {
        _crystalsLandedThisFrame = YES;
        [self solidifyCrystalsInCol:col];
    }
}

- (void) removeCrystals:(NSArray*)crystals
{
    for (Crystal* crystal in crystals)
    {
        _board[crystal.x][crystal.y] = NULL;
        [self removeChild:crystal];
        
        CCParticleSystem* particlesBack = (CCParticleSystem*)[CCBReader load:[NSString stringWithFormat:@"Particles/explo-%d", crystal.type]];
        particlesBack.position = ccp(crystal.x*CRYSTAL_SIZE + CRYSTAL_SIZE/2, crystal.y * CRYSTAL_SIZE + CRYSTAL_SIZE/2);
        particlesBack.autoRemoveOnFinish = YES;
        
        CCParticleSystem* particlesFront = (CCParticleSystem*)[CCBReader load:@"Particles/explo"];
        particlesFront.position = ccp(crystal.x*CRYSTAL_SIZE + CRYSTAL_SIZE/2, crystal.y * CRYSTAL_SIZE + CRYSTAL_SIZE/2);
        particlesFront.autoRemoveOnFinish = YES;
        
        [self addChild:particlesBack z:1];
        [self addChild:particlesFront z:2];
    }
    
    for (int j = 0; j < BOARD_WIDTH; j++)
    {
        [self fallifyCrystalsInCol:j];
    }
}

- (void) fallifyCrystalsInCol:(int)col
{
    BOOL foundHole = NO;
    for (int j = 0; j < BOARD_HEIGHT; j++)
    {
        if (foundHole)
        {
            if (_board[col][j])
            {
                // Fallify
                Crystal* crystal = _board[col][j];
                _board[col][j] = NULL;
                [crystal setStartingSpeed];
                [_fallingCol[col] addObject:crystal];
            }
        }
        else
        {
            if (!_board[col][j])
            {
                foundHole = YES;
            }
        }
    }
}

- (void) makePossibleMove
{
    // Make a possible move at a random spot at the board
    int x = CCRANDOM_0_1() * (BOARD_WIDTH - 1);
    int y = CCRANDOM_0_1() * (BOARD_HEIGHT - 1);
    
    // Recolor two bordering gems
    int type = _board[x][y].type;
    
    [self recolorCrystalAtX:x+1 Y:y toType:type];
    [self recolorCrystalAtX:x Y:y+1 toType:type];
}

- (void) recolorCrystalAtX:(int)x Y:(int)y toType:(int)type
{
    [self removeChild:_board[x][y]];
    
    Crystal* c = [Crystal crystalOfType:type];
    c.x = x;
    c.y = y;
    _board[x][y] = c;
    c.position = ccp(x * CRYSTAL_SIZE, y * CRYSTAL_SIZE);
    [self addChild:c];
}

#pragma mark Analyze Board

- (int) numCrystalsInCol:(int)col
{
    int num = 0;
    for (int j = 0; j < BOARD_HEIGHT; j++)
    {
        if(_board[col][j]) num++;
    }
    
    num += _fallingCol[col].count;
    
    return num;
}

- (float) topCrystalPosInCol:(int)col
{
    float top = [self numCrystalsInCol:col] * CRYSTAL_SIZE;
    
    for (Crystal* falling in _fallingCol[col])
    {
        if (falling.position.y > top)
        {
            top = falling.position.y;
        }
    }
    
    return top;
}

- (float) numFixedCrystalsInCol:(int)col
{
    float num = 0;
    
    for (int j = 0; j < BOARD_HEIGHT; j++)
    {
        if (_board[col][j]) num++;
    }
    
    return num;
}

- (Crystal*) bottomFallingCrystalInCol:(int)col
{
    Crystal* bottom = NULL;
    float pos = CRYSTAL_SIZE * BOARD_HEIGHT;
    
    for (Crystal* crystal in _fallingCol[col])
    {
        if (crystal.position.y < pos)
        {
            pos = crystal.position.y;
            bottom = crystal;
        }
    }
    
    return bottom;
}

- (NSArray*) connectedCrystalsAtPosX:(int)x Y:(int)y
{
    NSMutableArray* crystals = [NSMutableArray array];
    
    if (_board[x][y])
    {
        [self addConnectedCrystalsOfType:_board[x][y].type atPosX:x Y:y toArray:crystals];
    }
    
    return crystals;
}

- (void) addConnectedCrystalsOfType:(int)type atPosX:(int)x Y:(int)y toArray:(NSMutableArray*)array
{
    // Check for bounds
    if (x < 0 || x >= BOARD_WIDTH) return;
    if (y < 0 || y >= BOARD_HEIGHT) return;
    
    // Make sure there is a gem
    if (!_board[x][y]) return;
    
    // Make sure game types match
    if (_board[x][y].type != type) return;
    
    // Check if index is already visited
    if ([array containsObject:_board[x][y]]) return;
    
    // Add crystal to list
    [array addObject:_board[x][y]];
    
    // Visit neighbours
    [self addConnectedCrystalsOfType:type atPosX:x+1 Y:y toArray:array];
    [self addConnectedCrystalsOfType:type atPosX:x-1 Y:y toArray:array];
    [self addConnectedCrystalsOfType:type atPosX:x Y:y+1 toArray:array];
    [self addConnectedCrystalsOfType:type atPosX:x Y:y-1 toArray:array];
}

- (BOOL) hasPossibleMoves
{
    // If there are falling gems, there is still a chace for a match
    for (int i = 0; i < BOARD_WIDTH; i++)
    {
        if (_fallingCol[i].count > 0) return YES;
    }
    
    // Check all positions on the board
    for (int i = 0; i < BOARD_WIDTH; i++)
    {
        for (int j = 0; j < BOARD_HEIGHT; j++)
        {
            NSArray* connectedCrystals = [self connectedCrystalsAtPosX:i Y:j];
            if (connectedCrystals.count >= 3)
            {
                _hintCrystals = connectedCrystals;
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark Score & Time & Game Over

- (void) resetScore
{
    _score = 0;
    [GameScene currentGameScene].lblScore.string = @"0";
}

- (void) addScore:(int)score
{
    _score += score;
    [GameScene currentGameScene].lblScore.string = [NSString stringWithFormat:@"%d",_score];
}

- (int) secondsLeft
{
    int framesLeft = (int)(GAME_DURATION - _frame);
    if (framesLeft < 0) framesLeft = 0;
    
    return framesLeft/60;
}

- (void) updateTimeDisplay
{
    int secs = [self secondsLeft];
    
    NSString* timeStr = NULL;
    if (secs >= 60) timeStr = @"1:00";
    else timeStr = [NSString stringWithFormat:@"0:%02d", secs];
    
    [GameScene currentGameScene].lblTime.string = timeStr;
    
    if (!_gameOver && secs == 0)
    {
        [self startGameOver];
    }
    
    if (!_startedEndTimer && secs <= 5)
    {
        _startedEndTimer = YES;
        [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/timer.wav"];
    }
}

- (void) startGameOver
{
    self.userInteractionEnabled = NO;
    _gameOver = YES;
    
    // Move crystals to array with for game over animation
    for (int i = 0; i < BOARD_WIDTH; i++)
    {
        for (int j = 0; j < BOARD_HEIGHT; j++)
        {
            if (_board[i][j])
            {
                [_gameOverCrystals addObject:_board[i][j]];
                _board[i][j] = NULL;
            }
        }
        
        // Move any falling crystals to game over array
        for (Crystal* crystal in _fallingCol[i])
        {
            [_gameOverCrystals addObject:crystal];
        }
        [_fallingCol[i] removeAllObjects];
    }
    
    for (Crystal* crystal in _gameOverCrystals)
    {
        [crystal setupGameOverSpeeds];
    }
    
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/endgame.wav"];
    
    [[GameScene currentGameScene].animationManager runAnimationsForSequenceNamed:@"outro"];
}

- (void) animateGameOver
{
    for (Crystal* crystal in _gameOverCrystals)
    {
        CGPoint pos = crystal.position;
        crystal.position = ccp(pos.x + crystal.xSpeed, pos.y + crystal.speed);
    }
}

@end
