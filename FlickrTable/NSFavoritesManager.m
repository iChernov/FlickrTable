//
//  NSFavoritesManager.m
//  FlickrTable
//
//  Created by Ivan Chernov on 18/08/14.
//  Copyright (c) 2014 NumberFour AG. All rights reserved.
//

#import "NSFavoritesManager.h"
#import <TMCache/TMCache.h>
#import "N4ImageEntity.h"

@interface NSFavoritesManager ()
@property (strong, nonatomic) TMCache *p_privateCache;
@end

@implementation NSFavoritesManager

+ (instancetype) sharedManager {
    static dispatch_once_t pred;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)addNewFavorite:(UIImage *)image withTitle:(NSString *)title andComment:(NSString *)comment{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        N4ImageEntity *imageEntity = [N4ImageEntity MR_createInContext:localContext];
        imageEntity.imageData = UIImagePNGRepresentation(image);
        imageEntity.comment = comment;
        imageEntity.title = title;
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"saved successfully");
    }];
}

- (NSArray *)getImages {
    return [N4ImageEntity MR_findAll];
}

@end
