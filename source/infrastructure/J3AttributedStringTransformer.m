//
//  J3AttributedStringTransformer.m
//  Koan
//
//  Created by Samuel on 2/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3AttributedStringTransformer.h"

@interface J3AttributedStringTransform : NSObject<J3AttributedStringTransforming>
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
- (int) location;
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

- (int) location
{
  return location;
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
  NSAttributedString *resultString = [[aString copy] autorelease];
  id<J3AttributedStringTransforming> transform;
  int i, location, count = [transforms count], length = [aString length];
  
  for (i = 0; i < count; i++)
  {
    transform = [transforms objectAtIndex:i];
    
    if ([transform location] >= length)
      break;
    
    if (i == (count - 1))
    {
      location = length;
    }
    else
    {
      location = [(id<J3AttributedStringTransforming>)
        [transforms objectAtIndex:i+1] location];
    }
    
    resultString = [transform transform:resultString
                           upToLocation:location];
  }
  return resultString;
}

@end
