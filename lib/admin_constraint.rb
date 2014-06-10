
class AdminConstraint
  def matches?(request)
    return false if request.cookies['remember_token'].nil?
    account = Account.find_by_remember_token(request.cookies['remember_token'])
    account && account.is_admin?
  end
end

class BossConstraint
  def matches?(request)
    return false if request.cookies['remember_token'].nil?
    account = Account.find_by_remember_token(request.cookies['remember_token'])
    account && (account.is_boss? || account.is_admin?)
  end
end

class WorkerConstraint
  def matches?(request)
    return false if request.cookies['remember_token'].nil?
    account = Account.find_by_remember_token(request.cookies['remember_token'])
    account && (account.is_boss? || account.is_admin?|| account.is_worker?) 
  end
end