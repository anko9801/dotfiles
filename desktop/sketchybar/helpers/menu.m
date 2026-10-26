#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioHardwareService.h>
#include <sys/file.h>
#include <fcntl.h>
#include <unistd.h>
#include <math.h>

@interface MenuActions : NSObject
@property NSString *kind;
@property AudioDeviceID device;
@property AudioObjectPropertySelector volumeProperty;
@property NSTextField *volumeLabel;
@end

@implementation MenuActions
- (void)volume:(NSSlider *)slider {
  AudioDeviceID current = kAudioObjectUnknown;
  UInt32 size = sizeof(current);
  AudioObjectPropertyAddress output = { kAudioHardwarePropertyDefaultOutputDevice,
    kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
  if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &output, 0, NULL, &size, &current) != noErr || current != self.device) {
    slider.enabled = NO;
    self.volumeLabel.stringValue = @"出力先が変更されました";
    return;
  }
  Float32 value = slider.floatValue / 100;
  AudioObjectPropertyAddress property = { self.volumeProperty,
    kAudioObjectPropertyScopeOutput, kAudioObjectPropertyElementMain };
  OSStatus status = AudioObjectSetPropertyData(self.device, &property, 0, NULL, sizeof(value), &value);
  self.volumeLabel.stringValue = status == noErr
    ? [NSString stringWithFormat:@"音量 %.0f%%", slider.doubleValue] : @"音量を変更できません";
}
- (void)details:(id)sender {
  NSDictionary *panes = @{
    @"volume": @"Sound", @"network": @"Network", @"battery": @"Battery"
  };
  NSString *pane = panes[self.kind];
  NSURL *url = pane
    ? [NSURL fileURLWithPath:[NSString stringWithFormat:@"/System/Library/PreferencePanes/%@.prefPane", pane]]
    : [NSURL fileURLWithPath:@"/System/Applications/Utilities/Activity Monitor.app"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}
@end

static void addVolume(NSMenu *menu, MenuActions *actions) {
  AudioDeviceID device = kAudioObjectUnknown;
  UInt32 size = sizeof(device);
  AudioObjectPropertyAddress output = { kAudioHardwarePropertyDefaultOutputDevice,
    kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
  if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &output, 0, NULL, &size, &device) != noErr) return;
  Float32 value = 0;
  AudioObjectPropertyAddress property = { kAudioDevicePropertyVolumeScalar,
    kAudioObjectPropertyScopeOutput, kAudioObjectPropertyElementMain };
  size = sizeof(value);
  if (AudioObjectGetPropertyData(device, &property, 0, NULL, &size, &value) != noErr) {
    property.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume;
    size = sizeof(value);
    if (AudioObjectGetPropertyData(device, &property, 0, NULL, &size, &value) != noErr) return;
  }
  if (!isfinite(value) || value < 0 || value > 1) return;
  Boolean writable = false;
  if (AudioObjectIsPropertySettable(device, &property, &writable) != noErr || !writable) return;
  actions.device = device;
  actions.volumeProperty = property.mSelector;
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 280, 62)];
  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"音量 %.0f%%", 100 * value]];
  label.frame = NSMakeRect(18, 36, 244, 20);
  actions.volumeLabel = label;
  [view addSubview:label];
  NSSlider *slider = [NSSlider sliderWithValue:100 * value minValue:0 maxValue:100 target:actions action:@selector(volume:)];
  slider.frame = NSMakeRect(18, 10, 244, 24);
  slider.continuous = YES;
  [slider setAccessibilityLabel:@"出力音量"];
  [view addSubview:slider];
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"音量" action:NULL keyEquivalent:@""];
  item.view = view;
  [menu addItem:item];
}

static NSMenuItem *row(NSString *text, BOOL heading) {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:text action:NULL keyEquivalent:@""];
  item.enabled = NO;
  item.attributedTitle = [[NSAttributedString alloc] initWithString:text attributes:@{
    NSFontAttributeName: heading ? [NSFont boldSystemFontOfSize:13] : [NSFont menuFontOfSize:0],
    NSForegroundColorAttributeName: heading ? NSColor.labelColor : NSColor.secondaryLabelColor
  }];
  return item;
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    // Interactive menu tracking must outlive the native client's worker alarm.
    alarm(0);
    if ((argc > 1 && argc < 3) || argc > 32) return 64;
    NSString *kind = argc == 1 ? @"cpu" : [NSString stringWithUTF8String:argv[1]];
    if (![@[@"cpu", @"memory", @"volume", @"network", @"battery", @"calendar"] containsObject:kind]) return 64;
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    if (argc == 1) [lines addObjectsFromArray:@[@"SketchyBar", @"バーの項目をクリックすると詳細を表示します"]];
    for (int i = 2; i < argc; i++) {
      NSString *line = [NSString stringWithUTF8String:argv[i]];
      if (!line || line.length > 512) return 64;
      [lines addObject:line];
    }
    NSString *lockPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"anko-desktop-menu.lock"];
    int lock = open(lockPath.fileSystemRepresentation, O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (lock < 0 || flock(lock, LOCK_EX | LOCK_NB) != 0) return 0;

    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    NSStatusItem *anchor = [NSStatusBar.systemStatusBar statusItemWithLength:1];
    NSMenu *menu = [[NSMenu alloc] initWithTitle:lines.firstObject];
    menu.autoenablesItems = NO;
    menu.minimumWidth = 260;
    [menu addItem:row(lines.firstObject, YES)];
    [menu addItem:NSMenuItem.separatorItem];
    for (NSString *line in [lines subarrayWithRange:NSMakeRange(1, lines.count - 1)]) {
      [menu addItem:row(line, NO)];
    }
    MenuActions *actions = [MenuActions new];
    actions.kind = kind;
    if ([kind isEqualToString:@"calendar"]) {
      NSDatePicker *calendar = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0, 0, 280, 170)];
      calendar.datePickerStyle = NSDatePickerStyleClockAndCalendar;
      calendar.datePickerElements = NSDatePickerElementFlagYearMonthDay;
      calendar.dateValue = NSDate.date;
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"カレンダー" action:NULL keyEquivalent:@""];
      item.view = calendar;
      [menu addItem:item];
    } else {
      if ([kind isEqualToString:@"volume"]) addVolume(menu, actions);
      NSMenuItem *details = [[NSMenuItem alloc] initWithTitle:@"詳細を開く…" action:@selector(details:) keyEquivalent:@""];
      details.target = actions;
      [menu addItem:NSMenuItem.separatorItem];
      [menu addItem:details];
      // Keep the action target alive while AppKit tracks this synchronous menu.
      objc_setAssociatedObject(menu, @selector(details:), actions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSPoint point = NSEvent.mouseLocation;
    NSScreen *screen = NSScreen.mainScreen;
    for (NSScreen *candidate in NSScreen.screens) {
      if (NSPointInRect(point, candidate.frame)) { screen = candidate; break; }
    }
    point.y = NSMaxY(screen.frame) - 36;
    point.x = MIN(MAX(point.x - menu.minimumWidth / 2, NSMinX(screen.frame) + 6),
                  NSMaxX(screen.frame) - menu.minimumWidth - 6);
    dispatch_async(dispatch_get_main_queue(), ^{
      NSPoint local = [anchor.button convertPoint:[anchor.button.window convertPointFromScreen:point] fromView:nil];
      [menu popUpMenuPositioningItem:nil atLocation:local inView:anchor.button];
      [NSStatusBar.systemStatusBar removeStatusItem:anchor];
      close(lock);
      [NSApp terminate:nil];
    });
    [NSApp run];
  }
  return 0;
}
