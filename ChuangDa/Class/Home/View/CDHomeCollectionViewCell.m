//
//  CDHomeCollectionViewCell.m
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import "CDHomeCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import <SSHelpTools/SSHelpToolsConfig.h>
#import <SSHelpTools/SSHelpDefines.h>
@interface CDHomeCollectionViewCell()
@property(nonatomic, strong) CDHomeWebHistoryModel *dataModel;
@property(nonatomic, strong) UILabel *contentLab;
@property(nonatomic, strong) UIView *bottomLine;
@end

@implementation CDHomeCollectionViewCell

/// 复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.contentLab.text = @"";
}

- (void)refreshWithModel:(CDHomeWebHistoryModel *)model
{
    self.contentView.backgroundColor = _kColorFromHexRGB(@"#eeeff3");
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 4;
    //self.contentView.layer.borderWidth = 0.5f;
    //self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    
    //self.bottomLine.hidden = NO;
    self.contentLab.text = model.name;
}

#pragma mark -
#pragma mark - Lazy loading

- (UILabel *)contentLab
{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textAlignment = NSTextAlignmentLeft;
        _contentLab.numberOfLines = 0;
        [self.contentView addSubview:_contentLab];
        [_contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.right.mas_equalTo(-20);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
    }
    return _contentLab;
}

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        if (@available(iOS 13.0, *)) {
            _bottomLine.backgroundColor = [UIColor opaqueSeparatorColor];
        } else {
            _bottomLine.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        }
        [self.contentView addSubview:_bottomLine];
        [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.bottom.mas_equalTo(-0.5);
            make.height.mas_equalTo(1);
            make.right.mas_equalTo(-2);
        }];
    }
    return _bottomLine;
}

@end
