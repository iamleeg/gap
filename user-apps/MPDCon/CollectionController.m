/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Collection Controller

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include <AppKit/AppKit.h>
#include "CollectionController.h"

/* ---------------------
   - Private Interface -
   ---------------------*/
@interface CollectionController(Private)

- (void) _refreshViews: (id)sender;
- (void) _filterCollectionByString: (NSString *)filterString;
- (void) _getAllAlbumsForArtistAt: (NSInteger)row;
- (void) _getAllTracksForArtistAt: (NSInteger)artistRow albumAt: (NSInteger)albumRow;


int _artistSort(id artist1, id artist2, void *context);
int _albumSort(id album1, id album2, void *context);
int _trackSort(id track1, id track2, void *context);
int _titleSort(id title1, id title2, void *context);
int _aSort(id string1, id string2, void *context);
@end

@implementation CollectionController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedCollectionController
{
  static CollectionController *_sharedCollectionController = nil;

  if (! _sharedCollectionController) 
    {
      _sharedCollectionController = [[CollectionController 
				       allocWithZone: [self zone]] init];
    }
  
  return _sharedCollectionController;
}

- (id) init
{
  self = [self initWithWindowNibName: @"Collection"];
  
  if (self)
    {
      [self setWindowFrameAutosaveName: @"Collection"];
    }

  return self;
}

- (void) dealloc
{
  [allSongs release];
  [allArtists release];
  [allAlbums release];
  [filteredTracks release];
  [super dealloc];
}

/* --------------------
   - Playlist Methods -
   --------------------*/

- (void) addSelected: (id)sender
{
  NSEnumerator *songEnum = [trackView selectedRowEnumerator];
  NSNumber *songNumber;
  
  while ((songNumber = [songEnum nextObject]) != nil) 
    {
      [[MPDController sharedMPDController] 
	addTrack: [[allSongs objectAtIndex: [songNumber intValue]] getPath]];
    }
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;

  [trackView setAutosaveName: @"CollectionTrackTable"];
  [trackView setAutosaveTableColumns: YES];
  
  [trackView setTarget: self];
  [trackView setDoubleAction: @selector(doubleClicked:)];

  defCenter = [NSNotificationCenter defaultCenter];

  [defCenter addObserver: self
		selector: @selector(didNotConnect:)
		name: DidNotConnectNotification
		object: nil];

  [defCenter addObserver: self
                selector: @selector(_refreshViews:)
                    name: ShownCollectionChangedNotification
                  object: nil];

 [self _refreshViews:nil];
}

- (void) updateCollection: (id)sender
{
  [[MPDController sharedMPDController] updateCollection];
}

- (void) doubleClicked: (id)sender
{
  if ([trackView clickedRow] >= 0) 
    {
	  [self addSelected: self];
	}
  else 
    {
      NSString *identifier;
  
      identifier = [(NSTableColumn *)[[trackView tableColumns] 
	    	  objectAtIndex: [trackView clickedColumn]] 
		     identifier];
	  
      if ([identifier isEqual: @"artist"]) 
        {
          NSArray *tmpArray = [[[allSongs autorelease] 
		    	     sortedArrayUsingFunction: _artistSort 
			         context: NULL] retain];
          allSongs = tmpArray;
        } 
      else if ([identifier isEqual: @"album"]) 
        {
          NSArray *tmpArray = [[[allSongs autorelease]
		    	     sortedArrayUsingFunction: _albumSort 
			         context: NULL] retain];
          allSongs = tmpArray;
        } 
      else if ([identifier isEqual: @"title"]) 
        {
          NSArray *tmpArray = [[[allSongs autorelease]
		    	     sortedArrayUsingFunction: _titleSort 
			         context: NULL] retain];
          allSongs = tmpArray;
        } 
      else if ([identifier isEqual: @"trackNr"]) 
        {
          NSArray *tmpArray = [[[allSongs autorelease]
		    	     sortedArrayUsingFunction: _trackSort 
			         context: NULL] retain];
          allSongs = tmpArray;
        } 
  
      [trackView reloadData];
    }
}

- (void) filterCollection: (id) sender
{
  [self _refreshViews:nil];
}

- (void) clearFilter: (id)sender
{
  if ([[filterField stringValue] compare: @""] == NSOrderedSame)
    {
      return;
    }
    
  [filterField setStringValue: @""];
  [self _refreshViews:nil];
}

/* --------------------------------
   - TableView dataSource Methods -
   --------------------------------*/

- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView
{
  return [allSongs count];

}

- (id) tableView: (NSTableView *)tableView 
objectValueForTableColumn: (NSTableColumn *)tableColumn 
	     row:(NSInteger) row
{
  NSString *identifier = [tableColumn identifier];
  
  return [[allSongs objectAtIndex: row] valueForKey: identifier];
}


/* ----------------------------
   - Browser delegate Methods -
   ----------------------------*/
   
- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
  if (column == 0)
    {
      return [allArtists count] + 1;
    }
    
  else
    {
      [self _getAllAlbumsForArtistAt: [sender selectedRowInColumn: 0]];
      return [allAlbums count]+1;
    }
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell
          atRow:(NSInteger)row
         column:(NSInteger)column
{
#warning FIXME the formatters are not working
  if (column == 0) {
      [cell setLeaf: NO];
      
      if (row == 0) {
          //[cell setFormatter: [[[BoldFormatter alloc] init] autorelease]];
          [cell setStringValue: [NSString stringWithFormat: @"All (%"PRIuPTR" Artists)", [allArtists count]]];
      } else {
          //[cell setFormatter: [[[NormalFormatter alloc] init] autorelease]];
          [cell setStringValue: [allArtists objectAtIndex: row-1]];
      }
  } else {
      [cell setLeaf: YES];
      
      if (row == 0) {
          //[cell setFormatter: [[[BoldFormatter alloc] init] autorelease]];
          [cell setStringValue: [NSString stringWithFormat: @"All (%"PRIuPTR" Albums)", [allAlbums count]]];
      } else {
          //[cell setFormatter: [[[NormalFormatter alloc] init] autorelease]];
          [cell setStringValue: [allAlbums objectAtIndex: row-1]];
      }
  }
}

- (NSString *)browser:(NSBrowser *)sender
        titleOfColumn:(NSInteger)column
{
  if (column == 0) {
      return @"Artists";
  } else if (column == 1) {
      return @"Albums";
  } else {
      return @"";
  }
}
  

- (void) selectionChanged: (id) sender
{
  [self _getAllTracksForArtistAt: [sender selectedRowInColumn: 0] albumAt: [sender selectedRowInColumn: 1]];
  
  [trackView reloadData];
  [trackView deselectAll: sender];
  
  if ([trackView numberOfRows] > 0)
    {
      [trackView scrollRowToVisible: 0];
    }
}
 

/* ------------------------------
   - TableView dragging Methods -
   ------------------------------*/
   
- (BOOL) tableView: (NSTableView *)tv
	 writeRows: (NSArray *)rows
      toPasteboard: (NSPasteboard*)pboard
{
  NSArray *typeArray;
  NSMutableArray *songArray;
  
  BOOL accept;
  NSUInteger count;
  
  count = [rows count];
  
  if (count > 0)
    {
      NSUInteger i;
      songArray = [[NSMutableArray alloc] init];
      
      for (i = 0; i < count; i++)
        {
          [songArray addObject: [[allSongs objectAtIndex: [[rows objectAtIndex: i] integerValue]] getPath]];
        }
      
      accept = YES;
      typeArray = [NSArray arrayWithObjects: CollectionDragType, nil];
      [pboard declareTypes: typeArray owner: self];
      [pboard setPropertyList: [songArray autorelease] forType: CollectionDragType];
    }
  else
    {
      accept = NO;
    }
  
  return accept;
}
/* ------------------------
   - Notification Methods -
   ------------------------*/

- (void) didNotConnect: (NSNotification *)aNotif
{
  [[self window] performClose: self];
}

- (NSArray *) getAllTracks
{
  return filteredTracks;
}

@end

/* -------------------
   - Private Methods -
   -------------------*/
@implementation CollectionController(Private)

- (void) _refreshViews:(id) sender
{
  [self _filterCollectionByString: [filterField stringValue]];
  
  [collectionView reloadColumn: 0];

  [collectionView selectRow: 0 inColumn: 0];
  
  [self selectionChanged: collectionView];
}

- (void) _getAllAlbumsForArtistAt: (NSInteger)row
{
  [allAlbums release];
  
  NSMutableSet *tmpAlbums = [[NSMutableSet alloc] init];
     
  NSUInteger i;
     
  for (i = 0; i < [filteredTracks count]; i++)
    {
      if (row <= 0)
        {
          [tmpAlbums addObject: [[filteredTracks objectAtIndex: i] getAlbum]];
        }
      else
        {
          if ([[[filteredTracks objectAtIndex: i] getArtist] compare: [allArtists objectAtIndex: (row-1)]] == NSOrderedSame)
            {
              [tmpAlbums addObject: [[filteredTracks objectAtIndex: i] getAlbum]];
            }
        }
    }
      
  allAlbums = [[[[tmpAlbums autorelease] allObjects] sortedArrayUsingFunction: _aSort context: NULL] retain];
}


- (void) _getAllTracksForArtistAt: (NSInteger)artistRow albumAt: (NSInteger)albumRow
{
  [allSongs release];
  
  if (artistRow < 1)
    {
      if (albumRow < 1)
        {
          allSongs = [[NSArray arrayWithArray: filteredTracks] retain];
        }
      else
        {
          NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
              
          NSUInteger i;
              
          for (i = 0; i < [filteredTracks count]; i++)
            {
              if ([[[filteredTracks objectAtIndex: i] getAlbum] compare: [allAlbums objectAtIndex: (albumRow -1)]] == NSOrderedSame)
                {
                  [tmpArray addObject: [filteredTracks objectAtIndex: i]];
                }
            }
                
          allSongs = [[NSArray arrayWithArray: [tmpArray autorelease]] retain];
        }
    }
  else
    {
      if (albumRow < 1)
        {
         NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            
         NSUInteger i;
              
         for (i = 0; i < [filteredTracks count]; i++)
           {
             if ([[[filteredTracks objectAtIndex: i] getArtist] compare: [allArtists objectAtIndex: (artistRow -1)]] == NSOrderedSame)
               {
                 [tmpArray addObject: [filteredTracks objectAtIndex: i]];
               }
           }
                
         allSongs = [[NSArray arrayWithArray: [tmpArray autorelease]] retain];
        }
      else
        {
          NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
              
          NSUInteger i;
              
          for (i = 0; i < [filteredTracks count]; i++)
            {
              if (([[[filteredTracks objectAtIndex: i] getArtist] compare: [allArtists objectAtIndex: (artistRow -1)]] == NSOrderedSame) &&
                ([[[filteredTracks objectAtIndex: i] getAlbum] compare: [allAlbums objectAtIndex: (albumRow -1)]] == NSOrderedSame))
                {
                  [tmpArray addObject: [filteredTracks objectAtIndex: i]];
                }
            }
                
          allSongs = [[NSArray arrayWithArray: [tmpArray autorelease]] retain];
        }
    }
    
}
    
- (void) _filterCollectionByString: (NSString *) fString
{  
  [allArtists release];
  [filteredTracks release];

  if ([fString compare: @""] == NSOrderedSame)
    {
      allArtists = [[[MPDController sharedMPDController] getAllArtists] retain];
      filteredTracks = [[[MPDController sharedMPDController] getAllTracksWithMetadata: YES] retain];
    }
  else
    {
      NSArray *allTracks = [[[MPDController sharedMPDController] getAllTracksWithMetadata: YES] retain];
      NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
      NSMutableSet *tmpArtists = [[NSMutableSet alloc] init];
      
      NSUInteger i;
      
      for (i = 0; i < [allTracks count]; i++)
        {
          if ([[[allTracks objectAtIndex: i] getArtist] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  
            {
              [tmpArray addObject: [allTracks objectAtIndex: i]];
            }
          else if ([[[allTracks objectAtIndex: i] getTitle] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  
            {
              [tmpArray addObject: [allTracks objectAtIndex: i]];
            }
          else if ([[[allTracks objectAtIndex: i] getAlbum] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  
            {
              [tmpArray addObject: [allTracks objectAtIndex: i]];
            }
        }
        
      [allTracks release]; 
      filteredTracks = [[NSArray arrayWithArray: [tmpArray autorelease]] retain];
 
      for (i = 0; i < [filteredTracks count]; i++)
        {
          [tmpArtists addObject: [[filteredTracks objectAtIndex: i] getArtist]];
        }
        
      allArtists = [[[[tmpArtists autorelease] allObjects] sortedArrayUsingFunction: _aSort context: NULL] retain];
    }
}


int _artistSort(id artist1, id artist2, void *context)
{
  PlaylistItem *pl1, *pl2;

  pl1 = (PlaylistItem *)artist1;
  pl2 = (PlaylistItem *)artist2;

  return [[pl1 getArtist] caseInsensitiveCompare: [pl2 getArtist]];
}

int _albumSort(id album1, id album2, void *context)
{
  PlaylistItem *pl1, *pl2;

  pl1 = (PlaylistItem *)album1;
  pl2 = (PlaylistItem *)album2;

  return [[pl1 getAlbum] caseInsensitiveCompare: [pl2 getAlbum]];
}

int _titleSort(id track1, id track2, void *context)
{
  PlaylistItem *pl1, *pl2;

  pl1 = (PlaylistItem *)track1;
  pl2 = (PlaylistItem *)track2;

  return [[pl1 getTitle] caseInsensitiveCompare: [pl2 getTitle]];
}

int _trackSort(id track1, id track2, void *context)
{
  PlaylistItem *pl1, *pl2;

  pl1 = (PlaylistItem *)track1;
  pl2 = (PlaylistItem *)track2;

  return [[pl1 getTrackNr] caseInsensitiveCompare: [pl2 getTrackNr]];
}

int _aSort(id string1, id string2, void *context)
{
  return [string1 caseInsensitiveCompare: string2];
}

@end

