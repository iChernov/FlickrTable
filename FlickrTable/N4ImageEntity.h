//
//  N4ImageEntity.h
//  FlickrTable
//
//  Created by Ivan Chernov on 18/08/14.
//  Copyright (c) 2014 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface N4ImageEntity : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * comment;

@end
