require 'sinatra'
require 'pivotal-tracker'

class PivotedConfig
  def self.username
    ENV['USERNAME'] || raise("You must set a username env var")
  end
  def self.password
    ENV['PASSWORD'] || raise("You must set a password env var")
  end
  def self.project
    ENV['PROJECT'] || raise("You must set a project env var")
  end
  def self.label
    ENV['LABEL'] || raise("You must set a filtering label")
  end
end

helpers do
  def story_meta(story)
    meta = [story.story_type]
    if story.story_type == 'feature'
      if story.estimate > 0
        meta << story.estimate
      else
        meta << "unestimated"
      end
    end
    meta << story.current_state
    meta
  end
end

get '/' do
  PivotalTracker::Client.token(PivotedConfig.username, PivotedConfig.password)
  project = PivotalTracker::Project.find(PivotedConfig.project)
  stories = project.stories.all(:label => PivotedConfig.label)
  erb :index, locals: { project: project, stories: stories }
end
