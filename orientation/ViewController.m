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
@property (strong, nonatomic)UIImage *image;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.image = [self.imageView.image copy];
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
    self.imageView.layer.masksToBounds = NO;
}

- (CGImageRef)applyTransform:(CGAffineTransform)transform toImageRef:(CGImageRef)imageref{
    size_t width = CGImageGetWidth(imageref);
    size_t height = CGImageGetHeight(imageref);
    
    CGAffineTransform invertedTransform = CGAffineTransformInvert(transform);
    CGFloat newW = transform.a * width + transform.c * height;
    CGFloat newH = transform.b * width + transform.d * height;
    
//    CGSize newSize = CGSizeApplyAffineTransform(CGSizeMake(width, height), transform);
    CGSize newSize = CGRectApplyAffineTransform(CGRectMake(0, 0, width, height), transform).size;
//    invertedTransform.tx = (newW - width) * 0.5;
//    invertedTransform.ty = (newH - height) * 0.5;
//     [ cos(angle) sin(angle) -sin(angle) cos(angle) 0 0 ]
    // x' = cos(angle) * x - sin(angle) * y + tx
    // y' = sin(angle) * x + cos(angle) * y + ty
    
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, newSize.width, newSize.height,
                                             CGImageGetBitsPerComponent(imageref), 0,
                                             CGImageGetColorSpace(imageref),
                                             CGImageGetBitmapInfo(imageref));
    
    CGContextConcatCTM(ctx, transform);
    NSLog(@"%.2lf, %.2lf",transform.a, transform.b);
    //transform.b * height
    CGRect rotatedDrawRect = CGRectZero;
    if (transform.a >= 0 && transform.b >= 0) {
        rotatedDrawRect = CGRectMake(transform.b * height * transform.a, - transform.b * transform.b * height, width, height);
    }else if (transform.a <= 0 && transform.b >= 0) {
        rotatedDrawRect = CGRectMake(- fabs(powf(transform.a, 2) * width), - fabs(transform.a * transform.b * width) - height, width, height);
    }else if (transform.a <= 0 && transform.b <= 0){
        rotatedDrawRect = CGRectMake(- fabs(width + height * fabs(transform.a * transform.b)), - fabs(height * powf(transform.a, 2)), width, height);
    }else if (transform.a >= 0 && transform.b <= 0){
        rotatedDrawRect = CGRectMake(- fabs(powf(transform.b, 2) * width), fabs(transform.a * transform.b * width), width, height);
    }
    NSLog(@"%@", [NSValue valueWithCGRect:rotatedDrawRect]);
    CGContextDrawImage(ctx, rotatedDrawRect, imageref);
    CGImageRef resultRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return resultRef;
}

- (IBAction)rotate:(id)sender {
    CGImageRef imageRef = [self applyTransform:CGAffineTransformMakeRotation(M_PI * [(UISlider *)sender value]) toImageRef:self.image.CGImage];
    self.imageView.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
//    CGAffineTransform transform = self.imageView.transform;
//    NSLog(@"%lf",[(UISlider *)sender value]);
//    CGAffineTransform newTransform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation([(UISlider *)sender value]));
//    self.imageView.transform = newTransform;
//    [self refreshTf];
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
//    self.sp.frame = CGRectApplyAffineTransform(self.rect, transform);
//    NSLog(@"%@\n%@",[NSValue valueWithCGRect:self.sp.frame], [NSValue valueWithCGRect:self.imageView.frame]);
    
}

- (IBAction)mirror:(id)sender {
    self.imageView.transform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0);
    [self refreshTf];
}


@end
