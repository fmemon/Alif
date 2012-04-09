//
//  Box.h
//  Alif
//
//  Created by Saida Memon on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import "constants.h"
#import "Tile.h"

@interface Box : NSObject {
	id first, second;
	CGSize size;
	NSMutableArray *content;
	NSMutableSet *readyToRemoveTiles;
	BOOL lock;
	CCLayer *layer;
	Tile *OutBorderTile;
    
    int level;
    int score;
    int highscore;
    CCParticleExplosion *myEmitter;
    
    BOOL level1;
    BOOL level2;
    BOOL level3;
    BOOL level4;
    BOOL level5;
    BOOL level6;
    BOOL level7;
    BOOL level8;
    BOOL level9;    
}
@property(nonatomic, retain) CCLayer *layer;
@property(nonatomic, readonly) CGSize size;
@property(nonatomic) BOOL lock;
-(id) initWithSize: (CGSize) size factor: (int) factor;
-(Tile *) objectAtX: (int) posX Y: (int) posY;
-(int) scored;
-(void) unlock;
-(void) removeSprite: (id) sender;
-(void) afterAllMoveDone;
-(void)callEmitter: (id) sender newLevel:(BOOL)newLevel;      
-(void)dropIt;

@end
