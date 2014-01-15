require 'sinatra'
require 'pivotal-tracker'

helpers do
  def from_env(key)
    ENV[key] || raise("You must set the #{key} environment variable")
  end
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
  PivotalTracker::Client.token(from_env('USERNAME'), from_env('PASSWORD'))
  project = PivotalTracker::Project.find(from_env('PROJECT'))
  stories = project.stories.all(:label => from_env('LABEL'))
  erb :index, locals: { project: project, stories: stories }
end
