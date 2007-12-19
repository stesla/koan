//
// MUProfile.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUCodingService.h"
#import "MUProfile.h"
#import "MUProfileFormatting.h"
#import "MUTextLogger.h"

@interface MUProfile (Private)

- (void) globalBackgroundColorDidChange: (NSNotification *) notification;
- (void) globalFontDidChange: (NSNotification *) notification;
- (void) globalTextColorDidChange: (NSNotification *) notification;
- (void) registerForNotifications;

@end

#pragma mark -

@implementation MUProfile

@synthesize world, player, autoconnect;
@dynamic loginString, uniqueIdentifier, windowTitle;

+ (BOOL) automaticallyNotifiesObserversForKey: (NSString *) key
{
  static NSArray *keyArray;
  
  if (!keyArray)
  {
  	keyArray = [NSArray arrayWithObjects:
  		@"effectiveFont",
  		@"effectiveFontDisplayName",
  		@"effectiveTextColor",
  		@"effectiveBackgroundColor",
  		@"effectiveLinkColor",
  		@"effectiveVisitedLinkColor",
  		nil];
  }
  
  if ([keyArray containsObject: key])
  	return NO;
  else
  	return YES;
}

+ (MUProfile *) profileWithWorld: (MUWorld *) newWorld
                          player: (MUPlayer *) newPlayer
                     autoconnect: (BOOL) newAutoconnect
{
  return [[[self alloc] initWithWorld: newWorld
                               player: newPlayer
                          autoconnect: newAutoconnect] autorelease];
}

+ (MUProfile *) profileWithWorld: (MUWorld *) newWorld player: (MUPlayer *) newPlayer
{
  return [[[self alloc] initWithWorld: newWorld
                               player: newPlayer] autorelease];
}

+ (MUProfile *) profileWithWorld: (MUWorld *) newWorld
{
  return [[[self alloc] initWithWorld: newWorld] autorelease];
}

- (id) initWithWorld: (MUWorld *) newWorld
              player: (MUPlayer *) newPlayer
         autoconnect: (BOOL) newAutoconnect
  							font: (NSFont *) newFont
  				 textColor: (NSColor *) newTextColor
  	 backgroundColor: (NSColor *) newBackgroundColor
  				 linkColor: (NSColor *) newLinkColor
  	visitedLinkColor: (NSColor *) newVisitedLinkColor
{
  if (![super init])
    return nil;
  
  self.world = newWorld;
  self.player = newPlayer;
  self.autoconnect = newAutoconnect;
  [self setFont: newFont];
  [self setTextColor: newTextColor];
  [self setBackgroundColor: newBackgroundColor];
  [self setLinkColor: newLinkColor];
  [self setVisitedLinkColor: newVisitedLinkColor];
  
  [self registerForNotifications];
  
  return self;
}

- (id) initWithWorld: (MUWorld *) newWorld
              player: (MUPlayer *) newPlayer
         autoconnect: (BOOL) newAutoconnect
{
  return [self initWithWorld: newWorld
  										player: newPlayer
  							 autoconnect: newAutoconnect
  											font: nil
  								 textColor: nil
  					 backgroundColor: nil
  								 linkColor: nil
  					visitedLinkColor: nil];
}

- (id) initWithWorld: (MUWorld *) newWorld player: (MUPlayer *) newPlayer
{
  return [self initWithWorld: newWorld
                      player: newPlayer
                 autoconnect: NO];
}

- (id) initWithWorld: (MUWorld *) newWorld
{
  return [self initWithWorld: newWorld player: nil];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self name: nil object: nil];
  [player release];
  [world release];
  [super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (NSFont *) font
{
  return font;
}

- (void) setFont: (NSFont *) newFont
{
  if ([font isEqual: newFont])
    return;
  
  [self willChangeValueForKey: @"effectiveFont"];
  [self willChangeValueForKey: @"effectiveFontDisplayName"];
  [font release];
  font = [newFont copy];
  [self didChangeValueForKey: @"effectiveFont"];
  [self didChangeValueForKey: @"effectiveFontDisplayName"];
}

- (NSColor *) textColor
{
  return textColor;
}

- (void) setTextColor: (NSColor *) newTextColor
{
  if ([textColor isEqual: newTextColor])
    return;
  
  [self willChangeValueForKey: @"effectiveTextColor"];
  [textColor release];
  textColor = [newTextColor copy];
  [self didChangeValueForKey: @"effectiveTextColor"];
}

- (NSColor *) backgroundColor
{
  return backgroundColor;
}

- (void) setBackgroundColor: (NSColor *) newBackgroundColor
{
  if ([backgroundColor isEqual: newBackgroundColor])
    return;
  
  [self willChangeValueForKey: @"effectiveBackgroundColor"];
  [backgroundColor release];
  backgroundColor = [newBackgroundColor copy];
  [self didChangeValueForKey: @"effectiveBackgroundColor"];
}

- (NSColor *) linkColor
{
  return linkColor;
}

- (void) setLinkColor: (NSColor *) newLinkColor
{
  if ([linkColor isEqual: newLinkColor])
    return;
  
  [self willChangeValueForKey: @"effectiveLinkColor"];
  [linkColor release];
  linkColor = [newLinkColor copy];
  [self didChangeValueForKey: @"effectiveLinkColor"];
}

- (NSColor *) visitedLinkColor
{
  return visitedLinkColor;
}

- (void) setVisitedLinkColor: (NSColor *) newVisitedLinkColor
{
  if ([visitedLinkColor isEqual: newVisitedLinkColor])
    return;
  
  [self willChangeValueForKey: @"effectiveVisitedLinkColor"];
  [visitedLinkColor release];
  visitedLinkColor = [newVisitedLinkColor copy];
  [self didChangeValueForKey: @"effectiveVisitedLinkColor"];
}

- (NSObject <J3Formatting> *) formatting
{
  return [[[MUProfileFormatting alloc] initWithProfile: self] autorelease];
}

#pragma mark -
#pragma mark Accessors for bindings

- (NSData *) effectiveBackgroundColor
{
  if (backgroundColor)
  	return [NSArchiver archivedDataWithRootObject: backgroundColor];
  else
  {
  	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	
  	return [[defaults values] valueForKey: MUPBackgroundColor];
  }
}

- (NSFont *) effectiveFont
{
  if (font)
  	return font;
  else
  {
  	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	NSString *fontName = [[defaults values] valueForKey: MUPFontName];
  	float fontSize = [(NSNumber *) [[defaults values] valueForKey: MUPFontSize] floatValue];
  	
  	return [NSFont fontWithName: fontName size: fontSize];
  }
}

- (NSString *) effectiveFontDisplayName
{
  if (font)
  {
  	return [font fullDisplayName];
  }
  else
  {
  	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	NSString *fontName = [[defaults values] valueForKey: MUPFontName];
  	NSNumber *fontSize = [[defaults values] valueForKey: MUPFontSize];
  	
  	return [[NSFont fontWithName: fontName size: [fontSize floatValue]] fullDisplayName];
  }
}

- (NSData *) effectiveLinkColor
{
  if (linkColor)
  	return [NSArchiver archivedDataWithRootObject: linkColor];
  else
  {
  	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	
  	return [[defaults values] valueForKey: MUPLinkColor];
  }
}

- (NSData *) effectiveTextColor
{
  if (textColor)
  	return [NSArchiver archivedDataWithRootObject: textColor];
  else
  {
  	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	
  	return [[defaults values] valueForKey: MUPTextColor];
  }
}

- (NSData *) effectiveVisitedLinkColor
{
  if (visitedLinkColor)
  	return [NSArchiver archivedDataWithRootObject: visitedLinkColor];
  else
  {
  	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	
  	return [[defaults values] valueForKey: MUPVisitedLinkColor];
  }
}

#pragma mark -
#pragma mark Actions

- (J3TelnetConnection *) createNewTelnetConnectionWithDelegate: (NSObject <J3ConnectionDelegate> *) delegate
{
  return [world newTelnetConnectionWithDelegate: delegate];
}

- (J3Filter *) createLogger
{
  if (player)
    return [MUTextLogger filterWithWorld: world player: player];
  else
    return [MUTextLogger filterWithWorld: world];
}

- (BOOL) hasLoginInformation
{
  return [self loginString] != nil;
}

#pragma mark -
#pragma mark Property method implementations

- (NSString *) hostname
{
  return world.hostname;
}

- (NSString *) loginString
{
  if (player)
    return player.loginString;
  else
    return nil;
}

- (NSString *) uniqueIdentifier
{
  NSString *identifier = nil;
  if (player)
  {
    // FIXME:  Consider offloading the generation of a unique name for the player on MUPlayer.
    identifier = [NSString stringWithFormat: @"%@.%@",
                  world.uniqueIdentifier, [player.name lowercaseString]];
  }
  else
  {
    identifier = world.uniqueIdentifier;
  }
  return identifier;
}

- (NSString *) windowTitle
{
  return (player ? player.windowTitle : world.windowTitle);
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder: (NSCoder *) encoder
{
  [MUCodingService encodeProfile: self withCoder: encoder];
}

- (id) initWithCoder: (NSCoder *) decoder
{
  [MUCodingService decodeProfile: self withCoder: decoder];
  [self registerForNotifications];
  
  return self;
}

@end

#pragma mark -

@implementation MUProfile (Private)

- (void) globalBackgroundColorDidChange: (NSNotification *) notification
{
  if (!backgroundColor)
  {
  	[self willChangeValueForKey: @"effectiveBackgroundColor"];
  	[self didChangeValueForKey: @"effectiveBackgroundColor"];
  }
}

- (void) globalFontDidChange: (NSNotification *) notification
{
  if (!font)
  {
  	[self willChangeValueForKey: @"effectiveFont"];
  	[self willChangeValueForKey: @"effectiveFontDisplayName"];
  	[self didChangeValueForKey: @"effectiveFont"];
  	[self didChangeValueForKey: @"effectiveFontDisplayName"];
  }
}

- (void) globalTextColorDidChange: (NSNotification *) notification
{
  if (!textColor)
  {
  	[self willChangeValueForKey: @"effectiveTextColor"];
  	[self didChangeValueForKey: @"effectiveTextColor"];
  }
}

- (void) registerForNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalBackgroundColorDidChange:)
  																						 name: MUGlobalBackgroundColorDidChangeNotification
  																					 object: nil];
  	
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalFontDidChange:)
  																						 name: MUGlobalFontDidChangeNotification
  																					 object: nil];
  	
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalTextColorDidChange:)
  																						 name: MUGlobalTextColorDidChangeNotification
  																					 object: nil];
}

@end
