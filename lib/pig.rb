require 'git'

WORKING_DIR = File.join(File.dirname(File.expand_path(__FILE__)), "..")
NUMBER_OF_COMMITS = 10

class Pig

  attr_accessor :format

  def initialize options
    @format = options[:format]
  end

  def history
    results = ""
    commits = repository.log(NUMBER_OF_COMMITS) || []
    commits.each do |commit|
      results << format_commit(commit)
    end
    wrap(results)
  end

  def call env
    rack_response_template << [history]
  end

  def rack_response_template
    [200, {"Content-Type" => "text/#{@format}"}]
  end

  private

  def format_commit msg
    case format
    when :plain
      format_plain msg
    when :html
      format_html msg
    end
  end

  def repository
    Git.open root_dir
  end

  def root_dir
    if defined? Rails
      Rails.root
    else
      WORKING_DIR
    end
  end

  def wrap commits
    case format
    when :html
      "<html><head><title>Latest Commits</title></head><body><ul>#{commits}</ul></body></html>"
    else
      commits
    end
  end

  def format_plain commit
    "#{commit.message}\n  #{commit.to_s}\n  #{commit.author.date.strftime("%Y-%m-%d")} #{commit.author.name}\n\n"
  end

  def format_html commit
    "<li><h3>#{commit.message}</h3><br />#{commit.to_s}<br />#{commit.author.date.strftime("%Y-%m-%d")} #{commit.author.name}<br /><br /></li>"
  end

end
