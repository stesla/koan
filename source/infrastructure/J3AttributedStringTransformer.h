//
// J3AttributedStringTransformer.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3AttributedStringTransforming

- (NSAttributedString *) transform:(NSAttributedString *)string 
                      upToLocation:(int)location;
- (int) location;
- (NSString *) name;

@end

#pragma mark -

@interface J3AttributedStringTransformer : NSObject 
{
  NSMutableArray *transforms;
}

+ (J3AttributedStringTransformer *) transformer;

- (void) changeAttributeWithName:(NSString *)name 
                         toValue:(id)value
                      atLocation:(int)location;

- (NSAttributedString *) transform:(NSAttributedString *)string;

@end
