//
//  J3AttributedStringTransformer.m
//  Koan
//
//  Created by Samuel on 2/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3AttributedStringTransformer.h"

@interface J3AttributedStringTransform : NSObject
{
  NSString *name;
  id value;
  int location;
}

- (id) initTransformWithName:(NSString *)aName 
                       value:(id)aValue
                  atLocation:(int)aLocation;

- (NSAttributedString *) transform:(NSAttributedString *)string 
                      upToLocation:(int)aLocation;
@end

@implementation J3AttributedStringTransform
- (id) initTransformWithName:(NSString *)aName 
                       value:(id)aValue
                  atLocation:(int)aLocation;
{
  self = [super init];
  if (self)
  {
    [aName retain];
    name = aName;
    
    [aValue retain];
    value = aValue;
    
    location = aLocation;
  }
  return self;
}

- (void) dealloc
{
  [name release];
  [value release];
  [super dealloc];
}

- (NSAttributedString *) transform:(NSAttributedString *)string 
                      upToLocation:(int)aLocation
{
  NSMutableAttributedString *stringCopy = [[string mutableCopy] autorelease];
  NSMutableDictionary *dict = 
    [[[string attributesAtIndex:location 
                 effectiveRange:NULL] 
      mutableCopy] autorelease];
  NSRange range;

  [dict setValue:value forKey:name];
  range.location = location;
  range.length = aLocation - location;
  [stringCopy setAttributes:dict range:range];
  return stringCopy;
}
@end

@implementation J3AttributedStringTransformer

+ (J3AttributedStringTransformer *) transformer
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  self = [super init];
  {
    transforms = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) release
{
  [transforms release];
  [super dealloc];
}

- (void) changeAttributeWithName:(NSString *)aName 
                         toValue:(id)aValue
                         atLocation:(int)aLocation
{
  J3AttributedStringTransform *transform =
    [[J3AttributedStringTransform alloc] initTransformWithName:aName
                                                         value:aValue
                                                    atLocation:aLocation];
  [transforms addObject:transform];
}

- (NSAttributedString *) transform:(NSAttributedString *)aString
{
  return [[transforms objectAtIndex:0] transform:aString
                                    upToLocation:[aString length]];
}

@end
