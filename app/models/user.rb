class User < ApplicationRecord

 
    def as_json(*)
        super.except("salt", "passwd")
      end

end
