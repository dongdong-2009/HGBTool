//
//  ViewController.m
//  fe
//
//  Created by iOS_Onion on 16/10/18.
//  Copyright © 2016年 iOS_Onion. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UIWebViewDelegate>
@property (nonatomic,retain)NSMutableData *userData;
@property (nonatomic,retain)UIWebView *webView;
@property (nonatomic,retain)NSURLRequest *originRequest;
@property (nonatomic,assign)BOOL isAuto;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _isAuto = NO;
    
//    [self getDataWithuURLRequest];
    
    [self getWithWebView];
    
}

- (void)getWithWebView
{
    _webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    NSURL *url = [NSURL URLWithString:@"https://kyfw.12306.cn/otn/"];
    _originRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:_originRequest];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *scheme = [[request URL]scheme];
    NSLog(@"scheme:%@",scheme);
    if ([scheme isEqualToString:@"https"] && !_isAuto)
    {
        _originRequest = request;
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:_originRequest delegate:self];
        [conn start];
        [_webView stopLoading];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError");
}

- (void)getDataWithuURLRequest{
    NSString *urlStr = @"https://kyfw.12306.cn/otn/";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark NSURLConnectionDelegate
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //表示是否对CA文件进行校验，YES就会调用didReceiveAuthenticationChallenge进行校验，NO:就是不进行校验
    NSString *authenticationMethodStr = protectionSpace.authenticationMethod;
    BOOL isServerTrust = [authenticationMethodStr isEqualToString:NSURLAuthenticationMethodServerTrust];
    
    return isServerTrust;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    //对CA文件进行验证，并建立信任连接
    NSString *serverTrust = [[challenge protectionSpace] authenticationMethod];
    if ([serverTrust isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        //导入CA证书
        SecTrustRef serverTrust = [[challenge protectionSpace]serverTrust];
        NSString *cerPath = [[NSBundle mainBundle]pathForResource:@"srca" ofType:@"cer"];
        NSData *caCert = [NSData dataWithContentsOfFile:cerPath];
        if (nil == caCert)
        {
            return;
        }
        SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
        if (nil == caRef)
        {
            return;
        }
        NSArray *caArray = @[(__bridge id)caRef];
        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
        if(!(errSecSuccess == status))
        {
            return;
        }
        SecTrustResultType result = -1;
        status = SecTrustEvaluate(serverTrust, &result);
        if (!(errSecSuccess == status))
        {
            return;
        }
        /**
         这里的关键在于result参数的值，根据官方文档的说明，判断(result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed)的值，若为1，则该网站的CA被app信任成功，可以建立数据连接，这意味着所有由该CA签发的各个服务器证书都被信任，而访问其它没有被信任的任何网站都会连接失败。该CA文件既可以是SLL也可以是自签名。
         */
        BOOL allowConnect = (result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed);
        if (allowConnect)
        {
            NSLog(@"success");
            //发送凭证给服务器
            [[challenge sender]useCredential:[NSURLCredential credentialForTrust:serverTrust] forAuthenticationChallenge:challenge];
        }else
        {
            NSLog(@"error");
        }
    }
}

//willSendRequestForAuthenticationChallenge调用后无法调用didReceiveAuthenticationChallenge，canAuthenticateAgainstProtectionSpace
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (![challenge.protectionSpace.host isEqualToString:@"kyfw.12306.cn"] || ![challenge.protectionSpace.protocol isEqualToString:NSURLProtectionSpaceHTTPS])
    {
        NSLog(@"we unable to establish a secure connection.Please check your network conection and try again");
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }else
    {
        //1.获取trust object
        SecTrustRef serverTrust = [[challenge protectionSpace]serverTrust];
        //2.导入信任证书
        NSString *cerPath = [[NSBundle mainBundle]pathForResource:@"srca" ofType:@"cer"];
        NSData *caCert = [NSData dataWithContentsOfFile:cerPath];
        if (nil == caCert)
        {
            return;
        }
        
        SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
        if (nil == caRef)
        {
            return;
        }
        NSArray *caArray = @[(__bridge id)caRef];
        //3.将之前导入的证书设置成下面验证的Trust object的anchor certificate(根证书)
        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
        if(!(errSecSuccess == status))
        {
            return;
        }
        SecTrustResultType result = -1;
        /**
         4.SecTrustEvaluate会查找前面SecTrustSetAnchorCertificates设置的证书
         或者系统默认提供的证书，对serverTrust进行验证
         */
        status = SecTrustEvaluate(serverTrust, &result);
        if (errSecSuccess == status && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified))
        {
            //5.验证成功，生成NSURLCredential凭证cred,告知challenge的sender使用这个凭证来继续连接
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:serverTrust] forAuthenticationChallenge:challenge];
        }else
        {
            //6.验证失败，取消这次验证流程
            [challenge.sender cancelAuthenticationChallenge:challenge];
            return;
        }

        
//        //要服务器端单项HTTPS验证，iOS客户端忽略证书验证。
//        SecTrustRef trust = [[challenge protectionSpace] serverTrust];
//        
//        NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:trust];
//        
//        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"didCancelAuthenticationChallenge");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReciveResponse");
    _userData = [[NSMutableData alloc]init];
    //webView
    [_webView loadRequest:_originRequest];
    [connection cancel];
    _isAuto = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [_userData appendData:data];;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveInfo = [NSJSONSerialization JSONObjectWithData:_userData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"receiveInfo:%@",receiveInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
