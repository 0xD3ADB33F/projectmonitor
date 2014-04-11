class TravisProject < Project

  validates_presence_of :travis_github_account, :travis_repository, unless: ->(project) { project.webhooks_enabled }

  BASE_API_URL = "https://api.travis-ci.org"

  def build_status_url
    feed_url
  end

  def feed_url
    "#{base_url}/builds.json"
  end

  def has_status?(status)
    statuses.where(build_id: status.build_id, success: status.success).exists?
  end

  def project_name
    travis_github_account
  end

  def fetch_payload
    TravisJsonPayload.new.tap do |payload|
      payload.slug = slug
      payload.branch = build_branch
    end
  end

  def webhook_payload
    TravisJsonPayload.new.tap do |payload|
      payload.slug = slug
      payload.branch = build_branch
    end
  end

  def requires_branch_name?
    true
  end

  def slug
    "#{travis_github_account}/#{travis_repository}"
  end

  private

  def base_url
    "#{BASE_API_URL}/repositories/#{slug}"
  end
end
