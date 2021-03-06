/*
   Project: OresmeKit

   Copyright (C) 2011-2014 Free Software Foundation

   Author: multix

   Created: 2011-09-08 15:09:20 +0200 by multix

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "OKLineChart.h"
#import "OKSeries.h"

#define around(x) floor(x+0.5)

@implementation OKLineChart

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      minXUnitSize = 10;
      minYUnitSize = 10;
      lineWidth = 0.75;
    }
  return self;
}



-(void)drawRect: (NSRect)rect
{
  NSBezierPath *path;
  unsigned i, j;
  double oneXUnit;
  double oneYUnit;
  double xUnitSize;
  double yUnitSize;
  float availableHeight;
  float availableWidth;
  double rangeToRepresent;
  float axisLevel;
  float minXPos;
  float minYPos;
  float maxXPos;
  float maxYPos;
  unsigned xSteps;
  unsigned ySteps;

  [super drawRect: rect];
  /* the super method will have calculated the limits */
  rangeToRepresent = graphMaxYVal - graphMinYVal;
  if (rangeToRepresent == 0)
    {
      NSLog(@"No Y range to represent");
      return;
    }


  /* bottom and left limits of the graph
     absolute margin plus defined space */
  minXPos = 10 + marginLeft;
  minYPos = 10 + marginBottom;
  maxXPos = [self bounds].size.width - marginRight;
  maxYPos = [self bounds].size.height - marginTop;

  availableHeight = maxYPos - minYPos;
  availableWidth = maxXPos - minXPos;


  /* data range */
  oneYUnit = availableHeight / rangeToRepresent;
  oneXUnit = availableWidth / graphMaxXVal;
  axisLevel = minYPos;
  if (graphMinYVal < 0)
    axisLevel += around(-oneYUnit * graphMinYVal);
  NSLog(@"x-y unit: %f, %f:, axisLevel: %f", oneXUnit, oneYUnit, axisLevel);
  xUnitSize = oneXUnit;
  if (xUnitSize < minXUnitSize)
    {
    while (xUnitSize < minXUnitSize)
      xUnitSize += oneXUnit;
    }
  else if (xUnitSize >= availableWidth)
    {
      xUnitSize = minXUnitSize;
    }

  xSteps = ceil(availableWidth / xUnitSize);


  /* calculate grid values */
  [xAxisGridValues removeAllObjects];
  for (i = 0; i < xSteps; i++)
    {
      float x;
      
      x = around(minXPos + i * xUnitSize)+0.5;
      [xAxisGridValues addObject:[NSNumber numberWithFloat:x]];
    }

  [yAxisGridValues removeAllObjects];
  ySteps = 0;
  yUnitSize = oneYUnit;
  if (yAxisGridSizing == OKGridConstantSize)
    {
      if (yUnitSize < minYUnitSize)
        {
          while (yUnitSize < minYUnitSize)
            yUnitSize += oneYUnit;
        }
      else if (yUnitSize >= availableHeight)
        {
          yUnitSize = minYUnitSize;
        }
      ySteps = ceil(availableHeight / yUnitSize);
      for (i = 0; i < ySteps; i++)
        {
          float y;
          
          y = around(minYPos + i * yUnitSize)+0.5;
          [yAxisGridValues addObject:[NSNumber numberWithFloat:y]];
        }
    }
  else if (yAxisGridSizing == OKGridKiloMega)
    {
      int yAxisScaleExp;
      double scaledRange;

      yAxisScaleExp = 0;
      scaledRange = rangeToRepresent;
      if (rangeToRepresent > 1)
        {
          while (scaledRange > 1000)
            {
              scaledRange /= 1000;
              yAxisScaleExp += 3;
            }
        }
      else if (rangeToRepresent > 0)
        {
          while (scaledRange < 0.001)
            {
              scaledRange *= 1000;
              yAxisScaleExp += -3;
            }
        }
      else
        {
          NSLog(@"Consistency error: negative Y range: %lf", rangeToRepresent);
        }
      NSLog(@"1 - scaled range: %f, scaleExp: %d", scaledRange, yAxisScaleExp);
      /* we get the steps from the scaled range */
      scaledRange = ceil(scaledRange)+1;
      rangeToRepresent = scaledRange * pow(10, yAxisScaleExp);
      NSLog(@"new range: %f", rangeToRepresent);
      ySteps = (unsigned)scaledRange;
      NSLog(@"original steps: %u", ySteps);

      /* now we check is the single unit is too small */
      while ((availableHeight/ySteps) < minYUnitSize)
        {
          if (ySteps % 2)
            ySteps++;
          ySteps = (unsigned)ceil((double)ySteps / 2.0);
        }

      /* now we add one unit on top, to be sure to fit in smoothly
       and recalculate the range */
      yUnitSize = availableHeight / ySteps;
      oneYUnit = availableHeight / rangeToRepresent;

      for (i = 0; i < ySteps; i++)
        {
          float y;
          
          y = around(minYPos + i * yUnitSize)+0.5;
          [yAxisGridValues addObject:[NSNumber numberWithFloat:y]];
        }
    }
  NSLog(@"unit sizes: %f, %f", xUnitSize, yUnitSize);
  NSLog(@"x-y steps: %u-%u", xSteps, ySteps);

  /* draw grid */
  if (gridStyle != OKGridNone)
    {
      [gridColor set];
      if (gridStyle == OKGridHorizontal || gridStyle == OKGridBoth)
        {
          for (i = 0; i < ySteps; i++)
            {
              [NSBezierPath strokeRect: NSMakeRect(minXPos, [[yAxisGridValues objectAtIndex:i] floatValue], availableWidth, 0)];
            }
          }
      if (gridStyle == OKGridVertical || gridStyle == OKGridBoth)
        {
	  for (i = 0; i < xSteps; i++)
	    {
	      [NSBezierPath strokeRect: NSMakeRect([[xAxisGridValues objectAtIndex:i] floatValue], minYPos, 0, availableHeight)];
	    }
        }
    }
  
  /* draw axes */
  [axisColor set];
  [NSBezierPath strokeRect: NSMakeRect(minXPos, axisLevel+0.5, maxXPos-minXPos, 0)];
  [NSBezierPath strokeRect: NSMakeRect(minXPos+0.5, minYPos, 0, maxYPos-minYPos)];

  /* draw units */
  for (i = 0; i < xSteps; i++)
    {
      [NSBezierPath strokeRect: NSMakeRect([[xAxisGridValues objectAtIndex:i] floatValue], axisLevel-1, 0, 2)];
    }
  for (i = 0; i < ySteps; i++)
    {
      [NSBezierPath strokeRect: NSMakeRect(minXPos, [[yAxisGridValues objectAtIndex:i] floatValue], 2, 0)];
    }
  NSLog(@"top is: %f", i * (yUnitSize / oneYUnit));
  
  /* draw graph */
  for (i = 0; i < [seriesArray count]; i++)
    {
      OKSeries *series;
      float x;
      float y;
      NSPoint p;

      series = [seriesArray objectAtIndex: i];
      if ([series count] > 0)
	{
	  path = [[NSBezierPath alloc] init];
	  [[series color] set];
          if ([series highlighted])
            [path setLineWidth: lineWidth*2.5];
          else
            [path setLineWidth: lineWidth];
	  x = minXPos;
	  y = axisLevel + [[series objectAtIndex: 0] floatValue] * oneYUnit;
	  p = NSMakePoint(x, y);
	  [path moveToPoint: p];
	  x += oneXUnit;
	  for (j = 1; j < [series count]; j++)
	    {
	      y = axisLevel + [[series objectAtIndex: j] floatValue] * oneYUnit;
	      p = NSMakePoint(x, y);
	      [path lineToPoint: p];
	      x += oneXUnit;
	    }
	  [path stroke];
	  [path release];
	}
    }

  /* draw axis labels */
  if (yAxisLabelStyle  == OKMinMaxLabels || yAxisLabelStyle == OKAllLabels )
    {
      NSMutableParagraphStyle *style;
      NSDictionary *strAttr;
      NSFont *tempFont;
      NSPoint labelP;
      NSString *label;
      NSSize labelSize;

      style = [[NSMutableParagraphStyle alloc] init];
      [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
      tempFont = [NSFont systemFontOfSize:6];

      strAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
                                 tempFont, NSFontAttributeName,
                               [NSColor blackColor], NSForegroundColorAttributeName,
                               style, NSParagraphStyleAttributeName, nil] retain];
      [style release];


      i = 0;
      while (i < ySteps)
        {
          float y;
        
          y = around(minYPos + i * yUnitSize)+0.5;
          [NSBezierPath strokeRect: NSMakeRect(minXPos, y, 2, 0)];

          label = [OKChart format:[NSNumber numberWithFloat: i * (yUnitSize / oneYUnit) + graphMinYVal] withFormat:yLabelNumberFmt];
          labelSize = [label sizeWithAttributes:strAttr];
          labelP = NSMakePoint(2, (minYPos + i * yUnitSize) - labelSize.height / 2);
          [label drawAtPoint:labelP  withAttributes:strAttr];

          if (i == 0 && yAxisLabelStyle == OKMinMaxLabels)
            i = ySteps -1;
          else
            i++;
      }
      
      [strAttr release];
 
    }
}


@end
