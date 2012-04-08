//
//  Tile.h
//  Alif
//
//  Created by Saida Memon on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import "constants.h"

@interface Tile : NSObject {
	int x, y, value;
	CCSprite *sprite;
}

-(id) initWithX:(int)posX Y: (int) posY;
@property (nonatomic, readonly) int x, y;

//@property (nonatomic, assign) int x;
//@property (nonatomic, assign) int y;
//@property (nonatomic, readonly) int x, y;
//@property (nonatomic, readwrite) int y;

//@property (nonatomic, readwrite) int x;

@property (nonatomic) int value;
@property (nonatomic, retain) CCSprite *sprite;
-(BOOL) nearTile: (Tile *)othertile;
-(void) trade:(Tile *)otherTile;
-(CGPoint) pixPosition;
@end
