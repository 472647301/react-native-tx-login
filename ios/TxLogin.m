// TxLogin.m

#define SCREEN_RECT_WIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREEN_RECT_HEIGHT      [UIScreen mainScreen].bounds.size.height
// 判断是否是iPhone X系列
#define isIphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define isIPhoneX (SCREEN_RECT_WIDTH >= 375.0f && SCREEN_RECT_HEIGHT >= 812.0f && isIphone) || (SCREEN_RECT_WIDTH == 360.0f && SCREEN_RECT_HEIGHT == 780.0f && isIphone)

#import "TxLogin.h"

@implementation TxLogin

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"TxAuthSdk"];
}

//返回数据处理
- (NSString *)stringWithError:(id)error {
    
    if ([error isKindOfClass:[NSDictionary class]]) {
        return  [self descriptionWithLocale:error] ;
    } else {
        return error;
    }
}

#pragma mark 字典转化成字符串

- (NSString *)descriptionWithLocale:(NSDictionary*)locale {
    
    NSMutableString *msr = [NSMutableString string];
    [msr appendString:@"{"];
    [locale enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [msr appendFormat:@"\n\t%@ = %@,",key,obj];
    }];
    //去掉最后一个逗号（,）
    if ([msr hasSuffix:@","]) {
        NSString *str = [msr substringToIndex:msr.length - 1];
        msr = [NSMutableString stringWithString:str];
    }
    [msr appendString:@"\n}"];
    return msr;
}

// 初始化方法
RCT_EXPORT_METHOD(init:(NSString *)apiId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [TXLoginOauthSDK initLoginWithId:apiId];
    resolve(nil);
}

RCT_EXPORT_METHOD(login:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [TXLoginOauthSDK preLoginWithBack:^(NSDictionary * _Nonnull resultDic) {
        [self getToken:params];
        resolve(nil);
    } failBlock:^(id  _Nonnull error) {
        reject(@"404", [self stringWithError:error], nil);
    }];
}

-(void) getToken:(NSDictionary *)params
{
    TXLoginUIModel *uiModel =  [[TXLoginUIModel alloc] init];
    if ([params objectForKey:@"background_color"]) {
        CGRect backViewFrame = CGRectMake(0, 0, SCREEN_RECT_WIDTH, SCREEN_RECT_HEIGHT);
        UIView *backgroundView = [[UIView alloc] initWithFrame:backViewFrame];
        backgroundView.backgroundColor = [self colorWithHexString:params[@"background_color"]];
        [uiModel setCustomBackgroundView:backgroundView];
    }
    if ([params objectForKey:@"background_image"]) {
        [uiModel setViewBackImg:[UIImage imageNamed:params[@"background_image"]]];
    }
    // 导航栏
    CGRect navFrame = CGRectMake(0, 0, SCREEN_RECT_WIDTH, isIPhoneX ? 88 : 76);
    UIView *navView = [[UIView alloc] initWithFrame:navFrame];
    UIButton *navLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, isIPhoneX ? 44 : 32, 44, 44)];
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, isIPhoneX ? 44 : 32, SCREEN_RECT_WIDTH - 88, 44)];
    navLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    navLabel.textAlignment = NSTextAlignmentCenter;
    if ([params objectForKey:@"nav_title"]) {
        navLabel.text = params[@"nav_title"];  //设置标题
    }
    if ([params objectForKey:@"nav_title_size"]) {
        navLabel.font = [UIFont boldSystemFontOfSize:[params[@"nav_title_size"] doubleValue]];  //设置文本字体与大小
    }
    if ([params objectForKey:@"nav_title_color"]) {
        navLabel.textColor = [self colorWithHexString:params[@"nav_title_color"]];
    }
    if ([params objectForKey:@"nav_icon"]) {
        [navLeft.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [navLeft setImage:[UIImage imageNamed:params[@"nav_icon"]] forState:UIControlStateNormal];
        [navLeft addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [navView addSubview:navLeft];
    [navView addSubview:navLabel];
    [uiModel setCustomTopLoginView:navView];
    // logo
    float logoY = navView.frame.size.height + 170;
    CGRect logoFrame = CGRectMake((SCREEN_RECT_WIDTH - 80)/2.0 , logoY, 80.0, 80.0);
    if ([params objectForKey:@"image_logo"]) {
        [uiModel setIconImage:[UIImage imageNamed:params[@"image_logo"]]];
        [uiModel setLogoFrame:logoFrame];
        [uiModel setLogoHidden:NO];
    }
    [uiModel setSloganLabelOffsetY:SCREEN_RECT_HEIGHT / 2];
    
    if ([params objectForKey:@"state_text_size"]) {
        [uiModel setBrandLabelTextSize:[UIFont systemFontOfSize:[params[@"state_text_size"] doubleValue]]];
    }
    if ([params objectForKey:@"state_text_color"]) {
        [uiModel setSloganTextColor:[self colorWithHexString:params[@"state_text_color"]]];
    }
    // 手机号码
    if ([params objectForKey:@"number_size"] && [params objectForKey:@"number_color"]) {
        double numberFontSize = [params[@"number_size"] doubleValue];
        [uiModel setNumberTextAttributes:@{NSForegroundColorAttributeName:[self colorWithHexString:params[@"number_color"]],NSFontAttributeName:[UIFont systemFontOfSize:numberFontSize]}];
    }
    if ([params objectForKey:@"number_offset_y"]) {
        float numberOffsetY = SCREEN_RECT_HEIGHT - [params[@"number_offset_y"] floatValue];
        [uiModel setTxMobliNumberOffsetY:@(numberOffsetY)];
    }
    // 登录按钮
    if ([params objectForKey:@"login_image"]) {
        [uiModel setLoginBtnImgs:@[[UIImage imageNamed:params[@"login_image"]],[UIImage imageNamed:params[@"login_image"]],[UIImage imageNamed:params[@"login_image"]]]];
    }
    if ([params objectForKey:@"login_text"] && [params objectForKey:@"login_text_size"] && [params objectForKey:@"login_text_color"]) {
        double loginFontSize = [params[@"login_text_size"] doubleValue];
        [uiModel setLogBtnText:[[NSAttributedString alloc]initWithString:params[@"login_text"] attributes:@{NSForegroundColorAttributeName:[self colorWithHexString:params[@"login_text_color"]],NSFontAttributeName:[UIFont systemFontOfSize:loginFontSize]}]];
    }
    if ([params objectForKey:@"login_offset_y"]) {
        float loginY = SCREEN_RECT_HEIGHT - [params[@"login_offset_y"] floatValue];
        [uiModel setLogBtnOffsetY:loginY];
    } else {
        [uiModel setLogBtnOffsetY:SCREEN_RECT_HEIGHT / 2 - 80];
    }
    if ([params objectForKey:@"login_height"]) {
        [uiModel setLogBtnHeight:[[params objectForKey:@"login_height"] floatValue]];
    }
    // 其他登录方式
    UIView *otherLoginView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_RECT_HEIGHT- uiModel.logBtnOffsetY + 20, SCREEN_RECT_WIDTH, 48)];
    UILabel *otherLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, otherLoginView.frame.size.width, 20)];
    otherLoginLabel.textAlignment = NSTextAlignmentCenter;
    otherLoginLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOtherLogin:)];
    [otherLoginLabel addGestureRecognizer:rec];
    if ([params objectForKey:@"other_text"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:params[@"other_text"]];
        NSRange strRange = {0,[str length]};
        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        otherLoginLabel.attributedText = str;
    }
    if ([params objectForKey:@"other_text_size"]) {
        otherLoginLabel.font = [UIFont systemFontOfSize:[params[@"other_text_size"] doubleValue]];
    }
    if ([params objectForKey:@"other_text_color"]) {
        otherLoginLabel.textColor = [self colorWithHexString:params[@"other_text_color"]];
    }
    [otherLoginView addSubview:otherLoginLabel];
    [uiModel setCustomOtherLoginViews:@[otherLoginView]];
    [uiModel setIfCreateCustomView:YES];
    /**隐私协议*/
    if ([params objectForKey:@"protocol_y"]) {
        [uiModel setPrivacyLabelOffsetY:[params[@"protocol_y"] floatValue]];
    }
    if ([params objectForKey:@"protocol_text_color"]) {
        NSAttributedString* strappPrivacy =[[NSAttributedString alloc] initWithString:@"登录即同意&&并使用本机号码登录" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 14.0],NSForegroundColorAttributeName:[self colorWithHexString:params[@"protocol_text_color"]],NSParagraphStyleAttributeName:[[NSMutableParagraphStyle alloc] init]}];
        [uiModel setAppPrivacyDemo:strappPrivacy];
    }
    if ([params objectForKey:@"protocol_highlight_color"]) {
        [uiModel setPrivacyColor:[self colorWithHexString:params[@"protocol_highlight_color"]]];
    }
    [uiModel setPrivacyUncheckAnimation:true];
    /**web协议界面*/
    if ([params objectForKey:@"view_background_color"]) {
        [uiModel setWebNavColor:[self colorWithHexString:params[@"view_background_color"]]];
    }
    UIColor *webNavColor = [UIColor blackColor];
    double webNavFontSize = 16.0;
    if ([params objectForKey:@"view_text_color"]) {
        webNavColor = [self colorWithHexString:params[@"view_text_color"]];
    }
    if ([params objectForKey:@"view_text_size"]) {
        webNavFontSize = [params[@"view_text_size"] doubleValue];
    }
    [uiModel setWebNavTitleAttrs:@{NSForegroundColorAttributeName:webNavColor,NSFontAttributeName:[UIFont systemFontOfSize:webNavFontSize]}];
    if ([params objectForKey:@"view_back_icon"]) {
        [uiModel setWebNavReturnImg:params[@"view_back_icon"]];
    }
    
    [TXLoginOauthSDK loginWithController:[UIApplication sharedApplication].keyWindow.rootViewController andUIModel:uiModel successBlock:^(NSDictionary * _Nonnull resultDic) {
        if ([resultDic[@"loginResultCode"] isEqualToString:@"200087"]) {
            //此处无需操作,如果需要登录授权页面背景播放视频，则可以在此处调用play方法
            NSLog(@"拉起授权登录页成功");
        }else{
            NSDictionary *simInfo = [TXLoginOauthSDK getSimInfo];
            [self sendEventWithName:@"TxAuthSdk" body:@{
                @"type": @"TokenSuccess",
                @"token": resultDic[@"token"] ? resultDic[@"token"] : @"",
                @"carrier": simInfo[@"carrier"] ? simInfo[@"carrier"] : 0,
            }];
            [self closeModel];
        }
    } failBlock:^(id  _Nonnull error) {
        [self sendEventWithName:@"TxAuthSdk" body:@{
            @"type": @"TokenFailure",
            @"error": [self stringWithError:error]
        }];
    }];
}

- (void)backClick:(UIButton *)sender{
    [self sendEventWithName:@"TxAuthSdk" body:@{
        @"type": @"BackPressed",
    }];
    [self closeModel];
}

-(void)touchOtherLogin:(UITapGestureRecognizer *)rec{
    [self sendEventWithName:@"TxAuthSdk" body:@{
        @"type": @"OtherLogin",
    }];
    [self closeModel];
}

-(void)closeModel {
    [TXLoginOauthSDK delectScrip];
    [TXLoginOauthSDK dismissViewControllerAnimated:true completion:^{
        
    }];
}

-(UIColor *)colorWithHexString:(NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
 
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
