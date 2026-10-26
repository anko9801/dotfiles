#import "calendar.h"

void calendar_edit(CalendarEvents *events, NSDate *day) {
  NSMutableArray *available = [NSMutableArray new];
  for (NSDictionary *calendar in events.calendars) if ([calendar[@"writable"] boolValue]) [available addObject:calendar];
  if (!available.count) return;
  NSAlert *alert = [NSAlert new];
  alert.messageText = @"新しい予定";
  alert.informativeText = @"入力した予定は「追加」を押したときだけ保存されます。";
  [alert addButtonWithTitle:@"追加"]; [alert addButtonWithTitle:@"キャンセル"];
  NSView *form = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 280, 164)];
  NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 134, 280, 24)];
  title.placeholderString = @"予定のタイトル"; [form addSubview:title];
  NSCalendar *calendar = NSCalendar.currentCalendar;
  NSDate *startDate = [calendar dateBySettingHour:9 minute:0 second:0 ofDate:day options:0];
  NSDatePicker *(^picker)(NSString *, CGFloat, NSDate *) = ^NSDatePicker *(NSString *name, CGFloat y, NSDate *date) {
    NSTextField *label = [NSTextField labelWithString:name]; label.frame = NSMakeRect(0, y, 44, 24); [form addSubview:label];
    NSDatePicker *field = [[NSDatePicker alloc] initWithFrame:NSMakeRect(48, y, 232, 24)];
    field.datePickerStyle = NSDatePickerStyleTextFieldAndStepper;
    field.datePickerElements = NSDatePickerElementFlagYearMonthDay | NSDatePickerElementFlagHourMinute;
    field.dateValue = date; field.accessibilityLabel = name; [form addSubview:field]; return field;
  };
  NSDatePicker *start = picker(@"開始", 98, startDate);
  NSDatePicker *end = picker(@"終了", 62, [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0]);
  NSPopUpButton *target = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 16, 280, 26)];
  target.accessibilityLabel = @"保存先のカレンダー";
  for (NSDictionary *entry in available) [target addItemWithTitle:[NSString stringWithFormat:@"%@ · %@", entry[@"source"], entry[@"title"]]];
  for (NSUInteger index = 0; index < available.count; index++) if ([available[index][@"default"] boolValue]) { [target selectItemAtIndex:index]; break; }
  [form addSubview:target]; alert.accessoryView = form;
  [alert.window setInitialFirstResponder:title];
  calendar_close();
  NSString *name;
  for (;;) {
    if ([alert runModal] != NSAlertFirstButtonReturn) return;
    name = [title.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (name.length && [end.dateValue compare:start.dateValue] == NSOrderedDescending) break;
    alert.informativeText = @"保存していません。タイトルと、開始より後の終了時刻を入力してください。";
  }
  [events createTitle:name start:start.dateValue end:end.dateValue calendar:available[target.indexOfSelectedItem][@"id"] completion:^(NSError *error) {
    if (error) { NSAlert *failed = [NSAlert new]; failed.messageText = @"予定を保存できませんでした"; failed.informativeText = error.localizedDescription; [failed runModal]; }
  }];
}
