/* 
   Project: Sudoku
   DigitSource.h

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <AppKit/NSEvent.h>
#import <AppKit/NSView.h>

#define DIGIT_TYPE @"Digit"

#define DIGIT_FIELD_DIM 40
#define DIGIT_FONT_SIZE 24

@interface DigitSource : NSView
{
  int digit;
}

- initAtPoint:(NSPoint)loc  withDigit:(int)dval;

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag;

- makeDragImages;

- (void)mouseDown:(NSEvent *)theEvent;

@end
