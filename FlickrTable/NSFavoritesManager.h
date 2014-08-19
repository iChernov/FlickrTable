//
//  NSFavoritesManager.h
//  FlickrTable
//
//  Created by Ivan Chernov on 18/08/14.
//  Copyright (c) 2014 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFavoritesManager : NSObject
+ (instancetype) sharedManager;
- (void)addNewFavorite:(UIImage *)image withTitle:(NSString *)title andComment:(NSString *)comment;
- (NSArray *)getImages;
@end
