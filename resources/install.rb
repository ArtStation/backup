class Chef::Provider::Package::Rubygems
  class AlternateGemEnvironment
    def rubygems_version
      @rubygems_version ||= shell_out!("#{@gem_binary_location} --version").stdout.chomp
    end
  end

  def install_via_gem_command(name, version)
    src = []
    if new_resource.source.is_a?(String) && new_resource.source =~ /\.gem$/i
      name = new_resource.source
    else
      src << "--clear-sources" if new_resource.clear_sources
      src += gem_sources.map { |s| "--source=#{s}" }
    end
    src_str = src.empty? ? "" : " #{src.join(" ")}"
    if !version.nil? && !version.empty?
      shell_out!("#{gem_binary_path} install #{name} -q #{rdoc_string} -v \"#{version}\"#{src_str}#{opts}", env: nil)
    else
      shell_out!("#{gem_binary_path} install \"#{name}\" -q #{rdoc_string} #{src_str}#{opts}", env: nil)
    end
  end
  private

  def rdoc_string
    if needs_nodocument?
      "--no-document"
    else
      "--no-rdoc --no-ri"
    end
  end

  def needs_nodocument?
    Gem::Requirement.new(">= 3.0.0.beta1").satisfied_by?(Gem::Version.new(gem_env.rubygems_version))
  end
end

actions :install, :remove

# Version of the backup gem to install
attribute :version, :kind_of => String, :default => "4.4.0"
attribute :gem_binary, :kind_of => String, :default => "/usr/bin/gem"

def initialize(*args)
  super
  @run_context.include_recipe ["build-essential","cron"]
  @action = :install
end
