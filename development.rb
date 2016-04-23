dep 'gcc.bin' do
  installs 'build-essential'
end
dep 'make.bin' do
  installs 'build-essential'
end
dep 'automake.bin' do
  installs 'build-essential'
end

dep 'build-essential' do
  requires 'gcc.bin', 'make.bin', 'automake.bin'
end

dep 'chruby.src' do
  source 'https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz'
  configure { true }
  build { true }
  provides 'chruby-exec'
end

dep 'ruby-install.src' do
  source 'https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz'
  configure { true }
  build { true }
end

dep 'ruby.bin' do
  provides 'ruby ~> 2.3.0p0'
  meet do
    shell 'ruby-install ruby 2.3.0'
  end
  met? { "~/.rubies/ruby-2.3.0".p.exist? }
end

dep 'ruby' do
  requires 'chruby.src'
  requires 'ruby-install.src'

  requires 'ruby.bin'
end

dep 'postgresql.managed' do
  provides 'psql'
end

dep 'postgresql superuser exists', :role_name do
  role_name.default('postgres')

  def role_exists?(role_name)
    roles = shell %Q[psql postgres -c "select rolname from pg_roles WHERE rolname='#{role_name}'"]
    roles.to_s.include? role_name
  end

  met? {
    role_exists? role_name
  }

  meet {
    log "Adding #{role_name} user"
    shell? "sudo -u postgres createuser --superuser #{role_name}", log: true
    log "Adding #{role_name} database"
    shell? "sudo -u postgres createdb #{role_name}", log: true
  }
end

dep 'postgresql' do
  requires 'postgresql.managed', 'postgresql superuser exists'.with(shell('whoami'))
end

dep 'development' do
  requires 'desktop',
           'python',
           'shell',
           'utils',
           'spacemacs',
           'build-essential',
           'ruby',
           'postgresql'
end
