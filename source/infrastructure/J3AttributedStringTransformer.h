//
//  J3AttributedStringTransformer.h
//  Koan
//
//  Created by Samuel on 2/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface J3AttributedStringTransformer : NSObject 
{
  NSMutableArray *transforms;
}

+ (J3AttributedStringTransformer *) transformer;

- (void) changeAttributeWithName:(NSString *)aName 
                         toValue:(id)aValue
                      atLocation:(int)aLocation;
- (NSAttributedString *) transform:(NSAttributedString *)aString;

@end
