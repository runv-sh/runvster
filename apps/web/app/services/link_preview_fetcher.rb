require "cgi"
require "ipaddr"
require "net/http"
require "resolv"

class LinkPreviewFetcher
  MAX_REDIRECTS = 3
  REQUEST_TIMEOUT = 4
  PRIVATE_NETWORKS = %w[
    0.0.0.0/8
    10.0.0.0/8
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    ::1/128
    fc00::/7
    fe80::/10
  ].map { |value| IPAddr.new(value) }.freeze
  META_KEYS = %w[og:image:secure_url og:image:url og:image twitter:image].freeze

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url.to_s
  end

  def call
    uri = parse_public_uri(@url)
    return if uri.blank?

    final_uri, html = fetch_document(uri)
    return if final_uri.blank? || html.blank?

    thumbnail_url = extract_thumbnail_url(html, final_uri)
    return if thumbnail_url.blank?

    { thumbnail_url: }
  rescue StandardError => error
    Rails.logger.info("LinkPreviewFetcher failed for #{@url}: #{error.class}: #{error.message}")
    nil
  end

  private

  def fetch_document(uri, redirects = 0)
    return if redirects > MAX_REDIRECTS

    response = perform_request(uri)
    return if response.blank?

    case response
    when Net::HTTPSuccess
      content_type = response["content-type"].to_s.downcase
      return unless content_type.include?("text/html") || content_type.include?("application/xhtml")

      [uri, response.body.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")]
    when Net::HTTPRedirection
      location = response["location"].to_s
      redirected_uri = resolve_uri(location, uri, require_public_host: true)
      return if redirected_uri.blank?

      fetch_document(redirected_uri, redirects + 1)
    end
  end

  def perform_request(uri)
    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: REQUEST_TIMEOUT,
      read_timeout: REQUEST_TIMEOUT
    ) do |http|
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "RunvsterBot/1.0 (+https://runv.club)"
      request["Accept"] = "text/html,application/xhtml+xml"
      request["Accept-Encoding"] = "identity"
      http.request(request)
    end
  end

  def extract_thumbnail_url(html, page_uri)
    head = html.to_s[/<head\b.*?<\/head>/im] || html.to_s.first(150_000)
    meta_tags = head.scan(/<meta\b[^>]*>/im)
    link_tags = head.scan(/<link\b[^>]*>/im)

    candidate = META_KEYS.lazy.map do |key|
      meta_tags.find do |tag|
        attributes = extract_attributes(tag)
        [attributes["property"], attributes["name"]].compact.any? { |value| value.casecmp?(key) } &&
          attributes["content"].present?
      end
    end.find(&:present?)

    if candidate.present?
      absolute = resolve_uri(extract_attributes(candidate)["content"], page_uri)
      return absolute.to_s if absolute.present?
    end

    image_src = link_tags.find do |tag|
      attributes = extract_attributes(tag)
      rel_values = attributes["rel"].to_s.downcase.split
      rel_values.any? { |value| %w[image_src apple-touch-icon apple-touch-icon-precomposed icon shortcut].include?(value) } &&
        attributes["href"].present?
    end
    return if image_src.blank?

    absolute = resolve_uri(extract_attributes(image_src)["href"], page_uri)
    absolute&.to_s
  end

  def extract_attributes(tag)
    tag.to_s.scan(/([a-zA-Z_:][-a-zA-Z0-9_:.]*)\s*=\s*(?:\"([^\"]*)\"|'([^']*)'|([^\s"'=<>`]+))/m).each_with_object({}) do |(name, double_quoted, single_quoted, bare), attributes|
      attributes[name.downcase] = CGI.unescapeHTML(double_quoted || single_quoted || bare || "")
    end
  end

  def parse_public_uri(value)
    uri = URI.parse(value)
    return unless uri.is_a?(URI::HTTP) && uri.host.present?
    return unless public_host?(uri.host)

    uri
  rescue URI::InvalidURIError
    nil
  end

  def resolve_uri(value, base_uri, require_public_host: false)
    return if value.blank?

    uri = if value.start_with?("//")
      URI.parse("#{base_uri.scheme}:#{value}")
    else
      URI.join(base_uri.to_s, value)
    end
    return unless uri.is_a?(URI::HTTP)
    return if require_public_host && !public_host?(uri.host)

    uri
  rescue URI::InvalidURIError
    nil
  end

  def public_host?(host)
    return false if host.blank? || host.casecmp("localhost").zero?

    addresses = if ip_literal?(host)
      [IPAddr.new(host)]
    else
      Resolv.each_address(host).map { |address| IPAddr.new(address) }
    end
    return false if addresses.empty?

    addresses.none? { |address| PRIVATE_NETWORKS.any? { |range| range.include?(address) } }
  rescue Resolv::ResolvError, IPAddr::InvalidAddressError
    false
  end

  def ip_literal?(host)
    IPAddr.new(host)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end
