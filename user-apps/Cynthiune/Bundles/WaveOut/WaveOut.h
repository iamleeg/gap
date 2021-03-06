/* WaveOut.h - this file is part of Cynthiune
 *
 * Copyright (C) 2005  Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <wolfgang@contre.com>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef WaveOut_H
#define WaveOut_H

#define MAX_BLOCKS 16

#import <Cynthiune/Output.h>

@interface WaveOut : NSObject <CynthiuneBundle, Output>
{
  id parentPlayer;
  HWAVEOUT dev;
  int nBlocks;
  BOOL stopRequested;
  WAVEHDR **blocks;

  unsigned char buffer[DEFAULT_BUFFER_SIZE];
  int bufferSize;
}

@end

typedef struct {
    @defs (WaveOut);
} CWaveOut;

#endif /* WaveOut_H */
