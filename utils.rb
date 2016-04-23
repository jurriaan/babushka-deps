dep 'htop.bin'
dep 'tmux.bin'
dep 'gpg.bin' do
  installs 'gnupg'
end
dep 'pinentry-gnome3.bin'
dep 'ag.bin' do
  installs 'silversearcher-ag'
end

dep 'utils' do
  requires 'htop.bin', 'ag.bin', 'tmux.bin', 'gpg.bin', 'pinentry-gnome3.bin'
end
