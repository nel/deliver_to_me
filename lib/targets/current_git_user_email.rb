module Targets
  module CurrentGitUserEmail
    class << self
      def get
        if in_git?
          unless git_user_email.blank?
            git_user_email
          else
            puts <<-WARN
**************************************************************************************************
              Deliver_to_me plugin notification:

              It seems you do not have configured your git repo with user.name and user.email

              You can do it this way:
                $ git config --global user.name   "FirstName LastName"
                $ git config --global user.email  "Your Email Here"
**************************************************************************************************
            WARN
          end
        else
          puts <<-WARN
**************************************************************************************************
            Deliver_to_me plugin notification:
          
            You cannot use the :current_git_user_name options as you aren't
            in a git repo
**************************************************************************************************
          WARN
        end
      end
    
      private
        # return true if pwd is in a git repo, false otherwise
        def in_git?
          Kernel.system('git rev-parse --show-prefix 2>/dev/null')
        end
      
        def git_user_email
          `git config user.email`
        end
      
        def git_user_name
          `git config user.name`
        end
    end
  end
end