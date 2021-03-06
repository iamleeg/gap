/*

  Archive.m
  Zipper

  Copyright (C) 2012-2015 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/Foundation.h>
#import "Archive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "NSObject+Custom.h"
#import "Preferences.h"

#define X_EXE_NOT_FOUND	@"ExecutableNotFoundException"

/**
 * This dictionary holds all the file extensions that Archive and its subclasses
 * are able to decompress. Archive subclasses register themselves with 
 * the Archive class.
 */
static NSMutableDictionary *_fileExtMappings = nil;

@interface Archive (PrivateAPI)
- (void)sortElementsBySortOrder:(int) sortOrder selector:(SEL)selector;
@end

@implementation Archive : NSObject

+ (void)initialize
{
	if (_fileExtMappings == nil)
	{
		_fileExtMappings = [[NSMutableDictionary alloc] init];
	}
}

/**
 * All subclasses must register the file extensions they support with the Archive
 * class. This faciliates dynamic addition of Archive subclasses and helps
 * the app discover who's responsible for certain file extensions.
 */
+ (void)registerFileExtension:(NSString *)extension forArchiveClass:(Class)clazz
{
	[_fileExtMappings setObject:clazz forKey:extension];
}

+ (Class)classForFileExtension:(NSString *)fileExtension;
{
	return [_fileExtMappings objectForKey:fileExtension];
}

+ (NSArray *)allFileExtensions;
{
	return [_fileExtMappings allKeys];
}

/**
 * Returns an NSArray containing all archiver classes that are currently registered.
 */
+ (NSArray *)allArchivers;
{
	return [_fileExtMappings allValues];
}

/**
 * Returns YES if this kind of archives contains information about the compression ratio of
 * the archive, else NO.
 */
+ (BOOL)hasRatio
{
	return NO;
}

/**
 * Returns YES if this kind of archiver can uncopress files 'flat' i.e. without directory
 * information, else NO.
 */
+ (BOOL)canExtractWithoutFullPath
{
	return YES;
}

/**
 * Returns an NSData that can be compared against the first 4 bytes of the file to
 * determine the file type. This implementation returns nil.
 */
+ (NSData *)magicBytes
{
	return nil;
}

+ (Archive *)newWithPath:(NSString *)path
{
    NSParameterAssert(path != nil);
    return [[[self alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString *)path
{
    [super init];
    _path = [path retain];
    _elements = nil;
    _sortOrder = NSOrderedAscending;
    _sortAttribute = SortByPath;
    return self;
}

- (void)dealloc
{
  [_path release];
  [_elements release];
  [super dealloc];
}

- (NSString *)path
{
	return _path;
}

//------------------------------------------------------------------------------
// managing our elements
//------------------------------------------------------------------------------
- (NSArray *)elements
{
    if (_elements == nil)
    {
        [self setElements:[self listContents]];
    }
    return _elements;
}

- (void)setElements:(NSArray *)elements
{
  [_elements release];
  _elements = elements;
  [_elements retain];
}

- (int)elementCount
{
    return [[self elements] count];
}

- (FileInfo *)elementAtIndex:(int)index
{
    return [[self elements] objectAtIndex:index];
}

//------------------------------------------------------------------------------
// sorting our elements
//------------------------------------------------------------------------------
- (void)sortByPath
{
	NSArray * sortedElements = nil;
	
	// make sure we start by ordering in descending order when this column is clicked first
	if (_sortAttribute != SortByPath)
	{
		_sortAttribute = SortByPath;
		_sortOrder = NSOrderedDescending;
	}
	
	if (_sortOrder == NSOrderedAscending)
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(comparePathDescending:)];
		_sortOrder = NSOrderedDescending;
	}
	else
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(comparePathAscending:)];
		_sortOrder = NSOrderedAscending;
	}
	[self setElements:sortedElements];
}

- (void)sortBySize
{
	NSArray *sortedElements;

	// make sure we start by ordering in descending order when this column is clicked first
	if (_sortAttribute != SortBySize)
	{
		_sortAttribute = SortBySize;
		_sortOrder = NSOrderedDescending;
	}

	if (_sortOrder == NSOrderedAscending)
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareSizeDescending:)];
		_sortOrder = NSOrderedDescending;
	}
	else
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareSizeAscending:)];
		_sortOrder = NSOrderedAscending;
	}
		
	[self setElements:sortedElements];
}

- (void)sortByFilename
{
	NSArray *sortedElements;
	
	// make sure we start by ordering in descending order when this column is clicked first
	if (_sortAttribute != SortByFilename)
	{
		_sortAttribute = SortByFilename;
		_sortOrder = NSOrderedDescending;
	}

	if (_sortOrder == NSOrderedAscending)
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareFilenameDescending:)];
		_sortOrder = NSOrderedDescending;
	}
	else
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareFilenameAscending:)];
		_sortOrder = NSOrderedAscending;
	}
	[self setElements:sortedElements];
}

- (void)sortByDate
{
	NSArray *sortedElements;
	
	// make sure we start by ordering in descending order when this column is clicked first
	if (_sortAttribute != SortByDate)
	{
		_sortAttribute = SortByDate;
		_sortOrder = NSOrderedDescending;
	}

	if (_sortOrder == NSOrderedAscending)
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareDateDescending:)];
		_sortOrder = NSOrderedDescending;
	}
	else
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareDateAscending:)];
		_sortOrder = NSOrderedAscending;
	}
	[self setElements:sortedElements];
}

- (void)sortByRatio
{
	NSArray *sortedElements;
	
	// make sure we start by ordering in descending order when this column is clicked first
	if (_sortAttribute != SortByRatio)
	{
		_sortAttribute = SortByRatio;
		_sortOrder = NSOrderedDescending;
	}

	if (_sortOrder == NSOrderedAscending)
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareRatioDescending:)];
		_sortOrder = NSOrderedDescending;
	}
	else
	{
		sortedElements = [[self elements]
			sortedArrayUsingSelector:@selector(compareRatioAscending:)];
		_sortOrder = NSOrderedAscending;
	}
	[self setElements:sortedElements];
}

- (NSComparisonResult)sortOrder
{
	return _sortOrder;
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	[self methodIsAbstract:_cmd];
	// shut up the compiler
	return 0;
}

- (NSData *)dataByRunningUnachiverWithArguments:(NSArray *)args
{
   NSData *inData;
   NSFileHandle *readHandle;
   NSPipe *pipe;
   NSTask *task;
   NSMutableData *result;
    
   NSParameterAssert(args != nil);
   NSParameterAssert([[self class] executableDoesExist]);

   pipe = [NSPipe pipe];
   readHandle = [pipe fileHandleForReading];

   task = [[NSTask alloc] init];
   [task setLaunchPath:[[self class] unarchiveExecutable]];	
   [task setArguments:args];
   [task setStandardOutput:pipe];
   [task launch];

   result = [NSMutableData dataWithCapacity:1024];
   while ((inData = [readHandle availableData]) && [inData length])
     {
        [result appendData:inData];
     }
   [task release];
    
   return result;
}
// for archivers which have parameters to specify a destination directory
- (int)runUnarchiverWithArguments:(NSArray *)args
{
  return [[self class] runUnarchiverWithArguments:args inDirectory:nil];
}
// for archivers which do not have parameters to specify a destination directory
- (int)runUnarchiverWithArguments:(NSArray *)args inDirectory:(NSString *)workDir
{
  return [[self class] runUnarchiverWithArguments:args inDirectory:workDir];
}

+ (int)runUnarchiverWithArguments:(NSArray *)args inDirectory:(NSString *)workDir
{
  int result;
  NSTask *task;
  NSPipe *pipe;

  NSParameterAssert([self executableDoesExist]);
	
  pipe = [NSPipe pipe];
  task = [[NSTask alloc] init];
  [task setLaunchPath:[self unarchiveExecutable]];
  [task setArguments:args];
  [task setStandardOutput:pipe];
  [task setStandardError:pipe];
  if (workDir != nil)
    {
      [task setCurrentDirectoryPath:workDir];
    }
  [task launch];
  [task waitUntilExit];
	
  result = [task terminationStatus];
  [task release];
  return result;
}

+ (int)runArchiverWithArguments:(NSArray *)args inDirectory:(NSString *)workDir
{
	int result;
	NSTask *task;

	NSParameterAssert([self executableDoesExist]);
	
	task = [[NSTask alloc] init];
	[task setLaunchPath:[self archiveExecutable]];
	[task setArguments:args];
	if (workDir != nil)
	{
		[task setCurrentDirectoryPath:workDir];
	}
	[task launch];
	[task waitUntilExit];
	
	result = [task terminationStatus];
	[task release];
	return result;
}

- (NSArray *)listContents
{
	[self methodIsAbstract:_cmd];
	// shut up the compiler
	return nil;
}

+ (BOOL)executableDoesExist
{
	NSString *exePath;
	
	exePath = [self unarchiveExecutable];
	if (exePath == nil) 
	{
		return NO;
	}
	return [[NSFileManager defaultManager] isExecutableFileAtPath:exePath];
}

/*
 * Returns the full path to the executable that's used to extract the archive. This method
 * raises an exception indicating that subclasses have to override it.
 */
+ (NSString *)unarchiveExecutable
{
	[self methodIsAbstract:_cmd];
	// shut up the compiler
	return nil;
}
/*
 * Returns the full path to the executable that's used to create the archive. This method
 * raises an exception indicating that subclasses have to override it.
 */
+ (NSString *)archiveExecutable
{
	[self methodIsAbstract:_cmd];
	// shut up the compiler
	return nil;
}

/**
 * Returns the user presentable name for this kind of archive. This method raises an exception
 * indicating that subclasses have to override it.
 */
+ (ArchiveType)archiveType
{
	[self methodIsAbstract:_cmd];
	return UNKNOWN;
}

@end
