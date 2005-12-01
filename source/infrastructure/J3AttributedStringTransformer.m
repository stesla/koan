//
// J3AttributedStringTransformer.m
//
// Copyright (c) 2005 3James Software
//

#import "J3AttributedStringTransformer.h"

@interface J3AttributedStringTransform : NSObject <J3AttributedStringTransforming>
{
  NSString *name;
  id value;
  int location;
}

- (id) initTransformWithName:(NSString *)newName 
                       value:(id)newValue
                  atLocation:(int)newLocation;

- (NSAttributedString *) transform:(NSAttributedString *)string 
                      upToLocation:(int)endLocation;
- (int) location;

@end

#pragma mark -

@implementation J3AttributedStringTransform

- (id) initTransformWithName:(NSString *)newName 
                       value:(id)newValue
                  atLocation:(int)newLocation
{
  if (![super init])
    return nil;
  
  name = [newName copy];
  value = [newValue copy];
  location = newLocation;
  
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

- (NSString *) name
{
  return name;
}

- (NSAttributedString *) transform:(NSAttributedString *)string 
                      upToLocation:(int)endLocation
{
  NSMutableAttributedString *stringCopy = [[string mutableCopy] autorelease];
  NSMutableDictionary *dict =
    [[[string attributesAtIndex:location
                 effectiveRange:NULL] mutableCopy] autorelease];
  NSRange range;

  [dict setValue:value forKey:name];
  range.location = location;
  range.length = endLocation - location;
  [stringCopy setAttributes:dict range:range];
  
  return stringCopy;
}

@end

#pragma mark -

@interface J3AttributedStringTransformer (Private)

- (id <J3AttributedStringTransforming>) nextTransformAfter:(id <J3AttributedStringTransforming>)transform;

@end

#pragma mark -

@implementation J3AttributedStringTransformer

+ (J3AttributedStringTransformer *) transformer
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  
  transforms = [[NSMutableArray alloc] init];
  
  return self;
}

- (void) release
{
  [transforms release];
  [super dealloc];
}

- (void) changeAttributeWithName:(NSString *)name 
                         toValue:(id)value
                         atLocation:(int)location
{
  J3AttributedStringTransform *transform =
    [[J3AttributedStringTransform alloc] initTransformWithName:name
                                                         value:value
                                                    atLocation:location];
  [transforms addObject:transform];
}

- (NSAttributedString *) transform:(NSAttributedString *)string
{
  NSAttributedString *resultString = [[string copy] autorelease];
  id <J3AttributedStringTransforming> transform, nextTransform;
  int i, location, count = [transforms count], length = [string length];
  
  for (i = 0; i < count; i++)
  {
    transform = [transforms objectAtIndex:i];
    
    if ([transform location] >= length)
      break;
    
    nextTransform = [self nextTransformAfter:transform];
    if (nextTransform)
    {
      location = [nextTransform location];
    }
    else
    {
      location = length;
    }
    
    resultString = [transform transform:resultString
                           upToLocation:location];
  }
  return resultString;
}

@end

#pragma mark -

@implementation J3AttributedStringTransformer (Private)

- (id <J3AttributedStringTransforming>) nextTransformAfter:(id <J3AttributedStringTransforming>)transform
{
  int i = [transforms indexOfObject:transform] + 1, count = [transforms count];
  id <J3AttributedStringTransforming> currentTransform = nil;
  BOOL found = NO;
  
  while (!found && (i < count))
  {
    currentTransform = [transforms objectAtIndex:i];
    if ([[currentTransform name] isEqualToString:[transform name]])
      found = YES;
    i++;
  }
  
  if (found)
    return currentTransform;
  else
    return nil;
}

@end
