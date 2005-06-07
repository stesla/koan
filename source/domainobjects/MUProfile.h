//
//  MUProfile.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Terminal/J3TelnetConnection.h"
#import "MUWorld.h"
#import "MUPlayer.h"
#import "J3Filter.h"

@interface MUProfile : NSObject 
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

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld 
                          player:(MUPlayer *)newPlayer
                     autoconnect:(BOOL)autoconnect;
+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld;

// Designated initializer.
- (id) initWithWorld:(MUWorld *)newWorld 
              player:(MUPlayer *)newPlayer
         autoconnect:(BOOL)newAutoconnect
								font:(NSFont *)newFont
					 textColor:(NSColor *)newTextColor
		 backgroundColor:(NSColor *)newBackgroundColor
					 linkColor:(NSColor *)newLinkColor
		visitedLinkColor:(NSColor *)newVisitedLinkColor;

- (id) initWithWorld:(MUWorld *)newWorld 
              player:(MUPlayer *)newPlayer
         autoconnect:(BOOL)newAutoconnect;
- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
- (id) initWithWorld:(MUWorld *)newWorld;

// Accessors.
- (MUWorld *) world;
- (void) setWorld:(MUWorld *)newWorld;
- (MUPlayer *) player;
- (void) setPlayer:(MUPlayer *)newPlayer;
- (BOOL) autoconnect;
- (void) setAutoconnect:(BOOL)newAutoconnect;
- (NSFont *) font;
- (void) setFont:(NSFont *)newFont;
- (NSColor *) textColor;
- (void) setTextColor:(NSColor *)newTextColor;
- (NSColor *) backgroundColor;
- (void) setBackgroundColor:(NSColor *)newBackgroundColor;
- (NSColor *) linkColor;
- (void) setLinkColor:(NSColor *)newLinkColor;
- (NSColor *) visitedLinkColor;
- (void) setVisitedLinkColor:(NSColor *)newVisitedLinkColor;

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

- (J3TelnetConnection *) openTelnetWithDelegate:(id)delegate;
- (void) loginWithConnection:(J3TelnetConnection *)connection;
- (void) logoutWithConnection:(J3TelnetConnection *)connection;

@end
