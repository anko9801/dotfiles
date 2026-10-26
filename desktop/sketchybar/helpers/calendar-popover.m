#import "calendar.h"

static CalendarView *controller;
static NSPopover *popover;
static NSWindow *anchor;

NSRect calendar_anchor(NSPoint click, NSRect screen) {
  CGFloat x = MIN(MAX(click.x, NSMinX(screen) + 8), NSMaxX(screen) - 8);
  return NSMakeRect(x, NSMaxY(screen) - 34, 1, 1);
}

@interface CalendarPopover : NSObject <NSPopoverDelegate>
@end
@implementation CalendarPopover
- (void)popoverDidClose:(NSNotification *)notification { (void)notification; [anchor orderOut:nil]; }
@end

void calendar_prepare(void) {
  if (controller) return;
  controller = [CalendarView new];
  controller.close = ^{ calendar_close(); };
  [controller render];
  popover = [NSPopover new];
  popover.contentViewController = controller;
  popover.contentSize = NSMakeSize(260, 440);
  popover.behavior = NSPopoverBehaviorTransient;
  popover.animates = NO;
  static CalendarPopover *delegate;
  delegate = [CalendarPopover new]; popover.delegate = delegate;
  anchor = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1, 1) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
  anchor.backgroundColor = NSColor.clearColor; anchor.opaque = NO;
  anchor.hasShadow = NO; anchor.level = NSStatusWindowLevel;
  anchor.collectionBehavior = NSWindowCollectionBehaviorMoveToActiveSpace | NSWindowCollectionBehaviorFullScreenAuxiliary;
  anchor.releasedWhenClosed = NO;
}
void calendar_close(void) {
  if (popover.shown) [popover performClose:nil];
  [anchor orderOut:nil];
}
void calendar_show(void) {
  calendar_prepare();
  if (popover.shown) { calendar_close(); return; }
  NSPoint click = NSEvent.mouseLocation;
  NSScreen *screen = NSScreen.mainScreen;
  for (NSScreen *candidate in NSScreen.screens) if (NSPointInRect(click, candidate.frame)) { screen = candidate; break; }
  [anchor setFrame:calendar_anchor(click, screen.frame) display:NO];
  [anchor orderFrontRegardless];
  controller.calendar.timeZone = NSTimeZone.localTimeZone;
  [controller today:nil];
  [NSApp activateIgnoringOtherApps:YES];
  [popover showRelativeToRect:anchor.contentView.bounds ofView:anchor.contentView preferredEdge:NSRectEdgeMinY];
  [popover.contentViewController.view.window makeKeyWindow];
  [popover.contentViewController.view.window makeFirstResponder:controller.view];
}
