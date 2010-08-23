//
// MUMCCPProtocolHandler.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUMCCPProtocolHandler.h"

@interface MUMCCPProtocolHandler (Private)

- (unsigned) bytesPending;
- (void) cleanUpStream;
- (void) decompressInbuf;
- (void) decompressAfterAppendingToData: (NSMutableData *) data;
- (void) maybeGrowInbuf: (unsigned) size;
- (void) maybeGrowOutbuf: (unsigned) size;
- (BOOL) initializeStream;

@end

#pragma mark -

@implementation MUMCCPProtocolHandler

+ (id) protocolHandlerWithConnectionState: (J3TelnetConnectionState *) telnetConnectionState
{
  return [[[self alloc] initWithConnectionState: telnetConnectionState] autorelease];
}

- (id) initWithConnectionState: (J3TelnetConnectionState *) telnetConnectionState
{
  if (!(self = [super init]))
    return nil;
  
  connectionState = telnetConnectionState;
  stream = NULL;
  insize = 0;
  outsize = 0;
  
  return self;
}

- (void) dealloc
{
  [self cleanUpStream];
  if (inbuf) free (inbuf);
  if (outbuf) free (outbuf);
  [super dealloc];
}

- (NSData *) parseData: (NSData *) data
{
  if (!connectionState.incomingStreamCompressed)
    return data;
  
  unsigned dataLength = [data length];
  
  if (!stream)
  {
    if ([self initializeStream])
    {
      [self maybeGrowOutbuf: 2048];
    }
    else
    {
      // FIXME: Failing to initialize the stream is a fatal error.
      return [NSData data];
    }
  }
  
  [self maybeGrowInbuf: dataLength];
  memcpy (inbuf + insize, [data bytes], dataLength);
  insize += dataLength;
  
  [self decompressInbuf];
  
  NSMutableData *decompressedData = [NSMutableData dataWithCapacity: dataLength * 2];
  
  while ([self bytesPending])
    [self decompressAfterAppendingToData: decompressedData];
  
  return decompressedData;
}

- (NSData *) preprocessOutput: (NSData *) data
{
  // We don't compress outgoing. There's no point, and no servers support it.
  return data;
}

@end

#pragma mark -

@implementation MUMCCPProtocolHandler (Private)

- (void) cleanUpStream
{
  if (stream)
  {
    inflateEnd (stream);
    free (stream);
    stream = NULL;
  }
}

- (BOOL) initializeStream
{
  stream = (z_stream *) malloc (sizeof (z_stream));
  stream->zalloc = Z_NULL;
  stream->zfree = Z_NULL;
  stream->opaque = Z_NULL;
  stream->next_in = Z_NULL;
  stream->avail_in = 0;
  
  if (inflateInit (stream) != Z_OK)
  {
    // FIXME: this is also a fatal error.
    free (stream);
    stream = NULL;
    return NO;
  }
  
  return YES;
}

- (void) maybeGrowOutbuf: (unsigned) bytes
{
  if (outbuf == NULL)
  {
    outbuf = malloc (bytes);
    outalloc = bytes;
  }
  else
  {
    int old = outalloc;
    
    while (outalloc < outsize + bytes)
      outalloc *= 2;
    
    if (old != outalloc)
      outbuf = realloc (outbuf, outalloc);
  }
}

- (void) maybeGrowInbuf: (unsigned) bytes
{
  if (inbuf == NULL)
  {
    inbuf = malloc (bytes);
    inalloc = bytes;
  }
  else
  {
    int old = inalloc;
    
    while (inalloc < insize + bytes)
      inalloc *= 2;
    
    if (old != inalloc)
      inbuf = realloc (inbuf, inalloc);
  }
}

- (void) decompressAfterAppendingToData: (NSMutableData *) data
{
  if (!outsize)
    return;
  
  [data appendBytes: outbuf length: outsize];
  
  outsize = 0;
  
  [self decompressInbuf];
}

- (void) decompressInbuf
{
  int status;
  
  if (!insize)
    return;
  
  stream->next_in = inbuf;
  stream->next_out = outbuf + outsize;
  stream->avail_in = insize;
  stream->avail_out = outalloc - outsize;
  
  status = inflate (stream, Z_SYNC_FLUSH);
  
  if (status == Z_OK || status == Z_STREAM_END)
  {
    memmove (inbuf, stream->next_in, stream->avail_in);
    insize = stream->avail_in;
    outsize = stream->next_out - outbuf;
    
    if (status == Z_STREAM_END)
    {
      [self maybeGrowOutbuf: insize];
      
      memcpy (outbuf + outsize, inbuf, insize);
      outsize += insize;
      insize = 0;
      
      [self cleanUpStream];
      connectionState.incomingStreamCompressed = NO;
    }
    
    return;
  }
  
  if (status == Z_BUF_ERROR)
  {
    if (outsize * 2 > outalloc)
    {
      [self maybeGrowOutbuf: outalloc];
      [self decompressInbuf];
    }
    
    return;
  }
  
  // We have some other status error.
  // FIXME: this is a fatal error.
}

- (unsigned) bytesPending
{
  return outsize;
}

@end
