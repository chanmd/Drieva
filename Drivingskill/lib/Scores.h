//
//  Scores.h
//  Drivingskill
//
//  Created by Man Tung on 12/19/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Scores : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * score;

@end
