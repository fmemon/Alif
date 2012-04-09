//
//  PlayLayer.m
//  PlayLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "PlayLayer.h"
#import "SceneManager.h"
@interface PlayLayer()
-(void)afterTurn: (id) node;
@end

@implementation PlayLayer


-(id) init{
	self = [super init];
    // Preload effect
    [MusicHandler preload];
    
	score = 0;
    highscore = 0;
    gamePaused = FALSE;
    muted = FALSE;
    
    [self restoreData];
    pauseLabel = [CCLabelTTF labelWithString:@"Game Paused" fontName:@"Marker Felt" fontSize:32];
    [pauseLabel setPosition:ccp(160,330)];
    [pauseLabel setVisible:NO];
    [self addChild:pauseLabel z:0];
    
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
    [self addChild:scoreLabel z:10 tag:99];
    
	CCSprite *bg = [CCSprite spriteWithFile: @"ingame_menu.png"];
	bg.position = ccp(160,240);
	[self addChild: bg z:0];
	
	box = [[Box alloc] initWithSize:CGSizeMake(kBoxWidth,kBoxHeight) factor:6];
	box.layer = self;
	box.lock = YES;
	
	self.isTouchEnabled = YES;
        
    //Pause Toggle can not sure frame cache for sprites!!!!!
    CCMenuItemSprite *playItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseON.png"]
                                                         selectedSprite:[CCSprite spriteWithFile:@"newPauseONSelect.png"]];
    
    CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseOFF.png"]
                                                          selectedSprite:[CCSprite spriteWithFile:@"newPauseOFFSelect.png"]];
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (!muted)  {
        pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:playItem, pauseItem, nil];
        pause.position = ccp(screenSize.width*0.03, screenSize.height*0.95f);
    }
    else {
        pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:pauseItem, playItem, nil];
        pause.position = ccp(screenSize.width*0.03, screenSize.height*0.95f);
    }
    CCMenuItemSprite *pausedPlayItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"goldstars1sm.png"]
                                                         selectedSprite:[CCSprite spriteWithFile:@"goldstars1sm.png"]
                                                               disabledSprite:[CCSprite spriteWithFile:@"goldstars1sm.png"]
                                                                       target:self
                                                                     selector:@selector(paused)];
    CCMenuItemSprite* restartItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"reset.png"]
                                                            selectedSprite:[CCSprite spriteWithFile:@"resetS.png"]
                                                            disabledSprite:[CCSprite spriteWithFile:@"resetS.png"]
                                                                    target:self
                                                                  selector:@selector(reset)];	
    
    //Create Menu with the items created before
    CCMenu *menu = [CCMenu menuWithItems:pause,pausedPlayItem,restartItem, nil];
    menu.position = CGPointMake(150.0f, 15.0f);
    [menu alignItemsHorizontallyWithPadding:90.0f];

    [self addChild:menu z:11];
	
	return self;
}
-(void)paused {
    //[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    [[CCDirector sharedDirector] pause];
    pauseLayer = [CCLayerColor layerWithColor: ccc4(0, 0, 255, 125) width: 360 height: 480];
    pauseLayer.position = ccp(0,0);
    [self addChild: pauseLayer z:8];
    CCMenuItem *resume = [CCMenuItemImage itemFromNormalImage:@"heart.png" selectedImage:@"heart.png" target:self selector:@selector(resumeGame)];
    CCMenuItem *mainMenu = [CCMenuItemImage itemFromNormalImage:@"club.png" selectedImage:@"club.png" target:self selector:@selector(reset)];
    pauseMenu = [CCMenu menuWithItems:resume, mainMenu, nil];
    [pauseMenu alignItemsHorizontally];
    [self addChild:pauseMenu z:10];
}

-(void)resumeGame{
    [self removeChild:pauseMenu cleanup:YES];
    [self removeChild:pauseLayer cleanup:YES];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundmusic.mp3"];
    [[CCDirector sharedDirector] resume];
}

- (void)reset {
    //get score that was saved from Box
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults integerForKey:@"score"]) {
        score = [defaults integerForKey:@"score"];
    }
    [self saveData];

    CCDirector *director = [CCDirector sharedDirector];
    CCLayer *layer = [PlayLayer node];

	CCScene *newScene = [SceneManager wrap:layer];
	
	if ([director runningScene]) {
		[director replaceScene:newScene];
	}else {
		[director runWithScene:newScene];		
	}
    [self restoreData];
}
- (void)saveData {   
    if (score > highscore) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"newHS"];
    
    [defaults synchronize];
    }
}
- (void)restoreData {

    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults integerForKey:@"newHS"]) {
        highscore = [defaults integerForKey:@"newHS"];
        [highscoreLabel setString:[NSString stringWithFormat:@"HighScore: %i",highscore]];
    }
    
    if ([defaults boolForKey:@"IsMuted"]) {
        muted = [defaults boolForKey:@"IsMuted"];
        [[SimpleAudioEngine sharedEngine] setMute:muted];
    }
    
}

- (void)turnOnMusic {
    if ([[SimpleAudioEngine sharedEngine] mute]) {
        // This will unmute the sound
        muted = FALSE;
    }
    else {
        //This will mute the sound
        muted = TRUE;
    }
    [[SimpleAudioEngine sharedEngine] setMute:muted];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:muted forKey:@"IsMuted"];
    [defaults synchronize];
}

-(void) onEnterTransitionDidFinish{
	[box scored];
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
	//BOOL result = [box check];
	int result = [box scored];
	if (result > 0) {
     //   if (result > 0) {
		[box setLock:NO];
        //score += 5*result;
        //[self updateScore];
	}else {
		[self changeWithTileA:(Tile *)data TileB:firstOne sel:@selector(backCheck:data:)]; 
		[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:kMoveTileTime + 0.03f],
						 [CCCallFunc actionWithTarget:box selector:@selector(unlock)],
						 nil]];
	}
    
	firstOne = nil;
}
- (void)updateScore {
   // score += 55;
    [self saveData];  

    [scoreLabel setString:[NSString stringWithFormat:@"       Score: %i",score]];
 /*   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"score"];
    [defaults synchronize];
    
   */ 
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
