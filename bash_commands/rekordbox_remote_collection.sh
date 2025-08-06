# configure symbolic links (/D) to T7 files
mklink /D D:\PIONEER_symbolic \\192.168.20.50\PIONEER
mklink /D "D:\DJ MUSIC_symbolic" "\\192.168.20.50\DJ MUSIC"

# create junction links to T7 files
mklink /J D:\PIONEER D:\PIONEER_symbolic
mklink /J "D:\DJ MUSIC" "D:\DJ MUSIC_symbolic"