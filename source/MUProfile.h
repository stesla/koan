//
//  MUProfile.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Terminal/J3TelnetConnection.h>
#import "MUWorld.h"
#import "MUPlayer.h"
#import "J3Filter.h"

@interface MUProfile : NSObject 
{
  MUWorld   * world;
  MUPlayer  * player;
}

// designated initializer
- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player;
- (id) initWithWorld:(MUWorld *)world;

- (NSString *) frameName;
- (NSString *) windowName;

- (NSString *) hostname;
- (NSString *) loginString;
- (J3Filter *) logger;
- (J3TelnetConnection *) openTelnetWithDelegate:(id)delegate;


- (MUWorld *) world;
- (MUPlayer *) player;
@end
