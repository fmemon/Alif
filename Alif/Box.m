#import "Box.h"
#import "MusicHandler.h"
#import "SceneManager.h"

@interface Box()
-(int) repair;
-(int) repairSingleColumn: (int) columnIndex;
@end

@implementation Box
@synthesize layer;
@synthesize size;
@synthesize lock;

-(id) initWithSize: (CGSize) aSize factor: (int) aFactor{
	self = [super init];
	size = aSize;
	//OutBorderTile = [[Tile alloc] initWithX:-1 Y:-1];
	OutBorderTile = [Tile alloc];
    [OutBorderTile initWithX:-1 Y:-1];
	content = [NSMutableArray arrayWithCapacity: size.height];
	
	for (int y=0; y<size.height; y++) {
		
		NSMutableArray *rowContent = [NSMutableArray arrayWithCapacity:size.width];
		for (int x=0; x < size.width; x++) {
			//Tile *tile = [[Tile alloc] initWithX:x Y:y];
			Tile *tile = [Tile alloc];
            [tile initWithX:x Y:y];
            
			[rowContent addObject:tile];
			[tile release];
		}
		[content addObject:rowContent];
		[content retain];
	}
	
	readyToRemoveTiles = [NSMutableSet setWithCapacity:5];
	[readyToRemoveTiles retain];
    score = 0;
    level = 1;
	return self;
}

-(Tile *) objectAtX: (int) x Y: (int) y{
	if (x < 0 || x >= kBoxWidth || y < 0 || y >= kBoxHeight) {
		return OutBorderTile;
	}
	return [[content objectAtIndex: y] objectAtIndex: x];
}

-(void) checkWith: (Orientation) orient{
	int iMax = (orient == OrientationHori) ? size.width : size.height;
	int jMax = (orient == OrientationVert) ? size.height : size.width;
	for (int i=0; i<iMax; i++) {
		int count = 0;
		int value = -1;
		first = nil;
		second = nil;
		for (int j=0; j<jMax; j++) {
			Tile *tile = [self objectAtX:((orient == OrientationHori) ?i :j)  Y:((orient == OrientationHori) ?j :i)];
			if(tile.value == value){
				count++;
				if (count > 3) {
					[readyToRemoveTiles addObject:tile];
				}else
					if (count == 3) {
						[readyToRemoveTiles addObject:first];
						[readyToRemoveTiles addObject:second];
						[readyToRemoveTiles addObject:tile];
						first = nil;
						second = nil;
						
					}else if (count == 2) {
						second = tile;
					}else {
						
					}
				
			}else {
				count = 1;
				first = tile;
				second = nil;
				value = tile.value;
			}
		}
	}
}
-(int) scored {
    [self checkWith:OrientationHori];	
	[self checkWith:OrientationVert];
	
	NSArray *objects = [[readyToRemoveTiles objectEnumerator] allObjects];
	if ([objects count] == 0) {
		return 0;
	}
	
	int count = [objects count];
	for (int i=0; i<count; i++) {
        
		Tile *tile = [objects objectAtIndex:i];
		tile.value = 0;
		if (tile.sprite) {
			CCAction *action = [CCSequence actions:[CCScaleTo actionWithDuration:0.3f scale:0.0f],
								[CCCallFuncN actionWithTarget: self selector:@selector(removeSprite:)],
								nil];
			[tile.sprite runAction: action];
		}
	}
    
    int counter = [readyToRemoveTiles count];
    //NSLog(@"count of tiles to be removed for scoring %d", [readyToRemoveTiles count]);
	[readyToRemoveTiles removeAllObjects];
	int maxCount = [self repair];
	
	[layer runAction: [CCSequence actions: [CCDelayTime actionWithDuration: kMoveTileTime * maxCount + 0.03f],
					   [CCCallFunc actionWithTarget:self selector:@selector(afterAllMoveDone)],
					   nil]];
	return counter;
}

-(void) removeSprite: (id) sender{
    [MusicHandler playPing];
    [self callEmitter:sender newLevel:NO];

	[layer removeChild: sender cleanup:YES];
    score +=5;
    [(CCLabelTTF*)[layer getChildByTag:99] setString:[NSString stringWithFormat:@"       Score: %i",score]];

}

-(void) afterAllMoveDone{
	if([self scored]){
		
	}else {
		[self unlock];
	}
    

    
    //check if we reached next level 500 score
    if (score>=300) {
        level++;
        NSLog(@"Time to level up");
        [self callEmitter:nil newLevel:YES];
        CCLabelTTF* bigLevelLabel = (CCLabelTTF*)[layer getChildByTag:88];
        [bigLevelLabel setString:[NSString stringWithFormat:@" New Level: %i",level]];
        [bigLevelLabel setVisible:YES];
        
        id action = [CCSpawn actions: [CCScaleTo actionWithDuration:0.4f scale:0.5f], [CCFadeOut actionWithDuration:.4], [CCMoveTo actionWithDuration:0.8f position:ccp(40.0f, 475.0f)], nil];
        
        [bigLevelLabel runAction:[CCSequence actions: action, [CCCallFuncN actionWithTarget:self selector:@selector(dropIt)], nil]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"score"];
    [defaults setInteger:level forKey:@"level"];
    
    if (score > highscore) {
        [defaults setInteger:score forKey:@"newHS"];
    }
    [defaults synchronize];
}	 
-(void)dropIt {
    CCLabelTTF* bigLevelLabel = (CCLabelTTF*)[layer getChildByTag:88];
    [bigLevelLabel setVisible:NO];
    [(CCLabelTTF*)[layer getChildByTag:77] setString:[NSString stringWithFormat:@"Level: %i",level]];
    CCDirector *director = [CCDirector sharedDirector];
    CCLayer *player = [PlayLayer node];
    
	CCScene *newScene = [SceneManager wrap:player];
	
	if ([director runningScene]) {
		[director replaceScene:newScene];
	}else {
		[director runWithScene:newScene];		
	}

}
-(void) unlock{
	self.lock = NO;
}

-(int) repair{
	int maxCount = 0;
	for (int x=0; x<size.width; x++) {
		int count = [self repairSingleColumn:x];
		if (count > maxCount) {
			maxCount = count;
		}
	}
	return maxCount;
}

-(int) repairSingleColumn: (int) columnIndex{
	int extension = 0;
	for (int y=0; y<size.height; y++) {
		Tile *tile = [self objectAtX:columnIndex Y:y];
        if(tile.value == 0){
            extension++;
        }else if (extension == 0) {
            
        }else{
            Tile *destTile = [self objectAtX:columnIndex Y:y-extension];
            
            CCSequence *action = [CCSequence actions:
                                  [CCMoveBy actionWithDuration:kMoveTileTime*extension position:ccp(0,-kTileSize*extension)],
                                  nil];
            
            [tile.sprite runAction: action];
            
            destTile.value = tile.value;
            destTile.sprite = tile.sprite;
            
        }
	}
	
	for (int i=0; i<extension; i++) {
		int value = (arc4random()%kKindCount+1);
		Tile *destTile = [self objectAtX:columnIndex Y:kBoxHeight-extension+i];
		NSString *name = [NSString stringWithFormat:@"block_%d.png",value];
		CCSprite *sprite = [CCSprite spriteWithFile:name];
		sprite.position = ccp(kStartX + columnIndex * kTileSize + kTileSize/2, kStartY + (kBoxHeight + i) * kTileSize + kTileSize/2);
		CCSequence *action = [CCSequence actions:
							  [CCMoveBy actionWithDuration:kMoveTileTime*extension position:ccp(0,-kTileSize*extension)],
							  nil];
		[layer addChild: sprite];
		[sprite runAction: action];
		destTile.value = value;
		destTile.sprite = sprite;
	}
	return extension;
}

-(void)callEmitter: (id) sender newLevel:(BOOL)newLevel { 
    
    if (!newLevel) {
    int numParticle = 30 +CCRANDOM_0_1()*100;
    myEmitter = [[CCParticleExplosion alloc] initWithTotalParticles:numParticle];
    myEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"goldstars1sm.png"];
    CCSprite* sprite = (CCSprite*)sender;
   // NSLog(@"Value of x %f  and y %f", sprite.position.x, sprite.position.y);
    myEmitter.position = CGPointMake(sprite.position.x, sprite.position.y);    
    myEmitter.life =0.2f + CCRANDOM_0_1()*0.1;
    myEmitter.duration = 0.1f + CCRANDOM_0_1()*0.05;
    myEmitter.scale = 0.5f;
    myEmitter.speed = 50.0f + CCRANDOM_0_1()*50.0f;
    myEmitter.blendAdditive = YES;
    [layer addChild:myEmitter z:11];
    myEmitter.autoRemoveOnFinish = YES;
    }
    else {
        int numParticle = 30 +CCRANDOM_0_1()*1000;
        myEmitter = [[CCParticleExplosion alloc] initWithTotalParticles:numParticle];
        myEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"goldstars1sm.png"];
        myEmitter.position = CGPointMake(160.0f, 240.0f);    
        myEmitter.life =0.4f + CCRANDOM_0_1()*0.4;
        myEmitter.duration = 0.4f + CCRANDOM_0_1()*0.45;
        myEmitter.scale = 0.9f;
        myEmitter.speed = 100.0f + CCRANDOM_0_1()*50.0f;
        myEmitter.blendAdditive = YES;
        [layer addChild:myEmitter z:11];
        myEmitter.autoRemoveOnFinish = YES;
    }
}

@end
