xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.tag!("atom:link", href: @feed_url, rel: "self", type: "application/rss+xml")
    xml.title @feed_title
    xml.link root_url
    xml.description @feed_description
    xml.language "pt-BR"
    xml.lastBuildDate((@posts.first&.updated_at || Time.current).rfc2822)
    xml.generator "Runvster"

    @posts.each do |post|
      item_description = [
        post.social_description,
        ("Link original: #{post.url}" if post.link_post?),
        "Autor: @#{post.user.username}",
        "Comentarios: #{post.comments_count}",
        ("Tags: #{post.tags.map(&:name).join(', ')}" if post.tags.any?)
      ].compact.join(" | ")

      xml.item do
        xml.title post.title
        xml.link post_url(post)
        xml.guid post_url(post)
        xml.pubDate post.created_at.rfc2822
        xml.description item_description

        post.tags.each do |tag|
          xml.category tag.name
        end
      end
    end
  end
end
