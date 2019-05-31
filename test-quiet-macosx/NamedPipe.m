////
////  NamedPipe+NamedPipe.m
////  test-quiet-macosx
////
////  Created by Amit Shah on 2019-05-28.
////  Copyright © 2019 Amit Shah. All rights reserved.
////
//
//#import "NamedPipe.h"
//
//@implementation NamedPipe (NamedPipe)
//-(void)SomeFunc
//
//{
//    
//    const char * path = "/tmp/tom21";
//    
//    if(mkfifo(path, 0666) == -1 && errno !=EEXIST){
//        
//        NSLog(@"Unable to open the named pipe %c", path);
//        
//    }
//    
//    
//    
//    NSFileHandle * filehandleForReading;
//    
//    int fd = open(path, O_RDWR | O_NDELAY);
//    
//    filehandleForReading = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc: YES];
//    
//    
//    
//    NSNotificationCenter *nc;
//    
//    nc = [NSNotificationCenter defaultCenter];
//    
//    [nc removeObserver:self];
//    
//    [nc addObserver:self
//     
//           selector:@selector(dataReady:)
//     
//               name:NSFileHandleReadCompletionNotification
//     
//             object:filehandleForReading];
//    
//    [filehandleForReading readInBackgroundAndNotify];
//    
//}
//
//
//
////And then here is the func that gets called by the Notification server
//
//
//
//- (void)dataReady:(NSNotification *)n
//
//{
//    
//    NSData *d;
//    
//    d = [[n userInfo] valueForKey:NSFileHandleNotificationDataItem];
//    
//    
//    
//    
//    
//    NSLog(@"dataReady:%d bytes", [d length]);
//    
//    
//    
//    if ([d length]) {
//        
//        [self appendData:d];
//        
//    }
//    
//    
//    
//    //Tell the fileHandler to asychronusly report back
//    
//    [filehandleForReading readInBackgroundAndNotify];
//    
//}
//@end

