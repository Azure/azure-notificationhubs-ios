//
//  MSDebounceInstallationManager.m
//  WindowsAzureMessaging

#import "MSDebounceInstallationManager.h"
#import "MSInstallationManager.h"

@implementation MSDebounceInstallationManager

- (instancetype)initWithInterval:(double)interval {
    if(self = [super init]){
        self.interval = interval;
    }
    
    return self;
}

- (void)saveInstallation {
    if(_debounceTimer != nil){
        [_debounceTimer invalidate];
    }
    _debounceTimer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(execute) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_debounceTimer forMode:NSRunLoopCommonModes];
}

- (void)execute{
    [MSInstallationManager saveInstallation];
}

@end
