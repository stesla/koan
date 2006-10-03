//
//  NSFont (Traits).h
//  Koan
//
//  Created by Samuel on 10/2/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFont (Traits)

- (NSFont *) fontWithTrait:(NSFontTraitMask)trait;
- (BOOL) hasTrait:(NSFontTraitMask)trait;
- (BOOL) isBold;
- (BOOL) isItalic;

@end
