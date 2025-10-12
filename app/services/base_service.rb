class BaseService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end
end
