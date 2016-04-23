dep 'emacs.bin'

dep 'spacemacs' do
  requires 'emacs.bin'
  requires 'git.bin'

  meet { shell 'git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d' }
  met? { '~/.emacs.d'.p.exists? }
end
   
