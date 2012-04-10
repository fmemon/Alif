//
//  MusicHandler.mm
//  Alif
//
//  Created by Saida Memon on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MusicHandler.h"

//static NSString *WATER_EFFECT = @"splash2.caf";
//static NSString *BOUNCE_EFFECT = @"boing.caf";

static NSString *PING_EFFECT = @"kr_mix.mp3";

@interface MusicHandler()
+(void) playEffect:(NSString *)path;
@end


@implementation MusicHandler

+(void) preload{
	SimpleAudioEngine *engine = [SimpleAudioEngine sharedEngine];
	if (engine) {

		[engine preloadEffect:PING_EFFECT];
	}
}
+(void) playPing{
	[MusicHandler playEffect:PING_EFFECT];	
}



+(void) playEffect: (NSString *) path{
	[[SimpleAudioEngine sharedEngine] playEffect:path];
}
@end
