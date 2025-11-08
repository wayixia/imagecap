//
//  CursorMac.m
//  Runner
//
//  Created by Q on 2025/11/7.
//

#import "CursorMac.h"

static NSCursor *busyButClickableNSCursor;
static NSCursor *makeAliasNSCursor;
static NSCursor *moveNSCursor;
static NSCursor *resizeEastNSCursor;
static NSCursor *resizeEastWestNSCursor;
static NSCursor *resizeNorthNSCursor;
static NSCursor *resizeNorthSouthNSCursor;
static NSCursor *resizeNortheastNSCursor;
static NSCursor *resizeNortheastSouthwestNSCursor;
static NSCursor *resizeNorthwestNSCursor;
static NSCursor *resizeNorthwestSoutheastNSCursor;
static NSCursor *resizeSouthNSCursor;
static NSCursor *resizeSoutheastNSCursor;
static NSCursor *resizeSouthwestNSCursor;
static NSCursor *resizeWestNSCursor;

static NSCursor *cellNSCursor;
static NSCursor *helpNSCursor;
static NSCursor *zoomInNSCursor;
static NSCursor *zoomOutNSCursor;



@implementation CursorMac

-(instancetype)init{
  self = [super init];
  if( self ) {
    // init cursors
    moveNSCursor = [self loadCursorFromSystemService:@"Move"];
    // topright
    resizeNortheastSouthwestNSCursor = [self loadCursorFromSystemService:@"ResizeNortheastSouthwest"];
    // topleft
    resizeNorthwestSoutheastNSCursor = [self loadCursorFromSystemService:@"ResizeNorthwestSoutheast"];
  }
  
  return self;
}

-(NSCursor*)loadCursorFromSystemService:(nonnull NSString*)cursorName {
  NSString *cursorPath = [@"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors" stringByAppendingPathComponent:[cursorName lowercaseString] ];
  NSImage *image = [[NSImage alloc] initByReferencingFile:[cursorPath stringByAppendingPathComponent:@"cursor.pdf"]];
  NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[cursorPath stringByAppendingPathComponent:@"info.plist"]];
  NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([[info valueForKey:@"hotx"] doubleValue], [[info valueForKey:@"hoty"] doubleValue])];
  
  return cursor;
}

+ (nonnull NSCursor *)get:(nonnull NSString *)nsname {
  NSCursor* slot;
  
//  if ([nsname isEqualToString:@"BusyButClickable"])
//      slot = busyButClickableNSCursor;
//  else if ([nsname isEqualToString:@"MakeAlias"])
//      slot = makeAliasNSCursor;
//  else
  if ([nsname isEqualToString:@"Move"])
      slot = moveNSCursor;
  else if ([nsname isEqualToString:@"ResizeEast"])
      slot = resizeEastNSCursor;
  else if ([nsname isEqualToString:@"ResizeEastWest"])
      slot = resizeEastWestNSCursor;
  else if ([nsname isEqualToString:@"ResizeNorth"])
      slot = resizeNorthNSCursor;
  else if ([nsname isEqualToString:@"ResizeNorthSouth"])
      slot = resizeNorthSouthNSCursor;
  else if ([nsname isEqualToString:@"ResizeNortheast"])
      slot = resizeNortheastNSCursor;
  else if ([nsname isEqualToString:@"ResizeNortheastSouthwest"])
      slot = resizeNortheastSouthwestNSCursor;
  else if ([nsname isEqualToString:@"ResizeNorthwest"])
      slot = resizeNorthwestNSCursor;
  else if ([nsname isEqualToString:@"ResizeNorthwestSoutheast"])
      slot = resizeNorthwestSoutheastNSCursor;
  else if ([nsname isEqualToString:@"ResizeSouth"])
      slot = resizeSouthNSCursor;
  else if ([nsname isEqualToString:@"ResizeSoutheast"])
      slot = resizeSoutheastNSCursor;
  else if ([nsname isEqualToString:@"ResizeSouthwest"])
      slot = resizeSouthwestNSCursor;
  else if ([nsname isEqualToString:@"ResizeWest"])
      slot = resizeWestNSCursor;
//  else if (name == "Cell")
//      slot = cellNSCursor;
//  else if (name == "Help")
//      slot = helpNSCursor;
//  else if (name == "ZoomIn")
//      slot = zoomInNSCursor;
//  else if (name == "ZoomOut")
//      slot = zoomOutNSCursor;
  else
      return [NSCursor arrowCursor];
  
  if (!slot)
    return [NSCursor arrowCursor];

  return slot;
}

@end




