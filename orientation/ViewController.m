//
//  ViewController.m
//  orientation
//
//  Created by zhang ming on 2019/5/6.
//  Copyright © 2019 zhang ming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tf_a;
@property (weak, nonatomic) IBOutlet UITextField *tf_b;
@property (weak, nonatomic) IBOutlet UITextField *tf_c;
@property (weak, nonatomic) IBOutlet UITextField *tf_d;
@property (weak, nonatomic) IBOutlet UITextField *tf_tx;
@property (weak, nonatomic) IBOutlet UITextField *tf_ty;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *sp;
@property (assign, nonatomic)CGRect rect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];

    UIPinchGestureRecognizer* pincher = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
    pincher.delegate = self;
    [self.imageView addGestureRecognizer:pincher];
    //拖拽
    UIPanGestureRecognizer* panner = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    panner.delegate = self;
    [self.imageView addGestureRecognizer:panner];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateAction:)];
    rotation.delegate = self;
    [self.imageView addGestureRecognizer:rotation];
    self.slider.value = 0;
    self.slider.maximumValue = M_PI;
    self.slider.minimumValue = 0;
    [self.slider sendActionsForControlEvents:UIControlEventValueChanged];
    self.rect = self.imageView.frame;
    self.sp.frame = self.rect;
}

- (IBAction)rotate:(id)sender {
    CGAffineTransform transform = self.imageView.transform;
    NSLog(@"%lf",[(UISlider *)sender value]);
    CGAffineTransform newTransform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation([(UISlider *)sender value]));
    self.imageView.transform = newTransform;
    [self refreshTf];
}

- (IBAction)change:(id)sender {
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            [(UITextField *)subview resignFirstResponder];
        }
    }
    self.imageView.transform = CGAffineTransformMake(self.tf_a.text.floatValue, self.tf_b.text.floatValue, self.tf_c.text.floatValue, self.tf_d.text.floatValue, self.tf_tx.text.floatValue, self.tf_ty.text.floatValue);
}

- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer{
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1.0;
    [self refreshTf];
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer{
    CGPoint tranlation = [recognizer translationInView:self.imageView];
    self.imageView.transform =  CGAffineTransformTranslate(self.imageView.transform, tranlation.x, tranlation.y);
    [recognizer setTranslation:CGPointZero inView:self.imageView];
    [self refreshTf];
}

- (void)rotateAction:(UIRotationGestureRecognizer *)gesture{
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, gesture.rotation);
    gesture.rotation = 0;
    [self refreshTf];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (void)refreshTf{
    CGAffineTransform transform = self.imageView.transform;
    self.tf_a.text = [NSString stringWithFormat:@"%.2lf",transform.a];
    self.tf_b.text = [NSString stringWithFormat:@"%.2lf",transform.b];
    self.tf_c.text = [NSString stringWithFormat:@"%.2lf",transform.c];
    self.tf_d.text = [NSString stringWithFormat:@"%.2lf",transform.d];
    self.tf_tx.text = [NSString stringWithFormat:@"%.2lf",transform.tx];
    self.tf_ty.text = [NSString stringWithFormat:@"%.2lf",transform.ty];
//    CGFloat width = self.imageView.frame.size.width;
//    CGFloat height = self.imageView.frame.size.height;
//    CGFloat newW = fabs(transform.a * width + transform.c * height);
//    CGFloat newH = fabs(transform.b * width + transform.d * height);
    self.sp.frame = CGRectApplyAffineTransform(self.rect, transform);
    NSLog(@"%@\n%@",[NSValue valueWithCGRect:self.sp.frame], [NSValue valueWithCGRect:self.imageView.frame]);
    
}

- (IBAction)mirror:(id)sender {
    self.imageView.transform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0);
    [self refreshTf];
}


@end
