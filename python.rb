dep 'pyenv' do
  meet do
    shell 'git clone https://github.com/yyuu/pyenv.git ~/.pyenv'
  end

  met? do
    '~/.pyenv/bin/pyenv'.p.exists?
  end
end

dep 'install python', :version do
  requires 'pyenv'

  meet do
    log_shell "Installing python #{version}", "~/.pyenv/bin/pyenv install #{Shellwords.escape(version)}"
    shell '~/.pyenv/bin/pyenv rehash'
  end

  met? do
    File.join('~/.pyenv/versions', version, 'bin/python').p.exists?
  end
end

dep 'upgrade pip', :version do
  pip = File.expand_path(File.join('~/.pyenv/versions', version, 'bin/pip'))

  meet do
    shell([pip, 'install', '--upgrade', 'pip', 'setuptools'].shelljoin)
  end

  met? do
    outdated_pkgs_cmd = [pip, 'list', '--outdated'].shelljoin
    outdated_pkgs = `#{outdated_pkgs_cmd}`
    %w(pip setuptools).none? { |pkg| outdated_pkgs.include?(pkg) }
  end
end

dep 'python' do
  requires 'pyenv'

  %w(2.7.11 3.5.1).each do |version|
    requires 'install python'.with(version)
    requires 'upgrade pip'.with(version)
  end
end
