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
			@"effectiveFontDisplayName",
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
		[self willChangeValueForKey:@"effectiveFontDisplayName"];
		[font release];
		font = [newFont copy];
		[self didChangeValueForKey:@"effectiveFont"];
		[self didChangeValueForKey:@"effectiveFontDisplayName"];
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

- (NSData *) effectiveBackgroundColor
{
	if (backgroundColor)
		return [NSArchiver archivedDataWithRootObject:backgroundColor];
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPBackgroundColor];
	}
}

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

- (NSString *) effectiveFontDisplayName
{
	if (font)
	{
		return [font fullDisplayName];
	}
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		NSString *fontName = [[defaults values] valueForKey:MUPFontName];
		NSNumber *fontSize = [[defaults values] valueForKey:MUPFontSize];
		
		return [[NSFont fontWithName:fontName size:[fontSize floatValue]] fullDisplayName];
	}
}

- (NSData *) effectiveLinkColor
{
	if (linkColor)
		return [NSArchiver archivedDataWithRootObject:linkColor];
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPLinkColor];
	}
}

- (NSData *) effectiveTextColor
{
	if (textColor)
		return [NSArchiver archivedDataWithRootObject:textColor];
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPTextColor];
	}
}

- (NSData *) effectiveVisitedLinkColor
{
	if (visitedLinkColor)
		return [NSArchiver archivedDataWithRootObject:visitedLinkColor];
	else
	{
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		
		return [[defaults values] valueForKey:MUPVisitedLinkColor];
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

- (J3Telnet *) createNewTelnetConnectionWithDelegate:(id <NSObject, J3LineBufferDelegate, J3ConnectionDelegate>)object;
{
  J3Telnet *telnet = [world newTelnetConnectionWithDelegate:object];
  
  if (telnet)
  {
    [telnet scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  }
  return telnet;
}

- (void) loginWithConnection:(J3Telnet *)connection
{
  if (!loggedIn && player)
  {
    NSString *loginString = [player loginString];
    
    [connection writeLine:loginString];
    loggedIn = YES;
  }
}

- (void) logoutWithConnection:(J3Telnet *)connection
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
		[self willChangeValueForKey:@"effectiveFontDisplayName"];
		[self didChangeValueForKey:@"effectiveFont"];
		[self didChangeValueForKey:@"effectiveFontDisplayName"];
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
