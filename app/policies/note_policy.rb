class NotePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all.where(user: user, is_bookmarked: true)
    end
  end

  def create?
    return true
  end

  def show?
    return true
  end

  def update?
    return true
  end

  def beautiful_transcript?
    return true
  end
  
  def create_tag?
    return true
  end
  
  def raw_notes?
    return true
  end
  
  def raw_transcript?
    return true
  end
  
  def quiz?
    return true
  end
end
