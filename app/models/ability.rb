class Ability
  include CanCan::Ability

  def initialize(user)

    # Articles.
    if user.persisted?
        can :create, Article
    end
    if user.is? :moderator
        can :update, Article
    end
    can :read, Article

    # Submissions.
    if user.persisted?
        can :create, Submission
        can :update, Submission do |s|
            s.user == user
        end
        can :moderate, Submission do |s|
            user.is?(:admin)
        end
    end

    if user.persisted?
        can :create, :feedback
    end

    if user.is? :admin
        can :manage, :all
    end

  end
end
