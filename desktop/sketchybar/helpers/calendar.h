#import <AppKit/AppKit.h>
#import <EventKit/EventKit.h>

NSArray<NSDate *> *calendar_days(NSDate *month, NSCalendar *calendar);
NSRect calendar_anchor(NSPoint click, NSRect screen);

@interface CalendarEvents : NSObject
@property (copy) NSArray<NSDictionary *> *events;
@property (copy) NSArray<NSDictionary *> *calendars;
@property (copy) NSSet<NSString *> *selected;
@property (copy) void (^changed)(void);
@property (copy) NSString *message;
- (BOOL)authorized;
- (void)requestAccess;
- (void)loadFrom:(NSDate *)start to:(NSDate *)end;
- (void)toggle:(NSString *)identifier;
- (void)createTitle:(NSString *)title start:(NSDate *)start end:(NSDate *)end calendar:(NSString *)identifier completion:(void (^)(NSError *))completion;
@end

@interface CalendarView : NSViewController
@property NSCalendar *calendar;
@property NSDate *selectedDate;
@property NSDate *month;
@property CalendarEvents *events;
@property (copy) void (^close)(void);
- (void)render;
- (void)refresh;
- (void)moveMonth:(NSButton *)sender;
- (void)today:(id)sender;
@end

void calendar_show(void);
void calendar_prepare(void);
void calendar_close(void);
void calendar_edit(CalendarEvents *events, NSDate *day);
