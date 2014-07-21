//
//  RSViewController.m
//  RSReactiveCocoaDemo
//
//  Created by Mark Williams on 21/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

#import "RSViewController.h"
#import "ReactiveCocoa.h"

@interface RSViewController ()

@end

@implementation RSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];
	timeLabel.text = [self timeStringForDate:[NSDate date]];
	[self.view addSubview:timeLabel];

	
	RACScheduler *scheduler = [RACScheduler scheduler];
	RACSignal *timerSignal = [[[RACSignal interval:1 onScheduler:scheduler] take:1] concat:[RACSignal interval:1 onScheduler:scheduler]];
				
	[timerSignal subscribeNext: ^(NSDate *currentDateTime){
		dispatch_async(dispatch_get_main_queue(), ^{
			timeLabel.text = [self timeStringForDate:currentDateTime];
		});
	}];
	
	[self syncOperations];
}


- (void)syncOperations
{
	RACSignal *signal1 = [self asyncOperation1];
	RACSignal *signal2 = [self asyncOperation2];
//	RACSignal *combined = [signal1 combineLatestWith:signal2];
	RACSignal *combined = [signal1 merge:signal2];
	[[combined deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(id someObject) {
		NSLog(@"Next: %@", someObject);
	} error:^(NSError *error) {
		NSLog(@"Error");
	} completed:^{
		NSLog(@"Completed");
	}];
}

- (RACSignal *)asyncOperation1
{
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[NSThread sleepForTimeInterval:2];
			NSLog(@"Slept 2");
			[subscriber sendNext:@"asyncOperation1 next"];
			[subscriber sendCompleted];
			// [subscriber sendError:error];
		});
		return [RACDisposable disposableWithBlock:^{
			// Cancel code would go here
		}];
	}];
	return signal;
}

- (RACSignal *)asyncOperation2
{
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[NSThread sleepForTimeInterval:4];
			NSLog(@"Slept 4");
			[subscriber sendNext:@"asyncOperation2 next"];
			[subscriber sendCompleted];
			// [subscriber sendError:error];
		});
		return [RACDisposable disposableWithBlock:^{
			// Cancel code would go here
		}];
	}];
	return signal;

}

- (NSString *)timeStringForDate:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"hh:mm:ss";
	NSString *dateString = [dateFormatter stringFromDate:date];
	return dateString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
