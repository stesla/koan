//
// MUProfile.h
//
// Copyright (c) 2004, 2005, 2006, 2007 3James Software
//

@protocol J3LineBufferDelegate;
@protocol J3TelnetConnectionDelegate;

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
  
  BOOL loggedIn;
  BOOL autoconnect;
  
  NSFont *font;
  NSColor *textColor;
  NSColor *backgroundColor;
  NSColor *linkColor;
  NSColor *visitedLinkColor;
}

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
- (MUWorld *) world;
- (void) setWorld: (MUWorld *) newWorld;
- (MUPlayer *) player;
- (void) setPlayer: (MUPlayer *) newPlayer;
- (BOOL) autoconnect;
- (void) setAutoconnect: (BOOL) newAutoconnect;
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

- (J3TelnetConnection *) createNewTelnetConnectionWithDelegate: (NSObject <J3TelnetConnectionDelegate> *) delegate;

@end
