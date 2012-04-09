//
//  PlayLayer.m
//  PlayLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "PlayLayer.h"

@interface PlayLayer()
-(void)afterTurn: (id) node;
@end

@implementation PlayLayer

-(id) init{
	self = [super init];
	score = 0;
    highscore = 0;
    
    //show scores
    highscoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HighScore: %i",highscore] fontName:@"Marker Felt" fontSize:24];
    //highscoreLabel.color = ccc3(26, 46, 149);
    highscoreLabel.color = ccBLUE;
    highscoreLabel.position = ccp(180.0f, 465.0f);
    [self addChild:highscoreLabel z:10];
    
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"       Score: %i",score] fontName:@"Marker Felt" fontSize:24];
    scoreLabel.position = ccp(180.0f, 445.0f);
    //scoreLabel.color = ccc3(26, 46, 149);
    scoreLabel.color = ccBLUE;
    [self addChild:scoreLabel z:10];
    
	CCSprite *bg = [CCSprite spriteWithFile: @"ingame_menu.png"];
	bg.position = ccp(160,240);
	[self addChild: bg z:0];
	
	box = [[Box alloc] initWithSize:CGSizeMake(kBoxWidth,kBoxHeight) factor:6];
	box.layer = self;
	box.lock = YES;
	
	self.isTouchEnabled = YES;
	
	return self;
}

-(void) onEnterTransitionDidFinish{
	[box check];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	//NSLog(@"ccTouchesBegan");
	
	if ([box lock]) {
      //  NSLog(@"locked");

		return;
	}
	
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	
	int x = (location.x -kStartX) / kTileSize;
	int y = (location.y -kStartY) / kTileSize;
	
	
	if (selectedTile && selectedTile.x ==x && selectedTile.y == y) {
    //    if (selectedTile && selectedTile.x ==x && selectedTile.y == y) {
        //NSLog(@"same");

		return;
	}
	
	Tile *tile = [box objectAtX:x Y:y];
    
    //NSLog(@"vlue of near tile %d",[self nearTile:selectedTile anotherTile:tile]);
	
	if (selectedTile && [self nearTile:selectedTile anotherTile:tile]) {
     //   if (selectedTile && [selectedTile nearTile:tile]) {
        //NSLog(@"changeTile");

		[box setLock:YES];
		[self changeWithTileA: selectedTile TileB: tile sel: @selector(check:data:)];
		selectedTile = nil;
	}else {
        //NSLog(@"tile selected");

		selectedTile = tile;
		[self afterTurn:tile.sprite];
	}
}

-(void) changeWithTileA: (Tile *) a TileB: (Tile *) b sel : (SEL) sel{
	CCAction *actionA = [CCSequence actions:
						 [CCMoveTo actionWithDuration:kMoveTileTime position:[b pixPosition]],
						 [CCCallFuncND actionWithTarget:self selector:sel data: a],
						 nil
						 ];
	
	CCAction *actionB = [CCSequence actions:
						 [CCMoveTo actionWithDuration:kMoveTileTime position:[a pixPosition]],
						 [CCCallFuncND actionWithTarget:self selector:sel data: b],
						 nil
						 ];
    //NSLog(@"in the changeTile");

	[a.sprite runAction:actionA];
	[b.sprite runAction:actionB];
	
	[a trade:b];
}

-(BOOL) nearTile: (Tile *)aTile anotherTile: (Tile *)otherTile {
    //NSLog(@"INPLYATIME y %d othertiley %d  x %d othertilex %d",aTile.y, otherTile.y, aTile.x, otherTile.x);
    
	return 
	(aTile.x == otherTile.x && abs(aTile.y - otherTile.y)==1)
	||
	(aTile.y == otherTile.y && abs(aTile.x - otherTile.x)==1);
}

-(void) backCheck: (id) sender data: (id) data{
	if(nil == firstOne){
		firstOne = data;
		return;
	}
	firstOne = nil;
	[box setLock:NO];
}

-(void) check: (id) sender data: (id) data{
	if(nil == firstOne){
		firstOne = data;
		return;
	}
	BOOL result = [box check];
	if (result) {
		[box setLock:NO];	
	}else {
		[self changeWithTileA:(Tile *)data TileB:firstOne sel:@selector(backCheck:data:)]; 
		[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:kMoveTileTime + 0.03f],
						 [CCCallFunc actionWithTarget:box selector:@selector(unlock)],
						 nil]];
	}
    
	firstOne = nil;
}


-(void)afterTurn: (id) node{
	if (selectedTile && node == selectedTile.sprite) {
       // NSLog(@"after turn tile selected");

		CCSprite *sprite = (CCSprite *)node;
		CCSequence *someAction = [CCSequence actions: 
								  [CCScaleBy actionWithDuration:kMoveTileTime scale:0.5f],
								  [CCScaleBy actionWithDuration:kMoveTileTime scale:2.0f],
								  [CCCallFuncN actionWithTarget:self selector:@selector(afterTurn:)],
								  nil];
		
		[sprite runAction:someAction];
	}
}
@end
