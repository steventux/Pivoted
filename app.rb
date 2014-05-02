require 'sinatra'
require 'pivotal-tracker'

helpers do
  def from_env(key)
    ENV[key] || raise("You must set the #{key} environment variable")
  end

  def weekly_data(headings, stories, start_date, end_date, terms = nil)
    data = [headings]
    (start_date..end_date).each_slice(7) do |week|
      key = week.first.strftime("%d/%m/%Y")
      weekly_stories = [key]
      stories_this_week = stories.select do |s|
        s.created_at >= week.first and s.created_at <= week.last
      end
      weekly_stories << stories_this_week.size

      if terms
        terms.each do |term|
          terms_ary = []
          re = Regexp.new(term, 'i')
          terms_ary << stories_this_week.select do |s|
            s.name =~ re or s.description =~ re
          end.size
          weekly_stories << terms_ary
        end
      end
      data << weekly_stories.flatten
    end
    data
  end

  def query_terms(query)
    query.split(",").map(&:strip)
  end
end

get '/' do
  PivotalTracker::Client.token(from_env('USERNAME'), from_env('PASSWORD'))
  project = PivotalTracker::Project.find(params[:project] || from_env('PROJECT'))
  story_filter = { :includedone => true }
  story_filter[:label] = params[:label] if params[:label]

  stories = project.stories.all(story_filter)

  start_date = Date.parse(params[:start_date])
  end_date = Date.parse(params[:end_date])

  headings = ["Week starting", "Total stories (for label)"]
  if params[:query]
    terms = query_terms(params[:query])
    headings += terms
  else
    terms = nil
  end

  data_array = weekly_data(headings, stories, start_date, end_date, terms)

  erb :index, locals: {
    project: project,
    data_array: data_array
  }
end

get '/healthcheck' do
  'OK'
end
