/*
   Project: MPDCon

   Copyright (C) 2006

   Author: Daniel Luederwald

   Created: 2006-02-22 13:52:30 +0100 by mrsanders

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

#include "NormalFormatter.h"

@implementation NormalFormatter
- (NSString *) stringForObjectValue: (id) anObject
{
    return anObject;
}

- (NSAttributedString *)attributedStringForObjectValue: (id) anObject 
    withDefaultAttributes: (NSDictionary *) attr
{
  if (anObject != nil) {
    NSFont *theFont = [NSFont systemFontOfSize: [NSFont systemFontSize]];
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString: anObject];
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary: attr];
  
    [attrs setObject: theFont forKey: NSFontAttributeName];
    if ([aString length]) {
      [aString setAttributes: attrs range: NSMakeRange(0, [aString length])];
    }
    return [aString autorelease];  
  } else {
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString: @""];
    return [aString autorelease];  
  }
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error
{
  *obj = string;
}

@end
