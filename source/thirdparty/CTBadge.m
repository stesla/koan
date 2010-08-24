//
// CTBadge.m
// Version: 2.0
//
// Copyright (c) 2007 Chad Weider.
//
// License:
//
//   Released into Public Domain 4/10/08.
//
// Modifications by Tyler Berry.
// Copyright (c) 2010 3James Software.
//

#import "CTBadge.h"

const float CTLargeBadgeSize = 56.; // 46. was Weider's value. -- TB
const float CTSmallBadgeSize = 23.;
const float CTLargeLabelSize = 30.; // 24. was Weider's value. -- TB
const float CTSmallLabelSize = 11.;

@interface CTBadge (Private)

// Gradient used to fill badge mask
- (NSGradient *) badgeGradient;

// Return a badge with height of <size> to fit <length> characters.
- (NSImage *) badgeMaskOfSize: (float) size length: (unsigned) length;

// Returns appropriately attributed label string (not autoreleased)
- (NSAttributedString *) labelForString: (NSString *) string size: (unsigned) size;

// Returns string for display (replaces large numbers with infinity)
- (NSString *) stringForValue: (unsigned) value;

@end

#pragma mark -

@implementation CTBadge

+ (CTBadge *) systemBadge
{
  id newInstance = [[[self class] alloc] init];
  
  return [newInstance autorelease];
}

+ (CTBadge *) badgeWithColor: (NSColor *) badgeColor labelColor: (NSColor *) labelColor;
{
  id newInstance = [[[self class] alloc] init];
  
  [newInstance setBadgeColor: badgeColor];
  [newInstance setLabelColor: labelColor];
  
  return [newInstance autorelease];
}

- (id) init
{
  if (!(self = [super init]))
    return nil;

  badgeColor = nil;
  labelColor = nil;
    
  [self setBadgeColor: [NSColor redColor]];
  [self setLabelColor: [NSColor whiteColor]];
  
  return self;
}

- (void) dealloc
{
  if (badgeColor != nil)
    [badgeColor release];
  if (labelColor != nil)
    [labelColor release];
  
  [super dealloc];
}

#pragma mark -
#pragma mark Appearance

- (void) setBadgeColor: (NSColor *) theColor;
{
  if (badgeColor != nil)
    [badgeColor release];
  
  badgeColor = theColor;
  [badgeColor retain];
}
- (void) setLabelColor: (NSColor *) theColor;
{
  if (labelColor != nil)
    [labelColor release];
  
  labelColor = theColor;
  [labelColor retain];
}

- (NSColor *) badgeColor
{
  return badgeColor;
}

- (NSColor *) labelColor
{
  return labelColor;
}

#pragma mark -
#pragma mark Drawing

- (NSImage *) smallBadgeForValue: (unsigned) value
{
  return [self badgeOfSize: CTSmallBadgeSize forString: [self stringForValue: value]];
}

- (NSImage *) smallBadgeForString: (NSString *) string
{
  return [self badgeOfSize: CTSmallBadgeSize forString: string];
}

- (NSImage *) largeBadgeForValue: (unsigned) value
{
  return [self badgeOfSize: CTLargeBadgeSize forString: [self stringForValue: value]];
}

- (NSImage *) largeBadgeForString: (NSString *) string
{
  return [self badgeOfSize: CTLargeBadgeSize forString: string];
}

- (NSImage *) badgeOfSize: (float) size forValue: (unsigned) value
{
  return [self badgeOfSize: (float) size forString: [self stringForValue: value]];
}

- (NSImage *) badgeOfSize: (float) size forString: (NSString *) string
{
  float scaleFactor = 1;
  
  if (size <= 0)
    [NSException raise: NSInvalidArgumentException format: @"%@ %@: size (%f) must be positive", [self class], NSStringFromSelector (_cmd), size];
  else if (size <= CTSmallBadgeSize)
    scaleFactor = size / CTSmallBadgeSize;
  else
    scaleFactor = size / CTLargeBadgeSize;
  
  // Label stuff.
  NSAttributedString *label;
  NSSize labelSize;
  
  if (size <= CTSmallBadgeSize)
    label = [self labelForString: string size: CTSmallLabelSize * scaleFactor];
  else
    label = [self labelForString: string size: CTLargeLabelSize * scaleFactor];
  
  labelSize = [label size];
  
  //Badge stuff.
  NSImage *badgeImage;
  NSImage *badgeMask;
  
  NSGradient *badgeGradient = [self badgeGradient];
  
  float shadowOpacity, shadowOffset, shadowBlurRadius;
  
  int angle;
  
  if (size <= CTSmallBadgeSize)
	{
    shadowOpacity = .6;
    shadowOffset = floorf (1 * scaleFactor);
    shadowBlurRadius = ceilf (1 * scaleFactor);
	}
  else
	{
    shadowOpacity = .8;
    shadowOffset = ceilf (1 * scaleFactor);
    shadowBlurRadius = ceilf (2 * scaleFactor);
	}
  
  if ([label length] <= 3) // Badges have different gradient angles.
    angle = -45;
  else
    angle = -30;
  
  badgeMask = [self badgeMaskOfSize: size length: [label length]];
  
  NSSize badgeSize = [badgeMask size];
  NSPoint origin = NSMakePoint (shadowBlurRadius, shadowBlurRadius + shadowOffset);
  
  badgeImage = [[NSImage alloc] initWithSize: NSMakeSize (badgeSize.width + 2 * shadowBlurRadius, // Sometimes it needs more.
                                                          badgeSize.height + 2 * shadowBlurRadius - shadowOffset + (size <= CTSmallBadgeSize))];	// Space when small.
  
  [badgeImage lockFocus];
	[badgeGradient drawInRect: NSMakeRect (origin.x, origin.y, floorf (badgeSize.width), floorf (badgeSize.height)) angle:angle]; // Apply the gradient.
	[badgeMask compositeToPoint: origin operation: NSCompositeDestinationAtop]; // Knock out the badge area.
	[label drawInRect: NSMakeRect (origin.x + floorf ((badgeSize.width - labelSize.width) / 2) + 0.995,
                                 origin.y + floorf ((badgeSize.height - labelSize.height) / 2 + 1.5), badgeSize.width, labelSize.height)]; // Draw label in center.
  [badgeImage unlockFocus];
  
  // Final stuff.
  NSImage *image = [[NSImage alloc] initWithSize: [badgeImage size]];
  
  [image lockFocus];
	[NSGraphicsContext saveGraphicsState];
  NSShadow *theShadow = [[NSShadow alloc] init];
  [theShadow setShadowOffset: NSMakeSize (0, -shadowOffset)];
  [theShadow setShadowBlurRadius :shadowBlurRadius];
  [theShadow setShadowColor: [[NSColor blackColor] colorWithAlphaComponent: shadowOpacity]];
  [theShadow set];
  [theShadow release];
  [badgeImage compositeToPoint: NSZeroPoint operation: NSCompositeSourceOver];
	[NSGraphicsContext restoreGraphicsState];
  [image unlockFocus];
  
  [label release];
  [badgeImage release];
  
  return [image autorelease];
}


- (NSImage *) badgeOverlayImageForString: (NSString *) string insetX: (float) dx y: (float) dy;
{
  NSImage *badgeImage = [self largeBadgeForString:string];
  NSImage *overlayImage = [[NSImage alloc] initWithSize: NSMakeSize (128, 128)];
  
  // Draw large icon in the upper right corner of the overlay image.
  [overlayImage lockFocus];
	NSSize badgeSize = [badgeImage size];
	[badgeImage compositeToPoint: NSMakePoint (128 - dx - badgeSize.width, 128 - dy - badgeSize.height) operation: NSCompositeSourceOver];  
  [overlayImage unlockFocus];
  
  return [overlayImage autorelease];
}

- (void) badgeApplicationDockIconWithString: (NSString *) string insetX: (float) dx y: (float) dy;
{
  NSImage *appIcon = [NSImage imageNamed: @"NSApplicationIcon"];
  NSImage *badgeOverlay = [self badgeOverlayImageForString: string insetX: dx y: dy];
  
  //Put the appIcon underneath the badgeOverlay
  [badgeOverlay lockFocus];
	[appIcon compositeToPoint: NSZeroPoint operation: NSCompositeDestinationOver];
  [badgeOverlay unlockFocus];
  
  [NSApp setApplicationIconImage: badgeOverlay];
}

- (NSImage *) badgeOverlayImageForValue: (unsigned) value insetX: (float) dx y: (float) dy
{
  return [self badgeOverlayImageForString: [self stringForValue: value] insetX: dx y: dy];
}

- (void) badgeApplicationDockIconWithValue: (unsigned) value insetX: (float) dx y: (float) dy
{
  [self badgeApplicationDockIconWithString: [self stringForValue: value] insetX: dx y: dy];
}

@end

#pragma mark -

@implementation CTBadge (Private)

- (NSGradient *) badgeGradient
{
  NSGradient *aGradient = [[NSGradient alloc] initWithColorsAndLocations:[self badgeColor], 0.0, 
                           [self badgeColor], 1 / 3., 
                           [[self badgeColor] shadowWithLevel: 1 / 3.], 1.0, nil];
  
  return [aGradient autorelease];
}

- (NSImage *) badgeMaskOfSize: (float) size length: (unsigned) length;
{
  NSImage *badgeMask;
  
  if (length <=2)
    badgeMask = [NSImage imageNamed: @"CTBadge_1.pdf"];
  else if (length <=3)
    badgeMask = [NSImage imageNamed: @"CTBadge_3.pdf"];
  else if (length <=4)
    badgeMask = [NSImage imageNamed: @"CTBadge_4.pdf"];
  else
    badgeMask = [NSImage imageNamed: @"CTBadge_5.pdf"];
  
  if (size > 0 && size != [badgeMask size].height)
	{
    [badgeMask setName: nil];
    [badgeMask setScalesWhenResized: YES];
    [badgeMask setSize: NSMakeSize ([badgeMask size].width * (size / [badgeMask size].height), size)];
	}
  
  return badgeMask;
}

- (NSAttributedString *) labelForString: (NSString *) label size: (unsigned) size
{
  // Set Attributes to use on String.
  NSFont *labelFont;
  
  if (size <= CTSmallLabelSize)
    labelFont = [NSFont boldSystemFontOfSize: size];
  else
    labelFont = [NSFont fontWithName: @"Helvetica-Bold" size: size];
  
  NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
  [pStyle setAlignment: NSCenterTextAlignment];
  NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [self labelColor], NSForegroundColorAttributeName,
                              labelFont, NSFontAttributeName, nil];
  [pStyle release];
  
  // Label stuff.
  if ([label length] >= 6) // Replace with summarized string - ellipses at end and a zero-width space to trick us into using the 5-wide badge.
    label = [NSString stringWithFormat: @"%@%@", [label substringToIndex: 3], [NSString stringWithUTF8String: "\xe2\x80\xa6\xe2\x80\x8b"]];
  
  NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString: label attributes: attributes];
  [attributes release];
  
  return attributedString;
}

- (NSString *) stringForValue: (unsigned) value
{
  if (value < 100000)
    return [NSString stringWithFormat: @"%u", value];
  else //give infinity
    return [NSString stringWithUTF8String: "\xe2\x88\x9e"];
}

@end
