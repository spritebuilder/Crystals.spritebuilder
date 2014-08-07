//
//  Board.m
//  Crystals
//
//  Created by Viktor on 8/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Board.h"
#import "Crystal.h"



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
    
    return self;
}

- (void) didLoadFromCCB
{
    self.userInteractionEnabled = YES;
}

- (void) fixedUpdate:(CCTime)delta
{
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
    
    if (_crystalsLandedThisFrame)
    {
        int num = CCRANDOM_0_1()*4;
        [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"Sounds/tap-%d.wav",num]];
    }
}

#pragma mark Handle Touches

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint loc = [touch locationInNode:self];
    
    // Calc x and y in matrix
    int x = ((int)loc.x)/CRYSTAL_SIZE;
    int y = ((int)loc.y)/CRYSTAL_SIZE;
    
    // Find the crystals connected to the touch
    NSArray* crystals = [self connectedCrystalsAtPosX:x Y:y];
    
    if (crystals.count >= 3)
    {
        [self removeCrystals:crystals];
    }
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

@end
