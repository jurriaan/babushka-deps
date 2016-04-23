dep 'i3.managed' do
  installs 'i3', 'j4-dmenu-desktop'
  provides 'i3', 'i3status', 'i3lock', 'j4-dmenu-desktop'
end

dep 'fonts-hack-ttf.managed' do
  met? { '/usr/share/fonts/truetype/hack'.p.exists? }
end

dep 'gvfs-bin.managed' do
  provides 'gvfs-open'
end

dep 'slack.bin' do
  requires 'gvfs-bin.managed'

  meet do
    Dir.mktmpdir do |dir| 
      file = File.join(dir, 'slack.deb')
      shell "wget https://downloads.slack-edge.com/linux_releases/slack-desktop-2.0.3-amd64.deb -O #{file}"
      shasum = Digest::SHA256.file file

      if shasum.hexdigest == '8f8d4c7515463e7e8c68e9499f39a6e20fca759bcab059e0bd03d69978b0e85e'
        shell "sudo dpkg -i #{file}"
      end
    end
  end
end

dep 'lightdm.bin'
dep 'dunst.bin'
dep 'chromium-browser.bin'
dep 'gnome-settings-daemon.bin'

dep 'desktop' do
  requires 'i3.managed'
  requires 'lightdm.bin'
  requires 'chromium-browser.bin'
  requires 'gnome-settings-daemon.bin'
  requires 'dunst.bin'
  requires 'slack.bin'
  requires 'fonts-hack-ttf.managed'
end
