#import "calendar.h"

@implementation CalendarEvents {
  EKEventStore *_store;
  dispatch_queue_t _queue;
  NSUInteger _serial;
  NSDate *_start, *_end;
}
- (instancetype)init {
  if (!(self = [super init])) return nil;
  _queue = dispatch_queue_create("pub.anko.calendar.events", DISPATCH_QUEUE_SERIAL);
  _events = @[];
  _calendars = @[];
  NSArray *saved = [NSUserDefaults.standardUserDefaults arrayForKey:@"CalendarSelection"];
  if (!saved) saved = [NSUserDefaults.standardUserDefaults persistentDomainForName:@"com.mowglii.ItsycalApp"][@"SelectedCalendars"];
  _selected = saved ? [NSSet setWithArray:saved] : nil;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:) name:EKEventStoreChangedNotification object:nil];
  return self;
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (BOOL)authorized {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusFullAccess;
}
- (void)storeChanged:(NSNotification *)note {
  (void)note;
  dispatch_async(dispatch_get_main_queue(), ^{ if (self->_start) [self loadFrom:self->_start to:self->_end]; });
}
- (void)requestAccess {
  dispatch_async(_queue, ^{
    if (!self->_store) self->_store = [EKEventStore new];
    [self->_store requestFullAccessToEventsWithCompletion:^(BOOL granted, NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        self.message = granted ? nil : (error.localizedDescription ?: @"予定へのアクセスが許可されていません");
        if (granted && self->_start) [self loadFrom:self->_start to:self->_end];
        else if (self.changed) self.changed();
      });
    }];
  });
}
- (void)loadFrom:(NSDate *)start to:(NSDate *)end {
  _start = start; _end = end;
  NSUInteger serial = ++_serial;
  self.events = @[];
  if (![self authorized]) {
    self.calendars = @[];
    self.message = @"予定の連携にはカレンダーの許可が必要です";
    if (self.changed) self.changed();
    return;
  }
  self.message = @"予定を読み込み中…";
  if (self.changed) self.changed();
  NSSet *selection = self.selected;
  dispatch_async(_queue, ^{
    if (!self->_store) self->_store = [EKEventStore new];
    NSArray *available = [self->_store calendarsForEntityType:EKEntityTypeEvent];
    NSString *defaultID = self->_store.defaultCalendarForNewEvents.calendarIdentifier;
    NSMutableArray *chosen = [NSMutableArray new], *calendars = [NSMutableArray new], *result = [NSMutableArray new];
    for (EKCalendar *calendar in available) {
      NSString *identifier = calendar.calendarIdentifier;
      [calendars addObject:@{@"id": identifier, @"title": calendar.title ?: @"カレンダー",
        @"source": calendar.source.title ?: @"", @"writable": @(calendar.allowsContentModifications), @"default": @([identifier isEqualToString:defaultID])}];
      if (!selection || [selection containsObject:identifier]) [chosen addObject:calendar];
    }
    // An explicitly empty selection must not become EventKit's nil (= all calendars).
    if (chosen.count) {
      NSPredicate *predicate = [self->_store predicateForEventsWithStartDate:start endDate:end calendars:chosen];
      NSArray *events = [[self->_store eventsMatchingPredicate:predicate] sortedArrayUsingComparator:^NSComparisonResult(EKEvent *a, EKEvent *b) { return [a.startDate compare:b.startDate]; }];
      for (EKEvent *event in events) {
        [result addObject:@{@"title": event.title ?: @"（無題）", @"start": event.startDate,
          @"end": event.endDate, @"allDay": @(event.allDay), @"location": event.location ?: @""}];
      }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if (serial != self->_serial) return;
      self.calendars = calendars.copy;
      self.events = result.copy;
      self.message = available.count == 0 ? @"同期済みのカレンダーがありません" : (chosen.count ? nil : @"「カレンダー」で表示対象を選んでください");
      if (self.changed) self.changed();
    });
  });
}
- (void)toggle:(NSString *)identifier {
  NSMutableSet *selection = self.selected ? self.selected.mutableCopy : [NSMutableSet setWithArray:[self.calendars valueForKey:@"id"]];
  if ([selection containsObject:identifier]) [selection removeObject:identifier]; else [selection addObject:identifier];
  self.selected = selection.copy;
  [NSUserDefaults.standardUserDefaults setObject:selection.allObjects forKey:@"CalendarSelection"];
  if (_start) [self loadFrom:_start to:_end];
}
- (void)createTitle:(NSString *)title start:(NSDate *)start end:(NSDate *)end calendar:(NSString *)identifier completion:(void (^)(NSError *))completion {
  dispatch_async(_queue, ^{
    NSError *error = nil;
    if (![self authorized] || !self->_store || [end compare:start] != NSOrderedDescending) {
      error = [NSError errorWithDomain:@"Calendar" code:1 userInfo:@{NSLocalizedDescriptionKey: @"権限と開始・終了時刻を確認してください"}];
    } else {
      EKCalendar *calendar = [self->_store calendarWithIdentifier:identifier];
      if (!calendar || !calendar.allowsContentModifications) {
        error = [NSError errorWithDomain:@"Calendar" code:2 userInfo:@{NSLocalizedDescriptionKey: @"書き込み可能なカレンダーを選んでください"}];
      } else {
        EKEvent *event = [EKEvent eventWithEventStore:self->_store];
        event.title = title; event.startDate = start; event.endDate = end; event.calendar = calendar;
        if (![self->_store saveEvent:event span:EKSpanThisEvent commit:YES error:&error] && !error)
          error = [NSError errorWithDomain:@"Calendar" code:3 userInfo:@{NSLocalizedDescriptionKey: @"予定を保存できませんでした"}];
      }
    }
    dispatch_async(dispatch_get_main_queue(), ^{ completion(error); });
  });
}
@end
