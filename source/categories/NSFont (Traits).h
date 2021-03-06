//
// NSFont (Traits).h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface NSFont (Traits)

- (NSFont *) fontWithTrait: (NSFontTraitMask)trait;
- (BOOL) hasTrait: (NSFontTraitMask)trait;
- (BOOL) isBold;
- (BOOL) isItalic;

@end
