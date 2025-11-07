//
//  CursorMac.h
//  Runner
//
//  Created by Q on 2025/11/7.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CursorMac : NSObject

-(instancetype)init;
+(NSCursor*)get:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
