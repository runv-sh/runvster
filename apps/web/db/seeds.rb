tag_descriptions = {
  "founders" => "Decisoes de produto, tracao e construcao de empresa.",
  "infra" => "Arquitetura, deploy, operacao e confiabilidade.",
  "design" => "UX, sistemas visuais e experiencia de comunidade.",
  "product" => "Estrutura de produto, estrategia e descoberta.",
  "ai" => "Ferramentas, modelos, agentes e aplicacoes de IA.",
  "growth" => "Distribuicao, loops de crescimento e marketing.",
  "rails" => "Implementacao Ruby on Rails, padroes e runtime."
}

tags = tag_descriptions.map do |slug, description|
  Tag.find_or_create_by!(slug: slug) do |tag|
    tag.name = slug
    tag.description = description
  end
end

admin = User.find_or_create_by!(email: "admin@runvster.local") do |user|
  user.username = "admin"
  user.password = "runvster123"
  user.password_confirmation = "runvster123"
  user.bio = "Pessoa responsavel por abrir, operar e moderar o nucleo inicial."
  user.role = "admin"
end

member = User.find_or_create_by!(email: "member@runvster.local") do |user|
  user.username = "member_one"
  user.password = "runvster123"
  user.password_confirmation = "runvster123"
  user.bio = "Membro demo para exercitar convites, comentarios e votos."
end

invitation = Invitation.find_or_create_by!(recipient_email: member.email) do |record|
  record.inviter = admin
  record.expires_at = 14.days.from_now
end
invitation.mark_as_accepted!(member) unless invitation.accepted?

posts = [
  {
    title: "Como desenhar uma comunidade pequena com alta densidade de sinal",
    body: "Estamos explorando um feed com menos ruido, mais contexto e moderacao desde o inicio.",
    user: admin,
    tags: %w[product founders design]
  },
  {
    title: "Checklist de deploy para um monolito Rails com worker separado",
    url: "https://rubyonrails.org/",
    body: "Referencias para pensar deploy, filas, observabilidade e credenciais.",
    user: member,
    tags: %w[infra rails growth]
  }
]

posts.each do |attributes|
  post = Post.find_or_initialize_by(title: attributes[:title])
  post.user = attributes[:user]
  post.url = attributes[:url]
  post.body = attributes[:body]
  post.assign_tag_names(attributes[:tags].join(", "))
  post.save!
end

first_post, second_post = Post.order(:created_at).first(2)

comment = Comment.find_or_create_by!(post: first_post, user: member, body: "Esse tipo de curadoria muda completamente a qualidade do feed.")
Comment.find_or_create_by!(post: first_post, user: admin, parent: comment, body: "Essa e a aposta central do produto inicial.")

Vote.find_or_create_by!(post: first_post, user: admin) { |vote| vote.value = 1 }
Vote.find_or_create_by!(post: first_post, user: member) { |vote| vote.value = 1 }
Vote.find_or_create_by!(post: second_post, user: admin) { |vote| vote.value = 1 }

ModerationCase.find_or_create_by!(reporter: member, reportable: second_post, reason: "Link suspeito") do |record|
  record.details = "Exemplo de reporte para exercitar a fila administrativa."
end

AdminAction.find_or_create_by!(admin: admin, action_type: "seed_bootstrap", target_type: "System", target_id: nil) do |action|
  action.details = "Ambiente inicial populado com admin, membro, posts, votos e moderacao."
end
