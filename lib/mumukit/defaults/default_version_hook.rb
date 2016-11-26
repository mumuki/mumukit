class Mumukit::Defaults::VersionHook
  VERSION = File.read('version') rescue 'master'
end
