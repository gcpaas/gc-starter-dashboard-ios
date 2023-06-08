
#GitHub开源库
source 'https://cdn.cocoapods.org/'

use_frameworks!

# 屏蔽主工程和库有重复库的警告
install!'cocoapods',:deterministic_uuids=>false

platform :ios, '13.0'

post_install do |installer|

    installer.pods_project.targets.each do |target|

        target.build_configurations.each do |config|

            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""

            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"

            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'

        end

    end

end

target 'ChuangDa' do
  pod 'SGQRCode'
  pod 'ReactiveObjC'
  pod 'SDWebImage'
  pod 'SVProgressHUD'
  pod 'Masonry'
  pod 'FMDB'
  
  pod 'IFMMenu'
  pod 'YCXMenu'
  
  pod 'SSHelpTools', :git => 'https://github.com/songzhibing/SSHelpTools.git', :branch => 'develop', :commit => 'ae3d969'
end



