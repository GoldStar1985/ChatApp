/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2013-2014 Hyphenate Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Technologies.
 */

#import <Foundation/Foundation.h>

@interface EMAudioPlayerUtil : NSObject

+ (BOOL)isPlaying;

+ (NSString *)playingFilePath;

+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;

+ (void)stopCurrentPlaying;

@end
