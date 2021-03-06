/*

  TableViewDataSource.h
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

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

#import <Foundation/NSObject.h>

@class Archive;

#define COL_ID_NAME		@"name"
#define COL_ID_DATE		@"date"
#define COL_ID_SIZE		@"size"
#define COL_ID_PATH		@"path"
#define COL_ID_RATIO	@"ratio"

@interface TableViewDataSource : NSObject
{
  @private 
    Archive *_archive;
}

- (void)setArchive:(Archive *)archive;

@end
