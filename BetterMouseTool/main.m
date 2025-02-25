//
//  main.m
//  BetterMouseTool
//
//  Created by SEOJOON LEE on 2/21/25.
//

#import <Cocoa/Cocoa.h>

#define MIN_MOVEMENT 80

void openAccessibilitySettings(void) {
    NSLog(@"🔓 Opening Accessibility settings...");
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]];
}

@interface context_t: NSObject
{
@public
    bool gesture;
    CGEventType event;
    int button;
    CGPoint position;
}
@end

@implementation context_t

- (id)init {
    return [super init];
}

- (void)reset:(bool)press:(CGEventType)_event:(int)_button:(CGPoint)_position {
    self->gesture = press;
    self->event = _event;
    self->button = _button;
    self->position = _position;
}
@end

context_t* context = NULL;



void moveSpace(bool right) {
    NSLog(@"🚀 Launching Move Space ...");

    // Down Arrow 키 눌림 이벤트 생성
    CGEventRef arrowDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)(right ? 123 : 124), true);
    CGEventSetFlags(arrowDown, kCGEventFlagMaskControl | CGEventGetFlags(arrowDown));

    // Down Arrow 키 해제 이벤트
    CGEventRef arrowUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)(right ? 123 : 124), false);
    CGEventSetFlags(arrowUp, kCGEventFlagMaskControl | CGEventGetFlags(arrowUp));
    
    // 이벤트 전송 (Control + UpArrow)
    CGEventPost(kCGHIDEventTap, arrowDown);
    CGEventPost(kCGHIDEventTap, arrowUp);

    // 메모리 해제
    CFRelease(arrowDown);
    CFRelease(arrowUp);
}

void launchAppExpose(void) {
    NSLog(@"🚀 Launching App Exposé...");

    // Down Arrow 키 눌림 이벤트 생성
    CGEventRef downArrowDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)125, true);
    CGEventSetFlags(downArrowDown, kCGEventFlagMaskControl | CGEventGetFlags(downArrowDown));

    // Down Arrow 키 해제 이벤트
    CGEventRef downArrowUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)125, false);
    CGEventSetFlags(downArrowUp, kCGEventFlagMaskControl | CGEventGetFlags(downArrowUp));
    
    // 이벤트 전송 (Control + UpArrow)
    CGEventPost(kCGHIDEventTap, downArrowDown);
    CGEventPost(kCGHIDEventTap, downArrowUp);

    // 메모리 해제
    CFRelease(downArrowDown);
    CFRelease(downArrowUp);
}

void launchMissionControl(void) {
    NSLog(@"🚀 Launching Mission Control...");

    // Up Arrow 키 눌림 이벤트 생성
    CGEventRef upArrowDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)126, true);
    CGEventSetFlags(upArrowDown, kCGEventFlagMaskControl | CGEventGetFlags(upArrowDown));

    // Up Arrow 키 해제 이벤트
    CGEventRef upArrowUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)126, false);
    CGEventSetFlags(upArrowUp, kCGEventFlagMaskControl | CGEventGetFlags(upArrowUp));
    
    // 이벤트 전송 (Control + UpArrow)
    CGEventPost(kCGHIDEventTap, upArrowDown);
    CGEventPost(kCGHIDEventTap, upArrowUp);

    // 메모리 해제
    CFRelease(upArrowDown);
    CFRelease(upArrowUp);
}

CGPoint getCurrentMousePosition(void) {
    CGEventRef event = CGEventCreate(NULL);
    CGPoint cursor = CGEventGetLocation(event);
    CFRelease(event);
    return cursor;
}


// 이벤트 콜백 함수
CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    // thread safe code
    if (!context) return event;

    if (type == kCGEventLeftMouseDown
        || type == kCGEventLeftMouseUp
        || type == kCGEventRightMouseDown
        || type == kCGEventRightMouseUp
        || type == kCGEventOtherMouseDown
        || type == kCGEventOtherMouseUp) {
        int64_t button = CGEventGetIntegerValueField(event, kCGMouseEventButtonNumber);
        int64_t event_id = CGEventGetIntegerValueField(event, kCGMouseEventNumber);
//            NSLog(@"button : %llu (%lu)", button, (unsigned long)type);
        if (button == (0x1 | (1 << 4))) {
            NSLog(@"Get original input 1");
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, 2);
            return event;
        }
        else if (button == (0x2 | (1 << 4))) {
            NSLog(@"Get original input 2");
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, 2);
            return event;
        }
        else if (button == 2) { // Middle Mouse Button (Button 2)
            if (type == kCGEventOtherMouseDown) {
                NSLog(@"Middle Mouse Button Pressed!");
                
                @synchronized(context)
                {
                    if (!context->gesture) {
                        [context reset:true:type:(int)button:getCurrentMousePosition()];
                        CGEventSetType(event, kCGEventNull);
                        CGAssociateMouseAndMouseCursorPosition(FALSE);
                    }
                }
                
                return event;
            } else {
                NSLog(@"Middle Mouse Button Released!");
                
                if (context->gesture) {
                    
                    CGPoint position = getCurrentMousePosition();
                    
                    int horizontal = position.x - context->position.x,
                    vertical = position.y - context->position.y;
                    
                    int absHorizontal = sqrt(pow(horizontal, 2.0)),
                        absVertical = sqrt(pow(vertical, 2.0));
                    
                    if (absHorizontal > absVertical && absHorizontal > MIN_MOVEMENT) {
                        moveSpace(horizontal > 0);
                    } else if (absHorizontal < absVertical && absVertical > MIN_MOVEMENT) {
                        if (vertical > 0) { // is down
                            launchAppExpose();
                        } else {
                            launchMissionControl();
                        }
                    }
                    else {
                        NSLog(@"Append original input");
                        
                        CGEventRef origin = CGEventCreate(NULL);
                        CGEventSetType(origin, context->event);
                        CGEventSetIntegerValueField(origin, kCGMouseEventClickState, 1);
                        CGEventSetIntegerValueField(origin, kCGMouseEventButtonNumber, (0x1 | (1 << 4)));
                        CGEventPost(kCGHIDEventTap, origin);
                        CGEventSetType(origin, context->event + 1);
                        CGEventSetIntegerValueField(origin, kCGMouseEventClickState, 1);
                        CGEventSetIntegerValueField(origin, kCGMouseEventButtonNumber, (0x2 | (1 << 4)));
                        CGEventPost(kCGHIDEventTap, origin);
                        CFRelease(origin);
                        
                    }
                    
                    NSLog(@"Gesture : %d, %d", horizontal, vertical);
                    
                    @synchronized(context)
                    {
                        CGAssociateMouseAndMouseCursorPosition(TRUE);
                        [context reset:false:type:(int)button:CGPointMake(0, 0)];
                        CGEventSetType(event, kCGEventNull);
                    }
                    
                    return event;
                }
            }
        }
    }
    
    return event; // 이벤트를 시스템에 전달
}

CFMachPortRef getEventTap(void) {
    // 마우스 이벤트 감지 설정
    CGEventMask eventMask = CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventLeftMouseUp) | CGEventMaskBit(kCGEventRightMouseDown) | CGEventMaskBit(kCGEventRightMouseUp) | CGEventMaskBit(kCGEventOtherMouseDown) | CGEventMaskBit(kCGEventOtherMouseUp);
    
    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, eventCallback, NULL);
    
    return eventTap;
}

extern CGError CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
extern int _CGSDefaultConnection(void);

@interface EventThread : NSThread
@end

@implementation EventThread
- (void)main {
    @autoreleasepool {

        CFStringRef propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingMacRoman);
        CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
        CFRelease(propertyString);
        
        context = [[context_t alloc] init];
        
        CFMachPortRef eventTap = getEventTap();
        
//        if (!eventTap) openAccessibilitySettings();
        
        while (!eventTap) {
            NSLog(@"Failed to create event tap.");
            eventTap = getEventTap();
            
            sleep(1);
        }
    
        // 이벤트 루프 설정
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(eventTap, true);

        NSLog(@"✅ Listening for middle mouse button events...");
        CFRunLoopRun(); // 실행 루프 시작
        
        NSLog(@"❌ CFRunLoop has stopped!");
    }
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        EventThread *thread = [[EventThread alloc] init];
        [thread start]; // 새로운 스레드 실행
    }
    return NSApplicationMain(argc, argv);
}
