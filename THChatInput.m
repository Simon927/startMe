//
//  Created by Marat Alekperov (aka Timur Harleev) (m.alekperov@gmail.com) on 18.11.12.
//  Copyright (c) 2012 Me and Myself. All rights reserved.
//


#import "THChatInput.h"
#import "PostViewController.h"

@implementation THChatInput


- (void) composeView {
   
   CGSize size = self.frame.size;
   
   // Input
	_inputBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(-70+8, 0, size.width+70-8, size.height)]; //Change from origin (0, 0, size.width, size.height)
	_inputBackgroundView.autoresizingMask = UIViewAutoresizingNone;
   _inputBackgroundView.contentMode = UIViewContentModeScaleToFill;
	//_inputBackgroundView.userInteractionEnabled = YES;
   //_inputBackgroundView.alpha = .5;
   _inputBackgroundView.backgroundColor = [UIColor clearColor];
   //_inputBackgroundView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
	[self addSubview:_inputBackgroundView];
   [_inputBackgroundView release];
   
	// Text field
	_textView = [[UITextView alloc] initWithFrame:CGRectMake(8.0f, -6.0f, 185+62.0, 0)]; //Change ORIGIN.X from 70.0 to 8.0 and width +62
   _textView.backgroundColor = [UIColor clearColor];
   //_textView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.3];
	_textView.delegate = self;
   _textView.contentInset = UIEdgeInsetsMake(-4, -2, -4, 0);
   _textView.showsVerticalScrollIndicator = NO;
   _textView.showsHorizontalScrollIndicator = NO;
	_textView.font = [UIFont systemFontOfSize:15.0f];
	[self addSubview:_textView];
   [_textView release];
   
   [self adjustTextInputHeightForText:@"" animated:NO];
   
   _lblPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 14, 160+62, 20)]; //Change ORIGIN.X from 78.0 to 16.0
   _lblPlaceholder.font = [UIFont systemFontOfSize:15.0f];
   _lblPlaceholder.text = NSLocalizedString(@"lblComment", nil);
   _lblPlaceholder.textColor = [UIColor lightGrayColor];
   _lblPlaceholder.backgroundColor = [UIColor clearColor];
    [self addSubview:_lblPlaceholder];
   [_lblPlaceholder release];
   
	// Attach buttons
	_attachButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_attachButton.frame = CGRectMake(6.0f, 12.0f, 26.0f, 27.0f);
	_attachButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
   [_attachButton addTarget:self action:@selector(showAttachInput:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_attachButton];
   [_attachButton release];
	
	_emojiButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_emojiButton.frame = CGRectMake(12.0f + _attachButton.frame.size.width, 12.0f, 26.0f, 27.0f);
	_emojiButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
   [_emojiButton addTarget:self action:@selector(showEmojiInput:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_emojiButton];
   [_emojiButton release];
	
	// Send button
	_sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_sendButton.frame = CGRectMake(size.width - 64.0f+5.0f, 12.0f-7.0f, 58.0f-7.0f, 27.0f+3.0f);
	_sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	_sendButton.titleLabel.font = [UIFont fontWithName:APP_FONT size:14];
	_sendButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
   //	[_sendButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.4f] forState:UIControlStateNormal];
   //	[_sendButton setTitleShadowColor:[UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f] forState:UIControlStateNormal];
	[_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	//[_sendButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_sendButton];
   [_sendButton release];
   
    [_emojiButton setHidden:YES];
    [_attachButton setHidden:YES];
    
   [self sendSubviewToBack:_inputBackgroundView];
}

- (void) awakeFromNib {
   
   _inputHeight = 38.0f;
   _inputHeightWithShadow = 44.0f;
   _autoResizeOnKeyboardVisibilityChanged = YES;

   [self composeView];
}

- (void) adjustTextInputHeightForText:(NSString*)text animated:(BOOL)animated {
   
   if([text isEqualToString:@""]) text = @" ";
    
   int h1 = [text sizeWithFont:_textView.font].height;
   int h2 = [text sizeWithFont:_textView.font constrainedToSize:CGSizeMake(_textView.frame.size.width - 16, 170.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
   
   [UIView animateWithDuration:(animated ? .1f : 0) animations:^
    {
       int h = h2 == h1 ? _inputHeightWithShadow : h2 + 24;
       int delta = h - self.frame.size.height;
       CGRect r2 = CGRectMake(0, self.frame.origin.y - delta, self.frame.size.width, h);
       self.frame = r2; //CGRectMake(0, self.frame.origin.y - delta, self.superview.frame.size.width, h);
       _inputBackgroundView.frame = CGRectMake(-70+8, 0, self.frame.size.width+70-8, h); //Change from (0,0,self.frame.size.width,h)
       

       CGRect r = _textView.frame;
       r.origin.y = 12;
       r.size.height = h - 18;
       _textView.frame = r;

       
       PostViewController *pc = (PostViewController*)self.delegate;
       CGRect rect = pc.tableList.frame;
       rect.size.height -= delta;
       [pc.tableList setFrame:rect];
        
       rect.origin.y = 0;
       rect.size.height -= 82.0;
       [pc.tbHashtag setFrame:rect];
        
    } completion:^(BOOL finished)
    {
       //
    }];
}

- (id) initWithFrame:(CGRect)frame {
   
   self = [super initWithFrame:frame];
   
   if (self)
   {
      _inputHeight = 38.0f;
      _inputHeightWithShadow = 44.0f;
      _autoResizeOnKeyboardVisibilityChanged = YES;
      
      [self composeView];
   }
   return self;
}

- (void) fitText {
   
   [self adjustTextInputHeightForText:_textView.text animated:YES];
}

- (void) setText:(NSString*)text {
   
   _textView.text = text;
   _lblPlaceholder.hidden = text.length > 0;
   [self fitText];
}


#pragma mark UITextFieldDelegate Delegate

- (void) textViewDidBeginEditing:(UITextView*)textView {
   
   if (_autoResizeOnKeyboardVisibilityChanged)
   {
      [UIView animateWithDuration:.25f animations:^{
         CGRect r = self.frame;
         r.origin.y -= 216-50;
         [self setFrame:r];
          
          PostViewController *pc = (PostViewController*)self.delegate;
          //[pc.scrollView setContentOffset:CGPointMake(0, 216-44+r.size.height) animated:YES];
          
          CGRect rect = pc.tableList.frame;
          rect.size.height -= 216-50;
          [pc.tableList setFrame:rect];
          
          rect.origin.y = 0;
          rect.size.height -= 82.0;
          [pc.tbHashtag setFrame:rect];
      }];
      [self fitText];
   }
   if ([_delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
      [_delegate performSelector:@selector(textViewDidBeginEditing:) withObject:textView];
}

- (void) textViewDidEndEditing:(UITextView*)textView {
   
   if (_autoResizeOnKeyboardVisibilityChanged)
   {
      [UIView animateWithDuration:.25f animations:^{
         CGRect r = self.frame;
         r.origin.y += 216-50;
         [self setFrame:r];
          
         PostViewController *pc = (PostViewController*)self.delegate;
         //[pc.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
          
          CGRect rect = pc.tableList.frame;
          rect.size.height += 216-50;
          [pc.tableList setFrame:rect];
          
          rect.origin.y = 0;
          rect.size.height -= 82.0;
          [pc.tbHashtag setFrame:rect];
      }];
      
      [self fitText];
   }
    
    
   _lblPlaceholder.hidden = _textView.text.length > 0;
   
     
   if ([_delegate respondsToSelector:@selector(textViewDidEndEditing:)])
      [_delegate performSelector:@selector(textViewDidEndEditing:) withObject:textView];
}

- (BOOL) textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
   
    /*
   if ([text isEqualToString:@"\n"])
   {
      if ([_delegate respondsToSelector:@selector(returnButtonPressed:)])
         [_delegate performSelector:@selector(returnButtonPressed:) withObject:_textView afterDelay:.1];
      return NO;
   }
   else
     */
   if (text.length > 0)
   {
      [self adjustTextInputHeightForText:[NSString stringWithFormat:@"%@%@", _textView.text, text] animated:YES];
   }
   return YES;
}

- (void) textViewDidChange:(UITextView*)textView {
   
    _lblPlaceholder.hidden = textView.text.length > 0;
    
    //NSLog(@"%d",textView.text.length);
    
    if(textView.text.length > COMMENT_MAX_LENGHT) {
        [textView setText:[textView.text substringToIndex:COMMENT_MAX_LENGHT]];
    }
   
   [self fitText];
   
   if ([_delegate respondsToSelector:@selector(textViewDidChange:)])
      [_delegate performSelector:@selector(textViewDidChange:) withObject:textView];
}


#pragma mark THChatInput Delegate

- (void) sendButtonPressed:(id)sender {
   
   if ([_delegate respondsToSelector:@selector(sendButtonPressed:)])
      [_delegate performSelector:@selector(sendButtonPressed:) withObject:sender];
}

- (void) showAttachInput:(id)sender {
   
   if ([_delegate respondsToSelector:@selector(showAttachInput:)])
      [_delegate performSelector:@selector(showAttachInput:) withObject:sender];
}

- (void) showEmojiInput:(id)sender {
   
   if ([_delegate respondsToSelector:@selector(showEmojiInput:)])
   {
      if ([_textView isFirstResponder] == NO) [_textView becomeFirstResponder];

      [_delegate performSelector:@selector(showEmojiInput:) withObject:sender];
   }
}

@end
