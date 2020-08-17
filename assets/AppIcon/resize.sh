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
cp AppIcon.png AppIcon40px.png
sips -Z 40 AppIcon40px.png
cp AppIcon.png AppIcon60px.png
sips -Z 60 AppIcon60px.png
cp AppIcon.png AppIcon58px.png
sips -Z 58 AppIcon58px.png
cp AppIcon.png AppIcon87px.png
sips -Z 87 AppIcon87px.png
cp AppIcon.png AppIcon80px.png
sips -Z 80 AppIcon80px.png
cp AppIcon.png AppIcon120px.png
sips -Z 120 AppIcon120px.png
cp AppIcon.png AppIcon180px.png
sips -Z 180 AppIcon180px.png
cp AppIcon.png AppIcon20px.png
sips -Z 20 AppIcon20px.png
cp AppIcon.png AppIcon29px.png
sips -Z 29 AppIcon29px.png
cp AppIcon.png AppIcon76px.png
sips -Z 76 AppIcon76px.png
cp AppIcon.png AppIcon152px.png
sips -Z 152 AppIcon152px.png
cp AppIcon.png AppIcon167px.png
sips -Z 167 AppIcon167px.png
cp AppIcon.png AppIcon48px.png
sips -Z 48 AppIcon48px.png
cp AppIcon.png AppIcon55px.png
sips -Z 55 AppIcon55px.png
cp AppIcon.png AppIcon88px.png
sips -Z 88 AppIcon88px.png
cp AppIcon.png AppIcon100px.png
sips -Z 100 AppIcon100px.png
cp AppIcon.png AppIcon172px.png
sips -Z 172 AppIcon172px.png
cp AppIcon.png AppIcon196px.png
sips -Z 196 AppIcon196px.png
cp AppIcon.png AppIcon216px.png
sips -Z 216 AppIcon216px.png