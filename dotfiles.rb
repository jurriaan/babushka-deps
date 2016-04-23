require 'tmpdir'
require 'digest'

dep 'rcup.bin' do
  meet do
    Dir.mktmpdir do |dir| 
      file = File.join(dir, 'rcm.deb')
      shell "wget https://thoughtbot.github.io/rcm/debs/rcm_1.3.0-1_all.deb -O #{file}"
      shasum = Digest::SHA256.file file

      if shasum.hexdigest == '2e95bbc23da4a0b995ec4757e0920197f4c92357214a65fedaf24274cda6806d'
        shell "sudo dpkg -i #{file}"
      end
    end
  end
end

dep 'dotfiles' do
  requires 'rcup.bin'

  dotfiles_dir = File.expand_path '~/.dotfiles'
  dotfiles_repo = 'git@github.com:jurriaan/dotfiles.git'

  dotfile_dirs = Dir[File.join(dotfiles_dir, '*')].each.select { |d| File.directory?(d) }

  rcup_command = ['rcup', *(['-d'] * dotfile_dirs.count).zip(dotfile_dirs).flatten]

  meet do
    dotfiles_dir.p.exists? or shell(['git', 'clone', dotfiles_repo, dotfiles_dir].shelljoin)

    shell(rcup_command.shelljoin)
  end

  def dotfiles_up_to_date?(rcup_command)
    data = `#{[*rcup_command, '-g'].shelljoin}`
    checks = data.scan(/^handle_file_(..) "(.*)" "(.*)"$/)
    checks.all? do |method, source, target| 
      if method == 'ln'
        File.symlink?(target) && File.readlink(target) == source
      elsif method == 'cp'
        File.file?(target) && Digest::SHA256.file(target) == Digest::SHA256.file(source)
      else
        false
      end
    end
  end

  met? { dotfiles_dir.p.exists? && dotfiles_up_to_date?(rcup_command) }
end
