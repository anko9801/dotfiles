#import "../desktop/sketchybar/helpers/menu-view.m"
#include <assert.h>
#include <mach/mach_time.h>

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    uint64_t start = mach_absolute_time();
    [NSApplication sharedApplication];
    NSMenuItem *item = row(@"使用率 25%", NO);
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
    puts("Native menu: informational text uses primary system label color");
  }
}
