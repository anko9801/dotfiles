#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioHardwareService.h>
#include <math.h>

@interface MenuActions : NSObject
@property NSString *kind;
@property AudioDeviceID device;
@property AudioObjectPropertySelector volumeProperty;
@property NSTextField *volumeLabel;
@property NSString *deviceName;
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
    ? [NSString stringWithFormat:@"%@: %.0f%%", self.deviceName, slider.doubleValue] : @"音量を変更できません";
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
  CFStringRef name = NULL;
  size = sizeof(name);
  AudioObjectPropertyAddress naming = { kAudioObjectPropertyName, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
  if (AudioObjectGetPropertyData(device, &naming, 0, NULL, &size, &name) == noErr && name) {
    actions.deviceName = [(__bridge NSString *)name copy];
    CFRelease(name);
  } else actions.deviceName = [NSString stringWithFormat:@"Output %u", device];
  CGFloat width = menu.minimumWidth;
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, width, 62)];
  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"%@: %.0f%%", actions.deviceName, 100 * value]];
  label.frame = NSMakeRect(12, 36, width - 24, 20);
  label.toolTip = actions.deviceName;
  actions.volumeLabel = label;
  [view addSubview:label];
  NSSlider *slider = [NSSlider sliderWithValue:100 * value minValue:0 maxValue:100 target:actions action:@selector(volume:)];
  slider.frame = NSMakeRect(12, 10, width - 24, 24);
  slider.continuous = YES;
  [slider setAccessibilityLabel:@"出力音量"];
  [view addSubview:slider];
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"音量" action:NULL keyEquivalent:@""];
  item.view = view;
  [menu addItem:item];
}

static NSMenuItem *row(NSString *text, BOOL heading, CGFloat width, CGFloat column) {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:text action:NULL keyEquivalent:@""];
  item.enabled = NO;
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, width, heading ? 32 : 24)];
  NSRange split = heading ? NSMakeRange(NSNotFound, 0) : [text rangeOfString:@"\t"];
  NSString *key = split.location == NSNotFound ? text : [text substringToIndex:split.location];
  NSTextField *label = [NSTextField labelWithString:key];
  label.font = heading ? [NSFont boldSystemFontOfSize:14] : [NSFont systemFontOfSize:12];
  label.textColor = NSColor.labelColor;
  label.frame = NSMakeRect(12, 4, split.location == NSNotFound ? width - 24 : column, heading ? 24 : 20);
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.toolTip = text;
  [view addSubview:label];
  if (split.location != NSNotFound) {
    NSString *value = [text substringFromIndex:split.location + 1];
    NSTextField *number = [NSTextField labelWithString:value];
    number.font = [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
    number.textColor = NSColor.labelColor;
    number.alignment = NSTextAlignmentLeft;
    number.frame = NSMakeRect(20 + column, 4, width - column - 32, 20);
    number.lineBreakMode = NSLineBreakByTruncatingTail;
    number.toolTip = value;
    [view addSubview:number];
  }
  item.view = view;
  return item;
}

NSMenu *menu_create(NSArray<NSString *> *request) {
  NSString *kind = request[0];
  NSArray<NSString *> *lines = [request subarrayWithRange:NSMakeRange(1, request.count - 1)];
  NSMenu *menu = [[NSMenu alloc] initWithTitle:lines.firstObject];
  menu.autoenablesItems = NO;
  CGFloat column = 0, valueWidth = 0, plainWidth = 0;
  for (NSString *text in lines) {
    NSRange split = [text rangeOfString:@"\t"];
    if (split.location == NSNotFound) plainWidth = MAX(plainWidth, [text sizeWithAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:12]}].width);
    else {
      column = MAX(column, [[text substringToIndex:split.location] sizeWithAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:12]}].width);
      valueWidth = MAX(valueWidth, [[text substringFromIndex:split.location + 1] sizeWithAttributes:@{NSFontAttributeName: [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular]}].width);
    }
  }
  column = MIN(160, ceil(column) + 2);
  CGFloat minimum = [kind isEqualToString:@"volume"] ? 240 : 200;
  CGFloat width = MIN(480, MAX(minimum, MAX(plainWidth + 24, column + valueWidth + 32)));
  NSDatePicker *calendar = nil;
  if ([kind isEqualToString:@"calendar"]) {
    calendar = [[NSDatePicker alloc] initWithFrame:NSZeroRect];
    calendar.datePickerStyle = NSDatePickerStyleClockAndCalendar;
    calendar.datePickerElements = NSDatePickerElementFlagYearMonthDay;
    calendar.dateValue = NSDate.date;
    [calendar sizeToFit];
    width = MAX(width, calendar.frame.size.width + 24);
  }
  menu.minimumWidth = width;
  [menu addItem:row(lines.firstObject, YES, width, column)];
  [menu addItem:NSMenuItem.separatorItem];
  for (NSString *line in [lines subarrayWithRange:NSMakeRange(1, lines.count - 1)]) {
    [menu addItem:row(line, NO, width, column)];
  }
  MenuActions *actions = [MenuActions new];
  actions.kind = kind;
  if (calendar) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"カレンダー" action:NULL keyEquivalent:@""];
    NSSize size = calendar.frame.size;
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, width, size.height + 8)];
    calendar.frame = NSMakeRect((width - size.width) / 2, 4, size.width, size.height);
    [view addSubview:calendar];
    item.view = view;
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
  return menu;
}
