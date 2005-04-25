//
// MUProfile.m
//
// Copyright (c) 2004, 2005 3James Softwareautoconnect
//

#import "MUCodingService.h"
#import "MUProfile.h"
#import "J3TextLogger.h"

@interface MUProfile (Private)

- (void) globalBackgroundColorDidChange:(NSNotification *)notification;
- (void) globalFontDidChange:(NSNotification *)notification;
- (void) globalTextColorDidChange:(NSNotification *)notification;
- (void) registerForNotifications;

@end

#pragma mark -

@implementation MUProfile

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key
{
	static NSArray *keyArray;
	
	if (!keyArray)
	{
		keyArray = [NSArray arrayWithObjects:
			@"effectiveFont",
			@"effectiveTextColor",
			@"effectiveBackgroundColor",
			@"effectiveLinkColor",
			@"effectiveVisitedLinkColor",
			nil];
	}
	
	if ([keyArray containsObject:key])
		return NO;
	else
		return YES;
}

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld 
                          player:(MUPlayer *)newPlayer
                     autoconnect:(BOOL)newAutoconnect
{
  return [[[self alloc] initWithWorld:newWorld
                               player:newPlayer
                          autoconnect:newAutoconnect] autorelease];
}

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer
{
  return [[[self alloc] initWithWorld:newWorld 
                               player:newPlayer] autorelease];
}

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld
{
  return [[[self alloc] initWithWorld:newWorld] autorelease];
}

- (id) initWithWorld:(MUWorld *)newWorld 
              player:(MUPlayer *)newPlayer
         autoconnect:(BOOL)newAutoconnect
								font:(NSFont *)newFont
					 textColor:(NSColor *)newTextColor
		 backgroundColor:(NSColor *)newBackgroundColor
					 linkColor:(NSColor *)newLinkColor
		visitedLinkColor:(NSColor *)newVisitedLinkColor
{
	self = [super init];
	
  if (self && newWorld)
  {
    [self setWorld:newWorld];
    [self setPlayer:newPlayer];
    [self setAutoconnect:newAutoconnect];
		[self setFont:newFont];
		[self setTextColor:newTextColor];
		[self setBackgroundColor:newBackgroundColor];
		[self setLinkColor:newLinkColor];
		[self setVisitedLinkColor:newVisitedLinkColor];
		
		[self registerForNotifications];
  }
  return self;
}

- (id) initWithWorld:(MUWorld *)newWorld 
              player:(MUPlayer *)newPlayer
         autoconnect:(BOOL)newAutoconnect
{
	return [self initWithWorld:newWorld
											player:newPlayer
								 autoconnect:newAutoconnect
												font:nil
									 textColor:nil
						 backgroundColor:nil
									 linkColor:nil
						visitedLinkColor:nil];
}

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer
{
  return [self initWithWorld:newWorld 
                      player:newPlayer 
                 autoconnect:NO];
}

- (id) initWithWorld:(MUWorld *)newWorld
{
  return [self initWithWorld:newWorld player:nil];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
  [player release];
  [world release];
  [super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (MUWorld *) world
{
  return world;
}

- (void) setWorld:(MUWorld *)newWorld
{
  [newWorld retain];
  [world release];
  world = newWorld;
}

- (MUPlayer *) player
{
  return player;
}

- (void) setPlayer:(MUPlayer *)newPlayer
{
  [newPlayer retain];
  [player release];
  player = newPlayer;
}

- (BOOL) autoconnect
{
  return autoconnect;
}

- (void) setAutoconnect:(BOOL)newAutoconnect
{
  autoconnect = newAutoconnect;
}

- (NSFont *) font
{
	return font;
}

- (void) setFont:(NSFont *)newFont
{
	if (![font isEqual:newFont])
	{
		[self willChangeValueForKey:@"effectiveFont"];
		[font release];
		font = [newFont copy];
		[self didChangeValueForKey:@"effectiveFont"];
	}
}

- (NSColor *) textColor
{
	return textColor;
}

- (void) setTextColor:(NSColor *)newTextColor
{
	if (![textColor isEqual:newTextColor])
	{
		[self willChangeValueForKey:@"effectiveTextColor"];
		[textColor release];
		textColor = [newTextColor copy];
		[self didChangeValueForKey:@"effectiveTextColor"];
	}
}

- (NSColor *) backgroundColor
{
	return backgroundColor;
}

- (void) setBackgroundColor:(NSColor *)newBackgroundColor
{
	if (![backgroundColor isEqual:newBackgroundColor])
	{
		[self willChangeValueForKey:@"effectiveBackgroundColor"];
		[backgroundColor release];
		backgroundColor = [newBackgroundColor copy];
		[self didChangeValueForKey:@"effectiveBackgroundColor"];
	}
}

- (NSColor *) linkColor
{
	return linkColor;
}

- (void) setLinkColor:(NSColor *)newLinkColor
{
	if (![linkColor isEqual:newLinkColor])
	{
		[self willChangeValueForKey:@"effectiveLinkColor"];
		[linkColor release];
		linkColor = [newLinkColor copy];
		[self didChangeValueForKey:@"effectiveLinkColor"];
	}
}

- (NSColor *) visitedLinkColor
{
	return visitedLinkColor;
}

- (void) setVisitedLinkColor:(NSColor *)newVisitedLinkColor
{
	if (![visitedLinkColor isEqual:newVisitedLinkColor])
	{
		[self willChangeValueForKey:@"effectiveVisitedLinkColor"];
		[visitedLinkColor release];
		visitedLinkColor = [newVisitedLinkColor copy];
		[self didChangeValueForKey:@"effectiveVisitedLinkColor"];
	}
}

#pragma mark -
#pragma mark Accessors for bindings

- (NSFont *) effectiveFont
{
	if (font)
		return font;
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		NSString *fontName = [[defaults values] valueForKey:MUPFontName];
		float fontSize = [(NSNumber *) [[defaults values] valueForKey:MUPFontSize] floatValue];
		
		return [NSFont fontWithName:fontName size:fontSize];
	}
}

- (NSColor *) effectiveTextColor
{
	if (textColor)
		return textColor;
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPTextColor];
	}
}

- (NSColor *) effectiveBackgroundColor
{
	if (backgroundColor)
		return backgroundColor;
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPBackgroundColor];
	}
}

- (NSColor *) effectiveLinkColor
{
	if (linkColor)
		return linkColor;
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPTextColor];
	}
}

- (NSColor *) effectiveVisitedLinkColor
{
	if (visitedLinkColor)
		return visitedLinkColor;
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPTextColor];
	}
}

#pragma mark -
#pragma mark Actions

- (NSString *) hostname;
{
  return [world worldHostname];
}

- (J3Filter *) logger
{
  if (player)
    return [J3TextLogger filterWithWorld:world player:player];
  else
    return [J3TextLogger filterWithWorld:world];
}

- (NSString *) loginString
{
  return [player loginString];
}

- (NSString *) uniqueIdentifier
{
  NSString *rval = nil;
  if (player)
  {
    // Consider offloading the generation of a unique name for the player on
    // MUPlayer.
    rval = [NSString stringWithFormat:@"%@.%@", 
      [world uniqueIdentifier], [[player name] lowercaseString]];
  }
  else
  {
    rval = [world uniqueIdentifier];
  }
  return rval;
}

- (NSString *) windowTitle
{
  return (player ? [player windowTitle] : [world windowTitle]);
}

- (J3TelnetConnection *) openTelnetWithDelegate:(id)delegate
{
  J3TelnetConnection *telnet = [world newTelnetConnection];
  
  if (telnet)
  {
    [telnet setDelegate:delegate];
    [telnet open];
  }  
  
  return telnet;
}

- (void) loginWithConnection:(J3TelnetConnection *)connection
{
  if (!loggedIn && player)
  {
    [connection sendLine:[player loginString]];
    loggedIn = YES;
  }
}

- (void) logoutWithConnection:(J3TelnetConnection *)connection
{
  // We don't do anything with the connection at this point, but we could.
  // I put it there for parallelism with -loginWithConnection: and to make it
  // easy to add any shutdown we may decide we need later.
  loggedIn = NO;
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [MUCodingService encodeProfile:self withCoder:encoder];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  [MUCodingService decodeProfile:self withCoder:decoder];
	[self registerForNotifications];
	
	return self;
}

@end

#pragma mark -

@implementation MUProfile (Private)

- (void) globalBackgroundColorDidChange:(NSNotification *)notification
{
	if (!backgroundColor)
	{
		[self willChangeValueForKey:@"effectiveBackgroundColor"];
		[self didChangeValueForKey:@"effectiveBackgroundColor"];
	}
}

- (void) globalFontDidChange:(NSNotification *)notification
{
	if (!font)
	{
		[self willChangeValueForKey:@"effectiveFont"];
		[self didChangeValueForKey:@"effectiveFont"];
	}
}

- (void) globalTextColorDidChange:(NSNotification *)notification
{
	if (!textColor)
	{
		[self willChangeValueForKey:@"effectiveTextColor"];
		[self didChangeValueForKey:@"effectiveTextColor"];
	}
}

- (void) registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(globalBackgroundColorDidChange:)
																							 name:MUGlobalBackgroundColorDidChangeNotification
																						 object:nil];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(globalFontDidChange:)
																							 name:MUGlobalFontDidChangeNotification
																						 object:nil];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(globalTextColorDidChange:)
																							 name:MUGlobalTextColorDidChangeNotification
																						 object:nil];
}

@end
