//
// MUForwardingTextView.m
//
// Copyright (C) 2004 3James Software
//

#import "MUForwardingTextView.h"

@implementation MUForwardingTextView

+ (NSCursor *) fingerCursor;			// really should be in a category on NSCursor
{
  static NSCursor *fingerCursor = nil;
  
  if (fingerCursor == nil)
  {
    fingerCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"finger-cursor"]
                                           hotSpot:NSMakePoint (0, 0)];
  }
  
  return fingerCursor;
}

- (NSCursor *) cursorForLink:(NSObject *)linkObject atIndex:(unsigned)charIndex
{
  NSCursor *result = nil;
  
  if ([[self delegate] respondsToSelector:@selector(cursorForLink:atIndex:ofTextView:)])
    result = [[self delegate] cursorForLink:linkObject atIndex:charIndex ofTextView:self];
  
  if (result == nil)
    result = [[self class] fingerCursor];
  return result;
}

- (void) resetCursorRects
{
  NSAttributedString *attrString;
  NSPoint containerOrigin;
  NSRect visRect;
  NSRange visibleGlyphRange, visibleCharRange, attrsRange;
  
  attrString = [self textStorage];
  
  containerOrigin = [self textContainerOrigin];
  visRect = NSOffsetRect ([self visibleRect], -containerOrigin.x, -containerOrigin.y);
  
  visibleGlyphRange = [[self layoutManager] glyphRangeForBoundingRect:visRect inTextContainer:[self textContainer]];
  visibleCharRange = [[self layoutManager] characterRangeForGlyphRange:visibleGlyphRange actualGlyphRange:NULL];
  
  attrsRange = NSMakeRange (visibleCharRange.location, 0);
  
  while (NSMaxRange (attrsRange) < NSMaxRange (visibleCharRange))
  {
    NSString *linkObject;
    
    linkObject = [attrString attribute:NSLinkAttributeName 
                               atIndex:NSMaxRange (attrsRange)
                        effectiveRange:&attrsRange];
    
    if (linkObject != nil)
    {
      NSCursor *cursor;
      NSRectArray rects;
      unsigned int rectCount, rectIndex;
      NSRect oneRect;
      
      cursor = [self cursorForLink:linkObject atIndex:attrsRange.location];
      
      rects = [[self layoutManager] rectArrayForCharacterRange: attrsRange
                                  withinSelectedCharacterRange: NSMakeRange (NSNotFound, 0)
                                               inTextContainer: [self textContainer]
                                                     rectCount: &rectCount];
      
      for (rectIndex = 0; rectIndex < rectCount; rectIndex++)
      {
        oneRect = NSIntersectionRect (rects[rectIndex], [self visibleRect]);
        [self addCursorRect:oneRect cursor:cursor];
      }
    }
  }
}

- (void) insertText:(id)string
{
  [targetTextView insertText:string];
  [[self window] makeFirstResponder:targetTextView];
}

@end
