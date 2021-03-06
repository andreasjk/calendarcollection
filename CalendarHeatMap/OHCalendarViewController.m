//
//  OHCalendarViewController.m
//  CalendarHeatMap
//
//  Created by Oskar Hagberg on 2013-04-21.
//  Copyright (c) 2013 Oskar Hagberg. All rights reserved.
//

#import "OHCalendarViewController.h"
#import "OHCalendarView.h"

#define ranged_random(min, max) ((float)rand()/RAND_MAX * (max-min)+min)

@interface OHCalendarCircleDayCell : UICollectionViewCell

//@property (nonatomic, weak, readonly) UILabel* label;
@property (nonatomic) CGFloat diameter; // 0.0 - 1.0
@property (nonatomic, copy) UIColor* fillColor;
@property (nonatomic, copy) UIColor* strokeColor;
@property (nonatomic) BOOL circle;

@end

@implementation OHCalendarCircleDayCell

//@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setDiameter:(CGFloat)diameter
{
    _diameter = diameter;
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = [fillColor copy];
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = [strokeColor copy];
    [self setNeedsDisplay];
}

- (void)setup
{
    self.opaque = NO;
    self.circle = YES;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat edge = MIN(rect.size.width, rect.size.height);
    CGFloat inset = (edge - self.diameter * edge) / 2.0;
    CGRect ellipseRect = CGRectInset(rect, inset, inset);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(c, rect);
    
    CGContextSetFillColorWithColor(c, self.fillColor.CGColor);
    
    if (self.circle) {
        CGContextFillEllipseInRect(c, ellipseRect);
    } else {
        CGContextFillRect(c, ellipseRect);
    }
    
    CGContextSetLineWidth(c, 1);
    CGContextSetStrokeColorWithColor(c, self.strokeColor.CGColor);
    if (self.circle) {
        CGContextStrokeEllipseInRect(c, ellipseRect);
    } else {
        CGContextStrokeRect(c, ellipseRect);
    }

}

- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout
{
//    if ([newLayout isKindOfClass:[OHCalendarWeekLayout class]]) {
//        self.circle = NO;
//    } else {
//        self.circle = YES;
//    }
    [self setNeedsDisplay];
}

@end

@interface OHCalendarViewController () <OHCalendarViewDataSource, OHCalendarViewDelegate>

@property (nonatomic, weak) OHCalendarView* calendarView;
@property (nonatomic, strong) OHCalendarMonthLayout* monthLayout;
@property (nonatomic, strong) OHCalendarWeekLayout* weekLayout;
@property (nonatomic, strong) OHCalendarDayLayout* dayLayout;

@end

@implementation OHCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    OHCalendarMonthLayout* monthLayout = [[OHCalendarMonthLayout alloc] init];
    monthLayout.leftMargin = 10.0;
    monthLayout.rightMargin = monthLayout.leftMargin;
    self.monthLayout = monthLayout;
    
    OHCalendarWeekLayout* weekLayout = [[OHCalendarWeekLayout alloc] init];
    weekLayout.leftMargin = 80.0;
    weekLayout.rightMargin = weekLayout.leftMargin;
    self.weekLayout = weekLayout;
    
    OHCalendarDayLayout* dayLayout = [[OHCalendarDayLayout alloc] init];
    dayLayout.leftMargin = 149.0;
    dayLayout.rightMargin = dayLayout.leftMargin;
    self.dayLayout = dayLayout;
    
    OHCalendarView* calendarView = [[OHCalendarView alloc] initWithFrame:self.calendarWrapperView.bounds
                                                          calendarLayout:monthLayout];
    
    calendarView.endDate = [NSDate date];
    NSDateComponents* oneYearAgo = [[NSDateComponents alloc] init];
    oneYearAgo.year = -1;
    calendarView.startDate = [calendarView.calendar dateByAddingComponents:oneYearAgo
                                                                    toDate:calendarView.endDate
                                                                   options:0];
    
    calendarView.delegate = self;
    calendarView.dataSource = self;
    calendarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    calendarView.backgroundColor = [UIColor whiteColor];
    calendarView.showDayLabel = YES;
    [self.calendarWrapperView addSubview:calendarView];
    self.calendarView = calendarView;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.calendarView addGestureRecognizer:tap];
    
    [calendarView registerClass:[OHCalendarCircleDayCell class] forCellWithReuseIdentifier:@"cell"];
    
}

- (void)tapped
{
    if (self.calendarView.calendarLayout == self.monthLayout) {
        [self.calendarView setCalendarViewLayout:self.weekLayout animated:YES];
        
    } else if (self.calendarView.calendarLayout == self.weekLayout) {
        [self.calendarView setCalendarViewLayout:self.dayLayout animated:YES];
        
    } else {
        [self.calendarView setCalendarViewLayout:self.monthLayout animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OHCalendarViewDataSource implementation

- (UICollectionViewCell*)calendarView:(OHCalendarView*)calendarView cellForDate:(NSDate*)date
{
    OHCalendarCircleDayCell* cell = (OHCalendarCircleDayCell*)[calendarView dequeueReusableCellWithReuseIdentifier:@"cell" forDate:date];
    cell.fillColor = [self randomHSBColor];
    cell.strokeColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    cell.diameter = ranged_random(0.2, 1.0);
    return cell;
}

- (UIColor*)calendarView:(OHCalendarView*)calendarView backgroundColorForDate:(NSDate*)date
{
    NSDateComponents* components = [calendarView.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    if (components.day == 1) {
        return [UIColor yellowColor];
    }
    return [self randomHSBColor];
}

- (UIColor*)randomRGBColor
{
    
    float r = ranged_random(0.0, 1.0);
    float g = ranged_random(0.0, 1.0);
    float b = ranged_random(0.0, 1.0);
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

#define ARC4RANDOM_MAX      0x100000000
- (UIColor*)randomHSBColor
{
    double h = ranged_random(0.2, 0.2);
    double s = ranged_random(0.0, 0.4);
    double b = ranged_random(0.8, 1.0);
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:1.0];
}

#pragma mark - OHCalendarViewDelegate implementation

#pragma mark - User interaction

- (IBAction)showMonthLayout:(id)sender {
    [self.calendarView setCalendarViewLayout:self.monthLayout animated:YES];
}

- (IBAction)showWeekLayout:(id)sender {
    [self.calendarView setCalendarViewLayout:self.weekLayout animated:YES];
}

- (IBAction)showDayLayout:(id)sender {
    [self.calendarView setCalendarViewLayout:self.dayLayout animated:YES];
}

@end
