class TravisProProject < TravisProject
  BASE_API_URL = "https://api.travis-ci.com"

  validates_presence_of :travis_pro_token, unless: ->(project) { project.webhooks_enabled }

  def self.project_specific_attributes
    # parent class rejects columns that start with travis_pro_
    columns.map(&:name).grep(/^travis_/)
  end

  # Add ?token= or &token= to the feed_url, as appropriate
  def feed_url
    URI.parse(super).tap do |uri|
      params = URI.decode_www_form(uri.query || []) << ['token', travis_pro_token]
      uri.query = URI.encode_www_form(params)
    end.to_s
  end
end