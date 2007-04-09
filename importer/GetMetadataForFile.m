//
// GetMetadataForFile.m
//
// Copyright (c) 2007 3James Software
//

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 
#include <Foundation/Foundation.h>
#include "MUTextLogDocument.h"

Boolean
GetMetadataForFile (void *thisInterface,
                    CFMutableDictionaryRef attributes,
                    CFStringRef contentTypeUTI,
                    CFStringRef pathToFile)
{
  Boolean result = FALSE;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  MUTextLogDocument *logDocument = [[MUTextLogDocument alloc] initWithContentsOfURL: [NSURL fileURLWithPath: (NSString *) pathToFile]
                                                                             ofType: nil
                                                                              error: nil];
  
  if (logDocument)
  {
    [logDocument fillDictionaryWithMetadata: (NSMutableDictionary *) attributes];
    [logDocument release];
    result = TRUE;
  }
  
  [pool release];
  return result;
}
