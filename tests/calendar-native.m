#import "../desktop/sketchybar/helpers/calendar.h"
#include <assert.h>

@interface CalendarFixture : CalendarEvents
@end
@implementation CalendarFixture
- (BOOL)authorized { return YES; }
- (void)loadFrom:(NSDate *)start to:(NSDate *)end { assert([end compare:start] == NSOrderedDescending); if (self.changed) self.changed(); }
@end

static NSDate *date(NSString *value, NSCalendar *calendar) {
  NSDateFormatter *format = [NSDateFormatter new]; format.calendar = calendar; format.timeZone = calendar.timeZone; format.dateFormat = @"yyyy-MM-dd";
  return [format dateFromString:value];
}

int main(void) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    calendar.firstWeekday = 2; calendar.minimumDaysInFirstWeek = 4;
    NSArray *days = calendar_days(date(@"2024-03-31", calendar), calendar);
    assert(days.count == 42);
    assert([days.firstObject isEqualToDate:date(@"2024-02-26", calendar)]);
    assert([days.lastObject isEqualToDate:date(@"2024-04-07", calendar)]);
    for (NSDate *day in days) assert([calendar component:NSCalendarUnitHour fromDate:day] == 0);
    NSArray *leap = calendar_days(date(@"2024-02-01", calendar), calendar);
    assert([leap containsObject:date(@"2024-02-29", calendar)]);
    NSArray *year = calendar_days(date(@"2026-01-01", calendar), calendar);
    assert([year.firstObject isEqualToDate:date(@"2025-12-29", calendar)]);
    assert([calendar component:NSCalendarUnitWeekOfYear fromDate:year.firstObject] == 1);
    NSRect anchor = calendar_anchor(NSMakePoint(1440, 970), NSMakeRect(0, 0, 1512, 982));
    assert(anchor.origin.x == 1440 && anchor.origin.y == 948);
    assert(NSMaxY(anchor) <= 982 - 32 && "Calendar must open below the 32-point bar");
    NSRect second = calendar_anchor(NSMakePoint(-160, 300), NSMakeRect(-1920, -200, 1920, 1080));
    assert(second.origin.x == -160 && second.origin.y == 846);
    CalendarView *view = [CalendarView new];
    view.calendar = calendar; view.month = view.selectedDate = date(@"2026-01-31", calendar);
    CalendarFixture *fixture = [CalendarFixture new];
    fixture.events = @[@{@"title": [@"Very long event " stringByPaddingToLength:300 withString:@"x" startingAtIndex:0], @"start": view.selectedDate,
      @"end": [view.selectedDate dateByAddingTimeInterval:3600], @"allDay": @NO, @"location": @"A long location that must never widen the popup"}];
    fixture.changed = ^{ [view render]; }; view.events = fixture; [view render];
    assert(view.view.frame.size.width == 260 && view.preferredContentSize.width == 260);
    NSUInteger cells = 0;
    for (NSView *child in view.view.subviews) {
      assert(NSMinX(child.frame) >= 0 && NSMaxX(child.frame) <= 260);
      if ([child isKindOfClass:NSButton.class] && ((NSButton *)child).action == NSSelectorFromString(@"selectDay:")) cells++;
    }
    assert(cells == 42);
    NSButton *next = [NSButton new]; next.tag = 1; [view moveMonth:next];
    assert([view.month isEqualToDate:date(@"2026-02-01", calendar)] && "January 31 must not skip February");
    fixture.changed = nil;
    puts("Calendar: click anchor below bar, compact long-title layout, ISO weeks, leap day, DST and month navigation passed");
  }
}
