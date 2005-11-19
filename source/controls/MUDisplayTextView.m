//
// MUDisplayTextView.m
//
// Copyright (c) 2004, 2005 3James Software
//
// Based partially on NSTextViewWithLinks.m
//
// Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//
// IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
// consideration of your agreement to the following terms, and your use, installation, 
// modification or redistribution of this Apple software constitutes acceptance of these 
// terms.  If you do not agree with these terms, please do not use, install, modify or 
// redistribute this Apple software.
//
// In consideration of your agreement to abide by the following terms, and subject to these 
// terms, Apple grants you a personal, non-exclusive license, under Apple's copyrights in 
// this original Apple software (the "Apple Software"), to use, reproduce, modify and 
// redistribute the Apple Software, with or without modifications, in source and/or binary 
// forms; provided that if you redistribute the Apple Software in its entirety and without 
// modifications, you must retain this notice and the following text and disclaimers in all 
// such redistributions of the Apple Software.  Neither the name, trademarks, service marks 
// or logos of Apple Computer, Inc. may be used to endorse or promote products derived from 
// the Apple Software without specific prior written permission from Apple. Except as expressly
// stated in this notice, no other rights or licenses, express or implied, are granted by Apple
// herein, including but not limited to any patent rights that may be infringed by your 
// derivative works or by other works in which the Apple Software may be incorporated.
//
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, 
// EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, 
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS 
// USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
//          OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
// REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND 
// WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR 
// OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MUDisplayTextView.h"
#import "NSCursor (Finger).h"

@implementation MUDisplayTextView

- (NSCursor *) cursorForLink:(NSObject *)linkObject atIndex:(unsigned)charIndex
{
  NSCursor *result = nil;
  
  if ([[self delegate] respondsToSelector:@selector(cursorForLink:atIndex:ofTextView:)])
    result = [[self delegate] cursorForLink:linkObject atIndex:charIndex ofTextView:self];
  
  if (result == nil)
    result = [NSCursor fingerCursor];
  
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
  
  visibleGlyphRange = [[self layoutManager] glyphRangeForBoundingRect:visRect
                                                      inTextContainer:[self textContainer]];
  visibleCharRange = [[self layoutManager] characterRangeForGlyphRange:visibleGlyphRange
                                                      actualGlyphRange:NULL];
  
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
      unsigned rectCount, rectIndex;
      NSRect oneRect;
      
      cursor = [self cursorForLink:linkObject atIndex:attrsRange.location];
      
      rects = [[self layoutManager] rectArrayForCharacterRange:attrsRange
                                  withinSelectedCharacterRange:NSMakeRange (NSNotFound, 0)
                                               inTextContainer:[self textContainer]
                                                     rectCount:&rectCount];
      
      for (rectIndex = 0; rectIndex < rectCount; rectIndex++)
      {
        oneRect = NSIntersectionRect (rects[rectIndex], [self visibleRect]);
        [self addCursorRect:oneRect cursor:cursor];
      }
    }
  }
}

@end
