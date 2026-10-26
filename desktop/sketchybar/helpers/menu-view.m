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
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 280, heading ? 32 : 26)];
  NSTextField *label = [NSTextField labelWithString:text];
  label.font = heading ? [NSFont boldSystemFontOfSize:14] : [NSFont menuFontOfSize:0];
  label.textColor = NSColor.labelColor;
  label.frame = NSMakeRect(18, 4, 244, heading ? 24 : 20);
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.toolTip = text;
  [view addSubview:label];
  item.view = view;
  return item;
}

NSMenu *menu_create(NSArray<NSString *> *request) {
  NSString *kind = request[0];
  NSArray<NSString *> *lines = [request subarrayWithRange:NSMakeRange(1, request.count - 1)];
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
  return menu;
}
