class User < ActiveRecord::Base

  delegate :can?, :cannot?, :to => :ability

  has_many :authorizations, :dependent => :destroy

  serialize :roles, Array

  scope :admin, where(%|roles LIKE '%admin%'|)
  scope :moderator, where(%|roles LIKE '%moderator%' OR roles LIKE '%admin%'|)
  scope :not_admin, where(%|roles NOT LIKE '%admin%'|)
  scope :recent, ->(ago = 18.hours.ago) { where('created_at > ?', ago) }
  scope :blank_email, where(:email => nil)

  after_initialize :belongs_to_at_least_one_role
  validate :belongs_to_at_least_one_role

  # Override the default role getter and setter to validate the roles.
  def roles=(r)
    r = (r.is_a?(Array) ? r.flatten.compact.map(&:to_sym) : (r || '').split(',').map(&:to_sym)) & ROLES
    write_attribute(:roles, r)
  end

  def roles
    ([ read_attribute(:roles) ].flatten & ROLES).map(&:to_sym)
  end

  def role=(r)
    self.roles = [r]
  end

  def role
    self.roles.first
  end

  def ability
    @_ability ||= Ability.new(self)
  end

  def is?(role)
    self.roles.include?(role.to_sym)
  end

  def self.find_for_oauth(omniauth_hash, current_user)

    logger.info('omniauth_hash')
    logger.info(omniauth_hash.inspect)

    # Our temp user data struct.
    data = {
      :provider => omniauth_hash['provider'],
      :uid => omniauth_hash['uid'].to_s,
      :username => omniauth_hash['info']['user']['username'],
      :email => omniauth_hash['info']['user']['email'],
      :token => omniauth_hash['credentials']['token'],
      :profile => omniauth_hash['info']['profile'],
      :roles => omniauth_hash['info']['user']['roles'].map(&:to_sym),
      :friend_uids => omniauth_hash['info']['user']['friend_uids']
    }
    data_to_update_for_user = data.slice(:email, :username, :roles, :friend_uids)
    data_to_update_for_auth = data.slice(:provider, :uid, :token)
    data_to_update_for_profile = data[:profile].slice(:description, :name, :postnominals, :title) unless data[:profile].nil?

    auth = Authorization.where(data.slice(:provider, :uid)).first

    if auth

      auth.user.update_attributes!(data_to_update_for_user, :without_protection => true)
      auth.update_attributes!(data_to_update_for_auth.slice(:token))
      unless data_to_update_for_profile.nil?
        p = auth.user.profile || auth.user.build_profile
        p.update_attributes!(data_to_update_for_profile)
      end

      auth.user

    elsif current_user.persisted?

      current_user.update_attributes!(data_to_update_for_user, :without_protection => true)
      current_user.authorizations.create!(data_to_update_for_auth, :without_protection => true)
      unless data_to_update_for_profile.nil?
        p = auth.user.profile || auth.user.build_profile
        p.update_attributes!(data_to_update_for_profile)
      end

      current_user

    else

      # TODO:
      # Because it makes life easier for everyone involved, and there's no important information in
      # TWI apps, *and* because FB does email validation before allowing a user to use an email
      # address, we implicitly trust the email address we get from FB and link accounts if the
      # user hasn't already logged in here before with FB.
      user = self.where(data_to_update_for_user.slice(:email)).first_or_initialize
      user.assign_attributes(data_to_update_for_user, :without_protection => true)
      user.save(:validate => false)
      user.authorizations.create!(data_to_update_for_auth, :without_protection => true)
      unless data_to_update_for_profile.nil?
        p = user.profile || user.build_profile
        p.update_attributes!(data_to_update_for_profile)
      end

      user

    end

  end

  def gravatar_url(*args)
    options = args.extract_options!
    options[:size] ||= 80 if args.length < 1
    options[:size] ||= args.first
    raise ArgumentError unless options[:size]
    require 'digest/md5'
    hash = Digest::MD5.hexdigest([self.email, 'gravatar@thewellinspired.com'].select(&:present?).first.downcase)
    if self.default_gravatar_url
      "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{options[:size]}&d=#{URI.escape(self.default_gravatar_url)}"
    else
      "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{options[:size]}"
    end
  end

  private

  def belongs_to_at_least_one_role
    self.role = DEFAULT_ROLE unless self.roles.count > 0
  end

end

class User < ActiveRecord::Base

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :remember_me

  has_one :profile, :dependent => :destroy
  has_many :contributions
  has_many :submissions
  has_many :authorizations, :dependent => :destroy

  serialize :friend_uids, Array

  def contribution_counts(type = :word, article_ids = nil)
    raise ArgumentError unless type.in?([ :word, :line ])
    article_ids = [ article_ids ].flatten.compact
    articles = article_ids.empty? ? Article.all : Article.where(:id => article_ids)
    scope = self.contributions.order('SUM(contributions.word_size) DESC').select('SUM(contributions.word_size) AS word_count, SUM(contributions.line_size) AS line_count').having('SUM(contributions.word_size) > 0')
    scope = article_ids.empty? ? scope : scope.where(:contributions => { :article_id => article_ids })
    scope = scope.collect{ |c| { :word_count => c.word_count.to_i, :line_count => c.line_count.to_i } }.first
    return 0 if scope.nil?
    type == :word ? scope[:word_count] : scope[:line_count]
  end

  # Line total and word total are used in user serializers.
  def line_count
    self.contribution_counts(:line)
  end

  def word_count
    self.contribution_counts(:word)
  end

  def article_count
    self.contributions.select('DISTINCT article_id').count
  end

  def articles_by_impact
    Article.joins(:contributions).where(:contributions => { :user_id => self.id }).select('articles.*, SUM(contributions.word_size) AS word_count').group('articles.id').having('SUM(contributions.word_size) > 0').map{ |a| a.word_count = a.word_count.to_i; a }.sort_by(&:word_count).reverse
  end

  def self.all_users_with_contribution_counts
    self.joins(:contributions).order('SUM(contributions.word_size) DESC').select('users.*, SUM(contributions.word_size) AS word_count, SUM(contributions.line_size) AS line_count').having('SUM(contributions.word_size) > 0').group(all_columns(:users))
  end

  def default_gravatar_url
    'https://oncallaid.com/assets/default_gravatar.png'
  end

end
