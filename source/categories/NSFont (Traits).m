//
// NSFont (Traits).m
//
// Copyright (c) 2010 3James Software.
//

#import "NSFont (Traits).h"

@implementation NSFont (Traits)

- (NSFont *) fontWithTrait: (NSFontTraitMask) trait
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  return [fontManager convertFont: self toHaveTrait: trait];
}

- (BOOL) hasTrait: (NSFontTraitMask) trait
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  return [fontManager fontNamed: [self fontName] hasTraits: trait];
}

- (BOOL) isBold
{
  return [self hasTrait: NSBoldFontMask];
}

- (BOOL) isItalic
{
  return [self hasTrait: NSItalicFontMask];
}

@end
