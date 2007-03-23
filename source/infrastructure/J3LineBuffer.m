//
// J3LineBuffer.m
//
// Copyright (c) 2005, 2007 3James Software
//

#import "J3LineBuffer.h"

@implementation J3LineBuffer

// FIXME: ideally -appendByte: would only be used for binary data. This is going to cause issues later with multibyte stuff.
- (void) appendBytes: (uint8_t *) bytes length: (unsigned) length
{
  uint8_t *origin = bytes;
  unsigned offset = 0;
  
  for (unsigned span = 0; span < length; span++)
  {
    if (bytes[span] == (uint8_t) '\n')
    {
      [super appendBytes: origin length: span + 1];
      [self flush];
      
      origin += span + 1;
      offset += span + 1;
      
      if (bytes[span + 1] == (uint8_t) '\r')
      {
        span++;
        origin++;
        offset++;
      }
    }
  }
  
  [super appendBytes: origin length: length - offset];
}

- (void) appendString: (NSString *) string
{
  NSRange searchRange = NSMakeRange (0, [string length]);
  unsigned indexOfNewline = [string indexOfCharacter: (unichar) '\n' range: searchRange];
  
  while (indexOfNewline != NSNotFound && searchRange.location < [string length])
  {
    [super appendString: [string substringWithRange: NSMakeRange (searchRange.location, indexOfNewline + 1)]];
    [self flush];
      
    searchRange.location += indexOfNewline + 1;
    searchRange.length -= indexOfNewline + 1;
    
    indexOfNewline = [string indexOfCharacter: '\n' range: searchRange];
  }
  
  [super appendString: [string substringWithRange: searchRange]];
}

@end
