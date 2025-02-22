//
//  AppDelegate.m
//  BetterMouseTool
//
//  Created by SEOJOON LEE on 2/21/25.
//

#import "AppDelegate.h"


NSImage *get16x16AppIcon(void) {
    NSImage *appIcon = [NSApp applicationIconImage];
    
    if (!appIcon) {
        NSLog(@"No application icon found");
        return nil;
    }

    NSSize size = NSMakeSize(16, 16);
    NSRect targetRect = NSMakeRect(0, 0, size.width, size.height);
    
    NSImageRep *rep = [appIcon bestRepresentationForRect:targetRect context:nil hints:nil];
    
    if (!rep) {
        NSLog(@"Failed to retrieve 16x16 icon");
        return nil;
    }

    NSImage *smallIcon = [[NSImage alloc] initWithSize:size];
    [smallIcon addRepresentation:rep];

    return smallIcon;
}

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property NSStatusItem *barItem ;
@end

@implementation AppDelegate

- (void) quit_application {
    NSLog(@"Process is exiting");
    exit(0);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    [self.window center];
    
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit_application) keyEquivalent:@"Q"];
    
    [menu addItem:quit];
    
    self.barItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    self.barItem.button.image = get16x16AppIcon();
    [self.barItem setMenu:menu];
    
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp activateIgnoringOtherApps:YES];
    
    
    NSScreen *screen = [NSScreen mainScreen];  // 메인 화면의 크기 가져오기
    NSRect screenFrame = [screen frame];  // 전체 화면 크기

    CGFloat windowWidth = self.window.frame.size.width;
    CGFloat windowHeight = self.window.frame.size.height;
    CGFloat xPos = 150;
    CGFloat yPos = 150;

    // 📌 macOS 좌표계는 (0,0)이 왼쪽 아래이므로, 위치 조정 필요
    yPos = screenFrame.size.height - windowHeight - yPos;

    // 📌 contentRect 생성
    NSRect contentRect = NSMakeRect(xPos, yPos, windowWidth, windowHeight);

    // 📌 윈도우 프레임 변경 (XIB에서 로드된 윈도우 사용)
    [self.window setFrame:contentRect display:NO];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

// 🚀 Dock 아이콘을 클릭하면 윈도우를 표시
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
//        NSLog(@"Dock icon clicked - Showing window");
//        [self.window makeKeyAndOrderFront:nil];
    }
    return YES;
}

@end
