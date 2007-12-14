//
// MUProfile.h
//
// Copyright (c) 2007 3James Software.
//

@protocol J3LineBufferDelegate;

#import <Cocoa/Cocoa.h>
#import "J3Formatting.h"
#import "MUWorld.h"
#import "MUPlayer.h"
#import "J3Filter.h"
#import "J3TelnetConnection.h"

@interface MUProfile : NSObject <NSCoding>
{
  MUWorld *world;
  MUPlayer *player;
  BOOL autoconnect;
  
  BOOL loggedIn;
  
  NSFont *font;
  NSColor *textColor;
  NSColor *backgroundColor;
  NSColor *linkColor;
  NSColor *visitedLinkColor;
}

@property (retain) MUWorld *world;
@property (retain) MUPlayer *player;
@property (assign) BOOL autoconnect;

+ (MUProfile *) profileWithWorld: (MUWorld *) newWorld
                          player: (MUPlayer *) newPlayer
                     autoconnect: (BOOL) autoconnect;
+ (MUProfile *) profileWithWorld: (MUWorld *) newWorld player: (MUPlayer *) newPlayer;
+ (MUProfile *) profileWithWorld: (MUWorld *) newWorld;

// Designated initializer.
- (id) initWithWorld: (MUWorld *) newWorld
              player: (MUPlayer *) newPlayer
         autoconnect: (BOOL) newAutoconnect
  							font: (NSFont *) newFont
  				 textColor: (NSColor *) newTextColor
  	 backgroundColor: (NSColor *) newBackgroundColor
  				 linkColor: (NSColor *) newLinkColor
  	visitedLinkColor: (NSColor *) newVisitedLinkColor;

- (id) initWithWorld: (MUWorld *) newWorld
              player: (MUPlayer *) newPlayer
         autoconnect: (BOOL) newAutoconnect;

- (id) initWithWorld: (MUWorld *) newWorld player: (MUPlayer *) newPlayer;
- (id) initWithWorld: (MUWorld *) newWorld;

// Accessors.
- (NSFont *) font;
- (void) setFont: (NSFont *) newFont;
- (NSColor *) textColor;
- (void) setTextColor: (NSColor *) newTextColor;
- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) newBackgroundColor;
- (BOOL) hasLoginInformation;
- (NSColor *) linkColor;
- (void) setLinkColor: (NSColor *) newLinkColor;
- (NSColor *) visitedLinkColor;
- (void) setVisitedLinkColor: (NSColor *) newVisitedLinkColor;
- (NSObject <J3Formatting> *) formatting;

// Derived bindings.
- (NSFont *) effectiveFont;
- (NSString *) effectiveFontDisplayName;
- (NSData *) effectiveTextColor;
- (NSData *) effectiveBackgroundColor;
- (NSData *) effectiveLinkColor;
- (NSData *) effectiveVisitedLinkColor;

// Actions.
- (NSString *) hostname;
- (J3Filter *) logger;
- (NSString *) loginString;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

- (J3TelnetConnection *) createNewTelnetConnectionWithDelegate: (NSObject <J3ConnectionDelegate> *) delegate;

@end
