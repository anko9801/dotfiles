#import "../desktop/sketchybar/helpers/menu-view.m"
#include <assert.h>
#include <mach/mach_time.h>

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    uint64_t start = mach_absolute_time();
    [NSApplication sharedApplication];
    NSMenuItem *item = row(@"Busy\t25%", NO, 360, 100);
    if (argc > 1 && strcmp(argv[1], "--bench") == 0) {
      mach_timebase_info_data_t clock;
      mach_timebase_info(&clock);
      printf("%.3f\n", (mach_absolute_time() - start) * (double)clock.numer / clock.denom / 1e6);
      return 0;
    }
    assert(item.view != nil && "Information must not be drawn as a disabled action");
    NSTextField *label = (NSTextField *)item.view.subviews.firstObject;
    assert([label isKindOfClass:NSTextField.class]);
    assert([label.textColor isEqual:NSColor.labelColor]);
    assert(label.enabled && !label.editable && !label.selectable);
    assert(item.view.subviews.count == 2);
    NSTextField *value = (NSTextField *)item.view.subviews[1];
    assert([value.stringValue isEqualToString:@"25%"] && value.alignment == NSTextAlignmentLeft);
    assert(NSMinX(value.frame) - NSMaxX(label.frame) == 8);
    assert([value.textColor isEqual:NSColor.labelColor]);
    NSMenu *wide = menu_create(@[@"network", @"Network", @"IPv6\t2001:db8:1234:5678:9abc:def0:1234:5678"]);
    assert(wide.minimumWidth >= 200 && wide.minimumWidth <= 480);
    NSMenu *compact = menu_create(@[@"cpu", @"CPU", @"Busy\t5%"]);
    assert(compact.minimumWidth < 260 && "Short menus must not reserve a wide empty panel");
    NSMenu *calendar = menu_create(@[@"calendar", @"Calendar"]);
    NSView *container = calendar.itemArray.lastObject.view;
    NSView *date = container.subviews.firstObject;
    assert(date.frame.size.width > 0 && date.frame.size.height > 0);
    assert(NSMinX(date.frame) >= 12 && NSMaxX(date.frame) <= container.frame.size.width - 12);
    puts("Native menu: informational text uses primary system label color");
  }
}
