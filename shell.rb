dep 'ppa', :spec do
  requires 'python-software-properties.bin'
  def spec_name
    log_error("'#{spec}' doesn't look like 'ppa:something'.") unless spec[/^ppa\:\w+/]
    spec.to_s.sub(/^ppa\:/, '')
  end
  def ppa_release_file
    # This may be hardcoded to some extent, but I'm calling YAGNI on it for now.
    "ppa.launchpad.net_#{spec_name.gsub('/', '_')}_ubuntu_dists_#{Babushka.host.codename}_InRelease"
  end
  met? {
    ('/var/lib/apt/lists/' / ppa_release_file).exists?
  }
  meet {
    log_shell "Adding #{spec}", "add-apt-repository '#{spec}'", :spinner => true, :sudo => true
    log_shell "Updating apt lists to load #{spec}.", "apt-get update", :sudo => true
  }
end

dep 'fish.bin' do
  requires 'ppa'.with('ppa:fish-shell/release-2')
end

# Ensures a particular shell is setup in /etc/shells
#
#   * shell_path: The full path to a shell to use (optional, will be
#                 determined using shell_name if omitted)
dep 'shell in database', :shell_path do
  met? { '/etc/shells'.p.grep(shell_path) }
  meet {
    require 'shellwords'
    log "Adding '#{shell_path}' to the shell database..."
    shell! "echo #{shell_path} >> /etc/shells", :sudo => true
  }
end

# Sets the shell to use for a particular user
#
#   * username:   Determines which user's shell should be changed
#                 (optional, defaults to the current user)
#   * shell_name: Path to the binary to use for their shell
dep 'set shell', :username, :shell_name do
  username.default! current_username

  # Finds the full path of the shell specified in "shell"
  def shell_path
    value = shell_name.to_s

    if value.match(/^\//)
      # Absolute path already provided (starts with "/")
      value.p
    else
      # Shell name provided, use "which" to find the executable
      which(value).p
    end
  end

  setup {
    require 'shellwords'
    requires 'shell in database'.with(shell_path)
  }

  met? {
    command = "su - #{Shellwords.escape(username)} -c 'echo $SHELL'"
    puts shell_path
    shell!(command, sudo: true).strip == shell_path
  }

  meet {
    shell! "chsh #{Shellwords.escape(username)} -s #{Shellwords.escape(shell_path)}", sudo: true
  }
end

dep 'shell' do
  requires 'fish.bin'
  requires 'set shell'.with(shell_name: 'fish')
  requires 'dotfiles'
end
