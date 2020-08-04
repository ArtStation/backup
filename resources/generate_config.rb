actions :setup, :remove

# Password to encrypt all backups with
attribute :encryption_password, :kind_of => String, :default => nil
# Path where backup and it's configuration files and models reside
attribute :base_dir, :kind_of => String, :default => "/opt/backup"
# Cookbook that has the erb template specified in the source to generate config.rb
attribute :cookbook, :kind_of => String, :default => "backup"
# Filename of the erb template that generates config.rb
attribute :source, :kind_of => String, :default => "config.rb.erb"
# Where temporary files can be created
attribute :tmp_path, :kind_of => String, :default => "/tmp"
# Where the storage cycler data is stored
attribute :data_path, :kind_of => String, :default => "/opt/backup/.data"

attribute :major_version, :kind_of => String, :default => nil

def initialize(*args)
  super
  @action = :setup
  @major_version ||= major_backup_version
end

def major_backup_version
  backup_version = shell_out!("/usr/local/bin/backup version").stdout.chomp
  version = backup_version.match(/Backup (?<major>\d)/)

  return unless version
  version[:major]
end
