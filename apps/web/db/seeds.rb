%w[founders infra design product ai growth rails].each do |name|
  Tag.find_or_create_by!(slug: name) do |tag|
    tag.name = name
    tag.description = "Topicos iniciais para a comunidade Runvster."
  end
end
