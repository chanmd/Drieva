//
//  Temp.h
//  Drivingskill
//
//  Created by Man Tung on 12/10/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Temp : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * creatTime;
@property (nonatomic, retain) NSNumber * isUpload;

@end
