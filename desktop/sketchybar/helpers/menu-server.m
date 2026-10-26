#import <AppKit/AppKit.h>
#include <mach/mach_time.h>
#include <signal.h>
#include <unistd.h>

NSMenu *menu_create(NSArray<NSString *> *request);
static BOOL tracking;
static NSDictionary *latestTiming;

@interface MenuTiming : NSObject <NSMenuDelegate>
@property uint64_t started;
@end
@implementation MenuTiming
- (void)menuWillOpen:(NSMenu *)menu {
  mach_timebase_info_data_t clock;
  mach_timebase_info(&clock);
  double elapsed = (mach_absolute_time() - self.started) * (double)clock.numer / clock.denom / 1e6;
  latestTiming = @{ @"handler_to_menu_will_open_ms": @(elapsed), @"server_pid": @(getpid()) };
}
@end

static CFDataRef reply(NSString *text) {
  return (__bridge_retained CFDataRef)[text dataUsingEncoding:NSUTF8StringEncoding];
}

static CFDataRef receive(CFMessagePortRef port, SInt32 mode, CFDataRef bytes, void *context) {
  (void)port;
  (void)context;
  if (mode == 0) return reply([NSString stringWithFormat:@"%d", getpid()]);
  if (mode == 3) return (__bridge_retained CFDataRef)[NSJSONSerialization dataWithJSONObject:latestTiming ?: @{} options:0 error:NULL];
  if (mode != 1 && mode != 2) return reply(@"invalid");
  if (!bytes || CFDataGetLength(bytes) > 16384) return reply(@"invalid");
  id input = [NSPropertyListSerialization propertyListWithData:(__bridge NSData *)bytes options:NSPropertyListImmutable format:NULL error:nil];
  if (![input isKindOfClass:NSArray.class] || [input count] < 3 || [input count] > 32) return reply(@"invalid");
  for (id line in input) if (![line isKindOfClass:NSString.class] || [line length] > 512) return reply(@"invalid");
  NSArray *request = [input subarrayWithRange:NSMakeRange(1, [input count] - 1)];
  if (![@[@"cpu", @"memory", @"volume", @"network", @"battery", @"calendar"] containsObject:request[0]]) return reply(@"invalid");
  uint64_t started = strtoull([input[0] UTF8String], NULL, 10);
  if (!started || started > mach_absolute_time()) return reply(@"invalid");
  if (tracking) return reply(@"busy");
  // Benchmark the real menu construction without displaying a window or menu.
  if (mode == 2) { NSMenu *menu = menu_create(request); (void)menu.size; return reply(@"ok"); }
  tracking = YES;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSMenu *menu = menu_create(request);
    __attribute__((objc_precise_lifetime)) MenuTiming *timing = [MenuTiming new];
    timing.started = started;
    menu.delegate = timing;
    NSStatusItem *anchor = [NSStatusBar.systemStatusBar statusItemWithLength:1];
    NSPoint point = NSEvent.mouseLocation;
    NSScreen *screen = NSScreen.mainScreen;
    for (NSScreen *candidate in NSScreen.screens) {
      if (NSPointInRect(point, candidate.frame)) { screen = candidate; break; }
    }
    point.y = NSMaxY(screen.frame) - 36;
    point.x = MIN(MAX(point.x - menu.minimumWidth / 2, NSMinX(screen.frame) + 6),
                  NSMaxX(screen.frame) - menu.minimumWidth - 6);
    NSPoint local = [anchor.button convertPoint:[anchor.button.window convertPointFromScreen:point] fromView:nil];
    [menu popUpMenuPositioningItem:nil atLocation:local inView:anchor.button];
    [NSStatusBar.systemStatusBar removeStatusItem:anchor];
    menu.delegate = nil;
    tracking = NO;
  });
  return reply(@"ok");
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    alarm(0);
    if (argc != 4 || strcmp(argv[1], "--serve") != 0) return 64;
    pid_t owner = (pid_t)strtol(argv[2], NULL, 10);
    NSString *name = [NSString stringWithUTF8String:argv[3]];
    if (owner <= 1 || kill(owner, 0) != 0 || ![name hasPrefix:@"pub.anko.sketchybar-menu."] || name.length > 180) return 64;
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    // Font, CoreAudio and calendar initialization belong before the first click.
    for (NSArray *request in @[@[@"cpu", @"CPU", @"使用率"], @[@"volume", @"サウンド"], @[@"calendar", @"カレンダー"]]) {
      NSMenu *primer = menu_create(request);
      (void)primer.size;
    }
    CFMessagePortRef port = CFMessagePortCreateLocal(NULL, (__bridge CFStringRef)name, receive, NULL, NULL);
    if (!port) return 0;
    CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(NULL, port, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopCommonModes);
    dispatch_source_t lifetime = dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC, owner, DISPATCH_PROC_EXIT, dispatch_get_main_queue());
    if (!lifetime) { CFRelease(source); CFRelease(port); return 1; }
    dispatch_source_set_event_handler(lifetime, ^{ [NSApp terminate:nil]; });
    dispatch_resume(lifetime);
    if (kill(owner, 0) != 0) return 0;
    [NSApp run];
    dispatch_source_cancel(lifetime);
    CFMessagePortInvalidate(port);
    CFRelease(source);
    CFRelease(port);
  }
  return 0;
}
