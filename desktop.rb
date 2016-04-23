dep 'i3.managed' do
  installs 'i3', 'j4-dmenu-desktop'
  provides 'i3', 'i3status', 'i3lock', 'j4-dmenu-desktop'
end

dep 'lightdm.bin'
dep 'chromium-browser.bin'

dep 'desktop' do
  requires 'i3.managed'
  requires 'lightdm.bin'
  requires 'chromium-browser.bin'
end
