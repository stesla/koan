//
// Main.c
//
// Copyright (c) 2010 3James Software.
//

//==============================================================================
//
// This file contains the generic CFPlug-in code necessary for your importer
// To complete an importer implement the function in GetMetadataForFile.c.
// Most of the logic should be left unmodified.
//
//==============================================================================

#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFPlugInCOM.h>
#include <CoreServices/CoreServices.h>

#include "GetMetadataForFile.h"

#define PLUGIN_ID "7A7C8D06-11D4-48AF-B144-BDFFD271795F"
			   
// The layout for an instance of MetaDataImporterPlugIn. 
typedef struct __MetadataImporterPluginType
{
  MDImporterInterfaceStruct *conduitInterface;
  CFUUIDRef factoryID;
  UInt32 refCount;
} MetadataImporterPluginType;

// Forward declarations for the IUnknown implementation.

MetadataImporterPluginType *AllocMetadataImporterPluginType (CFUUIDRef inFactoryID);
void DeallocMetadataImporterPluginType (MetadataImporterPluginType *thisInstance);
HRESULT MetadataImporterQueryInterface (void *thisInstance, REFIID iid, LPVOID *ppv);
void *MetadataImporterPluginFactory (CFAllocatorRef allocator, CFUUIDRef typeID);
ULONG MetadataImporterPluginAddRef (void *thisInstance);
ULONG MetadataImporterPluginRelease (void *thisInstance);

// The TestInterface function table.

static MDImporterInterfaceStruct testInterfaceFunctionTable =
{
  NULL,
  MetadataImporterQueryInterface,
  MetadataImporterPluginAddRef,
  MetadataImporterPluginRelease,
  GetMetadataForFile
};

// Utility function that allocates a new instance.
// Initial setup for the importer, such as allocating globals, etc., can be done
// here.

MetadataImporterPluginType *
AllocMetadataImporterPluginType (CFUUIDRef inFactoryID)
{
  MetadataImporterPluginType *newInstance = (MetadataImporterPluginType *) malloc (sizeof (MetadataImporterPluginType));
  memset (newInstance, 0, sizeof (MetadataImporterPluginType));

  newInstance->conduitInterface = &testInterfaceFunctionTable;

  // Retain and keep an open instance refcount for each factory.
  newInstance->factoryID = CFRetain (inFactoryID);
  CFPlugInAddInstanceForFactory (inFactoryID);

  // This function returns the IUnknown interface so set the refCount to one.
  newInstance->refCount = 1;
  return newInstance;
}

// -----------------------------------------------------------------------------
//	DeallocKoanLogImporterMDImporterPluginType
// -----------------------------------------------------------------------------
//	Utility function that deallocates the instance when
//	the refCount goes to zero.
//      In the current implementation importer interfaces are never deallocated
//      but implement this as this might change in the future
//
void
DeallocMetadataImporterPluginType (MetadataImporterPluginType *instance)
{
  CFUUIDRef factoryID = instance->factoryID;
  
  free (instance);
  if (factoryID)
  {
    CFPlugInRemoveInstanceForFactory ((CFUUIDRef) instance);
    CFRelease (instance);
  }
}

// -----------------------------------------------------------------------------
//	MetadataImporterQueryInterface
// -----------------------------------------------------------------------------
//	Implementation of the IUnknown QueryInterface function.
//
HRESULT
MetadataImporterQueryInterface (void *thisInstance, REFIID iid, LPVOID *ppv)
{
  CFUUIDRef interfaceID;
  
  interfaceID = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault,iid);
  
  if (CFEqual(interfaceID,kMDImporterInterfaceID)){
    /* If the Right interface was requested, bump the ref count,
     * set the ppv parameter equal to the instance, and
     * return good status.
     */
    ((MetadataImporterPluginType*)thisInstance)->conduitInterface->AddRef(thisInstance);
    *ppv = thisInstance;
    CFRelease(interfaceID);
    return S_OK;
  }
  else
  {
    if (CFEqual(interfaceID,IUnknownUUID))
    {
      /* If the IUnknown interface was requested, same as above. */
            ((MetadataImporterPluginType*)thisInstance )->conduitInterface->AddRef(thisInstance);
      *ppv = thisInstance;
      CFRelease(interfaceID);
      return S_OK;
    }
    else
    {
      /* Requested interface unknown, bail with error. */
      *ppv = NULL;
      CFRelease(interfaceID);
      return E_NOINTERFACE;
    }
  }
}

// -----------------------------------------------------------------------------
//	MetadataImporterPluginAddRef
// -----------------------------------------------------------------------------
//	Implementation of reference counting for this type. Whenever an interface
//	is requested, bump the refCount for the instance. NOTE: returning the
//	refcount is a convention but is not required so don't rely on it.

ULONG
MetadataImporterPluginAddRef (void *instance)
{
  ((MetadataImporterPluginType *) instance)->refCount += 1;
  return ((MetadataImporterPluginType *) instance)->refCount;
}

// -----------------------------------------------------------------------------
// SampleCMPluginRelease
// -----------------------------------------------------------------------------
//	When an interface is released, decrement the refCount.
//	If the refCount goes to zero, deallocate the instance.

ULONG
MetadataImporterPluginRelease (void *instance)
{
  ((MetadataImporterPluginType *) instance)->refCount -= 1;
  if (((MetadataImporterPluginType *) instance)->refCount == 0)
  {
    DeallocMetadataImporterPluginType ((MetadataImporterPluginType *) instance);
    return 0;
  }
  else
  {
    return ((MetadataImporterPluginType *) instance)->refCount;
  }
}

// -----------------------------------------------------------------------------
//	KoanLogImporterMDImporterPluginFactory
// -----------------------------------------------------------------------------
//	Implementation of the factory function for this type.

void *
MetadataImporterPluginFactory (CFAllocatorRef allocator, CFUUIDRef typeID)
{
  MetadataImporterPluginType *result;
  CFUUIDRef uuid;
  
  /* If correct type is being requested, allocate an
   * instance of TestType and return the IUnknown interface.
   */
  if (CFEqual (typeID, kMDImporterTypeID))
  {
    uuid = CFUUIDCreateFromString (kCFAllocatorDefault, CFSTR (PLUGIN_ID));
    result = AllocMetadataImporterPluginType (uuid);
    CFRelease (uuid);
    return result;
  }
  
  /* If the requested type is incorrect, return NULL. */
  return NULL;
}

