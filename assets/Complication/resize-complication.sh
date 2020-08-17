# Takes a 1024x1024 png file named AppIcon.png as input.
# Outputs all required sizes for Xcode's AppIcon asset.
#
# Usage:
# 1. Get a 1024x1024 pixel .png file as input
# 2. Rename the input file to AppIcon.png
# 3. Execute this script in same directory as AppIcon.png
#    % sh ./xcode-appicon-all-sizes.sh
# 4. Drag the outputted image files into Xcode

cp AppIcon.png AppIcon1024px.png
# No need to resize AppIcon1024px.png
cp AppIcon.png AppIcon32px.png
sips -Z 32 AppIcon32px.png

cp AppIcon.png AppIcon36px.png
sips -Z 36 AppIcon36px.png

cp AppIcon.png AppIcon40px.png
sips -Z 40 AppIcon40px.png

cp AppIcon.png AppIcon182px.png
sips -Z 182 AppIcon182px.png

cp AppIcon.png AppIcon203px.png
sips -Z 203 AppIcon203px.png

cp AppIcon.png AppIcon224px.png
sips -Z 224 AppIcon224px.png

cp AppIcon.png AppIcon84px.png
sips -Z 84 AppIcon84px.png

cp AppIcon.png AppIcon94px.png
sips -Z 94 AppIcon94px.png

cp AppIcon.png AppIcon44px.png
sips -Z 44 AppIcon44px.png

cp AppIcon.png AppIcon206px.png
sips -Z 206 AppIcon206px.png

cp AppIcon.png AppIcon240px.png
sips -Z 240 AppIcon240px.png

cp AppIcon.png AppIcon264px.png
sips -Z 264 AppIcon264px.png

cp AppIcon.png AppIcon52px.png
sips -Z 52 AppIcon52px.png

cp AppIcon.png AppIcon58px.png
sips -Z 58 AppIcon58px.png

cp AppIcon.png AppIcon64px.png
sips -Z 64 AppIcon64px.png

cp AppIcon.png AppIcon50px.png
sips -Z 50 AppIcon50px.png
