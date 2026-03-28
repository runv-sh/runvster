CommunitySetting.current

def upsert_demo_user(email:, username:, password:, bio:, role: "member")
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    username: username,
    password: password,
    password_confirmation: password,
    bio: bio,
    role: role,
    email_verified_at: user.email_verified_at || Time.current,
    account_state: "active"
  )
  user.save!
  user
end

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

admin = upsert_demo_user(
  email: "admin@runvster.local",
  username: "admin",
  password: "runvster123",
  bio: "Pessoa responsavel por abrir, operar e moderar o nucleo inicial.",
  role: "admin"
)

moderator = upsert_demo_user(
  email: "moderator@runvster.local",
  username: "mod_one",
  password: "runvster123",
  bio: "Moderador demo para exercitar a fila de revisao e a area staff.",
  role: "moderator"
)

member = upsert_demo_user(
  email: "member@runvster.local",
  username: "member_one",
  password: "runvster123",
  bio: "Membro demo para exercitar convites, comentarios e votos."
)

pending_invitation = Invitation.find_or_initialize_by(recipient_email: "prospect@runvster.local")
pending_invitation.assign_attributes(
  inviter: admin,
  invitee: nil,
  accepted_at: nil,
  revoked_at: nil,
  acceptance_note: nil,
  expires_at: 14.days.from_now,
  sent_count: [pending_invitation.sent_count.to_i, 1].max,
  last_sent_at: pending_invitation.last_sent_at || Time.current
)
pending_invitation.save!

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

AdminAction.find_or_create_by!(admin: moderator, action_type: "seed_review_ready", target_type: "ModerationCase", target_id: ModerationCase.order(:id).last&.id) do |action|
  action.details = "Conta moderadora demo criada para validar os fluxos de staff sem usar o admin."
end

AdminAction.find_or_create_by!(admin: admin, action_type: "seed_bootstrap", target_type: "System", target_id: nil) do |action|
  action.details = "Ambiente inicial populado com admin, moderador, membro, posts, votos, convites e moderacao."
end
