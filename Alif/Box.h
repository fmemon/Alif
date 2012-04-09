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
    
    int score;
}
@property(nonatomic, retain) CCLayer *layer;
@property(nonatomic, readonly) CGSize size;
@property(nonatomic) BOOL lock;
-(id) initWithSize: (CGSize) size factor: (int) factor;
-(Tile *) objectAtX: (int) posX Y: (int) posY;
-(BOOL) check;
-(int) scored;
-(void) unlock;
-(void) removeSprite: (id) sender;
-(void) afterAllMoveDone;
@end
