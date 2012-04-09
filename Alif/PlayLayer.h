//
//  PlayLayer.h
//  Alif
//
//  Created by Saida Memon on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "MusicHandler.h"

#import "Box.h"

@interface PlayLayer : CCLayer
{
	Box *box;
	Tile *selectedTile;
	Tile *firstOne;
    int score;
    int highscore;
    CCLabelTTF *highscoreLabel;
    CCLabelTTF *scoreLabel;
    
    CCMenuItemToggle *pause;
    
    BOOL muted;
}

-(void) changeWithTileA: (Tile *) a TileB: (Tile *) b sel : (SEL) sel;
-(void) check: (id) sender data: (id) data;
-(BOOL) nearTile: (Tile *)aTile anotherTile: (Tile *)otherTile;
- (void)turnOnMusic;
- (void)restoreData;
- (void)updateScore;
- (void)saveData;
- (void)reset;
@end
