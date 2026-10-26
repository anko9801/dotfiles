#import "calendar.h"

@interface CalendarCanvas : NSView
@property (weak) CalendarView *controller;
@end
@implementation CalendarCanvas
- (BOOL)isFlipped { return YES; }
- (BOOL)acceptsFirstResponder { return YES; }
- (void)keyDown:(NSEvent *)event {
  if (!self.controller) { [super keyDown:event]; return; }
  if (event.keyCode == 53) { if (self.controller.close) self.controller.close(); return; }
  if (event.keyCode == 49) { [self.controller today:nil]; return; }
  if (event.keyCode == 123 || event.keyCode == 124) {
    NSButton *sender = [NSButton new]; sender.tag = event.keyCode == 123 ? -1 : 1;
    [self.controller moveMonth:sender]; return;
  }
  [super keyDown:event];
}
@end

NSArray<NSDate *> *calendar_days(NSDate *month, NSCalendar *calendar) {
  NSDate *first = [calendar dateFromComponents:[calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:month]];
  NSInteger offset = ([calendar component:NSCalendarUnitWeekday fromDate:first] + 5) % 7;
  NSDate *start = [calendar dateByAddingUnit:NSCalendarUnitDay value:-offset toDate:first options:0];
  NSMutableArray *days = [NSMutableArray new];
  for (NSInteger day = 0; day < 42; day++) [days addObject:[calendar dateByAddingUnit:NSCalendarUnitDay value:day toDate:start options:0]];
  return days.copy;
}

static NSTextField *text(NSString *value, NSRect frame, BOOL bold) {
  NSTextField *label = [NSTextField labelWithString:value];
  label.frame = frame;
  label.font = [NSFont systemFontOfSize:12 weight:bold ? NSFontWeightSemibold : NSFontWeightRegular];
  label.textColor = NSColor.labelColor;
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.toolTip = value;
  return label;
}

@implementation CalendarView
- (instancetype)init {
  if (!(self = [super init])) return nil;
  _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  _calendar.timeZone = NSTimeZone.localTimeZone;
  _calendar.firstWeekday = 2; _calendar.minimumDaysInFirstWeek = 4;
  _month = _selectedDate = [_calendar startOfDayForDate:NSDate.date];
  _events = [CalendarEvents new];
  __weak CalendarView *weak = self;
  _events.changed = ^{ [weak render]; };
  return self;
}
- (void)loadView {
  CalendarCanvas *canvas = [[CalendarCanvas alloc] initWithFrame:NSMakeRect(0, 0, 260, 440)];
  canvas.controller = self; self.view = canvas;
}
- (NSButton *)button:(NSString *)title frame:(NSRect)frame action:(SEL)action {
  NSButton *button = [NSButton buttonWithTitle:title target:self action:action];
  button.frame = frame; button.controlSize = NSControlSizeSmall;
  button.bezelStyle = NSBezelStyleRounded;
  button.font = [NSFont systemFontOfSize:11];
  [self.view addSubview:button];
  return button;
}
- (void)render {
  for (NSView *view in self.view.subviews.copy) [view removeFromSuperview];
  NSDateFormatter *format = [NSDateFormatter new];
  format.locale = [NSLocale localeWithLocaleIdentifier:@"ja_JP"]; format.calendar = self.calendar;
  format.dateFormat = @"yyyy年M月";
  NSTextField *title = text([format stringFromDate:self.month], NSMakeRect(14, 14, 132, 20), YES);
  title.font = [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]; [self.view addSubview:title];
  NSButton *previous = [self button:@"‹" frame:NSMakeRect(147, 10, 27, 26) action:@selector(moveMonth:)];
  previous.tag = -1; previous.accessibilityLabel = @"前の月";
  NSButton *next = [self button:@"›" frame:NSMakeRect(176, 10, 27, 26) action:@selector(moveMonth:)];
  next.tag = 1; next.accessibilityLabel = @"次の月";
  [self button:@"今日" frame:NSMakeRect(205, 10, 42, 26) action:@selector(today:)];
  NSArray *weekdays = @[@"月", @"火", @"水", @"木", @"金", @"土", @"日"];
  for (NSInteger column = 0; column < 7; column++) {
    NSTextField *label = text(weekdays[column], NSMakeRect(35 + column * 30, 44, 28, 18), NO);
    label.alignment = NSTextAlignmentCenter; [self.view addSubview:label];
  }
  NSArray *days = calendar_days(self.month, self.calendar);
  for (NSInteger row = 0; row < 6; row++) {
    NSInteger week = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:days[row * 7]];
    NSTextField *label = text([NSString stringWithFormat:@"%ld", (long)week], NSMakeRect(8, 73 + row * 28, 25, 18), NO);
    label.font = [NSFont monospacedDigitSystemFontOfSize:10 weight:NSFontWeightRegular];
    label.textColor = NSColor.secondaryLabelColor; label.alignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
  }
  for (NSInteger index = 0; index < 42; index++) {
    NSDate *date = days[index];
    NSButton *day = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%ld", (long)[self.calendar component:NSCalendarUnitDay fromDate:date]] target:self action:@selector(selectDay:)];
    day.frame = NSMakeRect(35 + (index % 7) * 30, 67 + (index / 7) * 28, 28, 26);
    day.tag = index; day.bezelStyle = NSBezelStyleRegularSquare; day.bordered = NO;
    BOOL selected = [self.calendar isDate:date inSameDayAsDate:self.selectedDate];
    day.wantsLayer = YES; day.layer.cornerRadius = 6;
    day.layer.backgroundColor = (selected ? NSColor.controlAccentColor : NSColor.clearColor).CGColor;
    BOOL thisMonth = [self.calendar isDate:date equalToDate:self.month toUnitGranularity:NSCalendarUnitMonth];
    day.font = [NSFont monospacedDigitSystemFontOfSize:12 weight:[self.calendar isDateInToday:date] ? NSFontWeightBold : NSFontWeightRegular];
    NSColor *color = selected ? NSColor.whiteColor : (thisMonth ? NSColor.labelColor : NSColor.tertiaryLabelColor);
    day.attributedTitle = [[NSAttributedString alloc] initWithString:day.title attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: day.font}];
    format.dateFormat = @"yyyy年M月d日 EEEE"; day.accessibilityLabel = [format stringFromDate:date];
    BOOL hasEvent = NO;
    NSDate *tomorrow = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
    for (NSDictionary *event in self.events.events) {
      if ([event[@"start"] compare:tomorrow] == NSOrderedAscending && [event[@"end"] compare:date] == NSOrderedDescending) { hasEvent = YES; break; }
    }
    if (hasEvent) {
      NSView *dot = [[NSView alloc] initWithFrame:NSMakeRect(12, 1, 3, 3)];
      dot.wantsLayer = YES; dot.layer.cornerRadius = 1.5;
      dot.layer.backgroundColor = (selected ? NSColor.whiteColor : NSColor.controlAccentColor).CGColor;
      [day addSubview:dot];
    }
    [self.view addSubview:day];
  }
  NSBox *line = [[NSBox alloc] initWithFrame:NSMakeRect(14, 242, 232, 1)]; line.boxType = NSBoxSeparator;
  [self.view addSubview:line];
  format.dateFormat = @"M月d日 (E)";
  [self.view addSubview:text([NSString stringWithFormat:@"%@から7日間", [format stringFromDate:self.selectedDate]], NSMakeRect(14, 252, 232, 19), YES)];
  [self renderAgenda:format];
  [self button:@"カレンダー" frame:NSMakeRect(10, 405, 92, 26) action:@selector(filters:)];
  NSButton *add = [self button:@"＋ 予定" frame:NSMakeRect(106, 405, 66, 26) action:@selector(add:)];
  add.enabled = [self.events authorized] && self.events.calendars.count > 0;
  [self button:@"詳細…" frame:NSMakeRect(178, 405, 72, 26) action:@selector(details:)];
  self.preferredContentSize = NSMakeSize(260, 440);
}
- (void)renderAgenda:(NSDateFormatter *)format {
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(14, 276, 232, 120)];
  scroll.hasVerticalScroller = YES; scroll.autohidesScrollers = YES; scroll.drawsBackground = NO;
  CalendarCanvas *list = [[CalendarCanvas alloc] initWithFrame:NSMakeRect(0, 0, 216, 120)];
  CGFloat y = 0;
  NSDate *last = nil, *end = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:self.selectedDate options:0];
  for (NSDictionary *event in self.events.events) {
    NSDate *start = event[@"start"], *finish = event[@"end"];
    if ([start compare:end] != NSOrderedAscending || [finish compare:self.selectedDate] != NSOrderedDescending) continue;
    NSDate *day = [start laterDate:self.selectedDate];
    if (!last || ![self.calendar isDate:last inSameDayAsDate:day]) {
      format.dateFormat = @"M/d (E)";
      [list addSubview:text([format stringFromDate:day], NSMakeRect(0, y, 216, 17), YES)]; y += 20; last = day;
    }
    format.dateFormat = @"H:mm";
    NSString *when = [event[@"allDay"] boolValue] ? @"終日" : [NSString stringWithFormat:@"%@–%@", [format stringFromDate:start], [format stringFromDate:finish]];
    if (![event[@"allDay"] boolValue] && ![self.calendar isDate:start inSameDayAsDate:finish]) {
      format.dateFormat = @"M/d H:mm";
      when = [NSString stringWithFormat:@"%@–%@", [format stringFromDate:start], [format stringFromDate:finish]];
    } else if ([event[@"allDay"] boolValue]) {
      NSDate *lastDay = [finish dateByAddingTimeInterval:-1];
      if (![self.calendar isDate:start inSameDayAsDate:lastDay]) {
        format.dateFormat = @"M/d";
        when = [NSString stringWithFormat:@"終日 %@–%@", [format stringFromDate:start], [format stringFromDate:lastDay]];
      }
    }
    [list addSubview:text([NSString stringWithFormat:@"%@  %@", when, event[@"title"]], NSMakeRect(0, y, 216, 18), NO)]; y += 20;
    if ([event[@"location"] length]) {
      NSTextField *location = text(event[@"location"], NSMakeRect(0, y, 216, 16), NO);
      location.font = [NSFont systemFontOfSize:11]; [list addSubview:location]; y += 18;
    }
    y += 5;
  }
  if (self.events.message || y == 0) {
    NSTextField *status = text(self.events.message ?: @"この7日間の予定はありません", NSMakeRect(0, 0, 216, 38), NO);
    status.maximumNumberOfLines = 2; status.lineBreakMode = NSLineBreakByWordWrapping; [list addSubview:status]; y = 42;
  }
  if (![self.events authorized]) {
    NSButton *allow = [NSButton buttonWithTitle:@"予定を連携…" target:self action:@selector(authorize:)];
    allow.frame = NSMakeRect(0, y, 140, 28); [list addSubview:allow]; y += 30;
  }
  list.frame = NSMakeRect(0, 0, 216, MAX(120, y)); scroll.documentView = list; [self.view addSubview:scroll];
}
- (void)refresh {
  NSArray *days = calendar_days(self.month, self.calendar);
  [self.events loadFrom:days.firstObject to:[self.calendar dateByAddingUnit:NSCalendarUnitDay value:8 toDate:days.lastObject options:0]];
}
- (void)selectDay:(NSButton *)sender { self.selectedDate = calendar_days(self.month, self.calendar)[sender.tag]; [self render]; }
- (void)moveMonth:(NSButton *)sender {
  NSDate *first = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.month]];
  self.month = self.selectedDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:sender.tag toDate:first options:0];
  [self refresh];
}
- (void)today:(id)sender { (void)sender; self.month = self.selectedDate = [self.calendar startOfDayForDate:NSDate.date]; [self refresh]; }
- (void)authorize:(id)sender { (void)sender; [self.events requestAccess]; }
- (void)add:(id)sender { (void)sender; calendar_edit(self.events, self.selectedDate); }
- (void)details:(id)sender {
  (void)sender;
  NSDateFormatter *format = [NSDateFormatter new]; format.dateFormat = @"yyyy-MM-dd"; format.calendar = self.calendar;
  NSURL *url = [NSURL URLWithString:[@"itsycal://date/" stringByAppendingString:[format stringFromDate:self.selectedDate]]];
  if (self.close) self.close(); [NSWorkspace.sharedWorkspace openURL:url];
}
- (void)filters:(NSButton *)sender {
  NSMenu *menu = [NSMenu new];
  for (NSDictionary *calendar in self.events.calendars) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ · %@", calendar[@"source"], calendar[@"title"]] action:@selector(toggle:) keyEquivalent:@""];
    item.target = self; item.representedObject = calendar[@"id"];
    item.state = !self.events.selected || [self.events.selected containsObject:calendar[@"id"]] ? NSControlStateValueOn : NSControlStateValueOff;
    [menu addItem:item];
  }
  if (!menu.numberOfItems) [menu addItemWithTitle:@"先に予定へのアクセスを許可してください" action:NULL keyEquivalent:@""];
  [menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, NSHeight(sender.bounds)) inView:sender];
}
- (void)toggle:(NSMenuItem *)sender { [self.events toggle:sender.representedObject]; }
@end
