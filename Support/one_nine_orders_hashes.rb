require 'yaml'
require 'i18n/core_ext/hash'

class Hash
  def set(keys, value)
    key = keys.shift
    if keys.empty?
      self[key] = value
    else
      self[key] ||= {}
      self[key].set keys, value
    end
  end unless Hash.method_defined?(:set)
end

class YamlWriter
  attr_accessor :filename, :locale
  
  def initialize(filename)
    if md = filename.match(/.*?\/([-A-Za-z]+)\.yml$/)
      self.locale = md[1]
    end
    self.filename = filename
  end
  
  def []=(key, text)
    keys = [locale] + key.split('.')
    data = { locale => {} }
    data.set(keys.dup, text)
    if File.exists?(filename)
      file_content = File.open(filename, 'r') { |f| f.read }
      data = YAML.load(file_content).deep_merge!(data) if file_content
      File.open(filename, 'w+') { |f| f.write YAML.dump(data) }
    end
  end
end


filename, key, translated = ARGV
raise StandardError, "Must be 1.9" unless RUBY_VERSION =~ /^1\.9\.[0-9]+$/
raise ArgumentError, "Need to supply: filename key and translated text" unless filename && key && translated
YamlWriter.new(filename)[key] = translated
