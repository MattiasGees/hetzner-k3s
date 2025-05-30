require "yaml"
require "file"
require "crest"

module K3s
  GITHUB_DELIM_LINKS = ","
  GITHUB_LINK_REGEX = /<(?<link>[^>]+)>; rel="(?<rel>[^"]+)"/
  RELEASES_DIRECTORY = File.expand_path("#{ENV["HOME"]}/.hetzner-k3s")
  RELEASES_FILENAME =  File.expand_path("#{ENV["HOME"]}/.hetzner-k3s/k3s-releases.yaml")

  def self.available_releases
    Dir.mkdir(RELEASES_DIRECTORY) unless File.directory?(RELEASES_DIRECTORY)

    if File.exists?(RELEASES_FILENAME)
      if (Time.utc - File.info(RELEASES_FILENAME).modification_time) > 7.days
        File.delete(RELEASES_FILENAME)
      else
        return YAML.parse(File.read(RELEASES_FILENAME)).as_a
      end
    end

    releases = fetch_all_releases_from_github
    File.open(RELEASES_FILENAME, "w") { |f| YAML.dump(releases, f) }
    releases
  end

  private def self.fetch_all_releases_from_github : Array(String)
    releases = [] of String
    next_page_url = "https://api.github.com/repos/k3s-io/k3s/tags?per_page=100"

    while next_page_url
      response = Crest.get(next_page_url, json: true)
      releases.concat(JSON.parse(response.body).as_a.map { |release| release["name"].as_s })

      next_page_url = extract_next_github_page_url(response.headers["Link"]?)
    end

    releases.reverse
  end

  private def self.extract_next_github_page_url(link_header : (Array(String) | String | Nil)) : String?
    return nil unless link_header

    link_header = link_header.is_a?(Array) ? link_header.join(",") : link_header

    links = link_header.split(GITHUB_DELIM_LINKS, remove_empty: true)

    links.each do |link|
      captures = GITHUB_LINK_REGEX.match(link.strip).try &.named_captures
      return captures["link"] if captures && captures["rel"]? == "next"
    end

    nil
  end
end
