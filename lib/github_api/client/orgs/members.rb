# encoding: utf-8

module Github
  class Client::Orgs::Members < API
    # List members
    #
    # List all users who are members of an organization. A member is a user
    # that belongs to at least 1 team in the organization.
    # If the authenticated user is also a member of this organization then
    # both concealed and public members will be returned.
    # Otherwise only public members are returned.
    #
    # @param [Hash] params
    # @input params [String] :filter
    #   Filter members returned in the list. Can be one of:
    #   * 2fa_disabled: Members without two-factor authentication enabled.
    #   Available for owners of organizations with private repositories.
    #   * all: All members the authenticated user can see.
    #   Default: all
    #
    # @example
    #  github = Github.new
    #  github.orgs.members.list 'org-name'
    #  github.orgs.members.list 'org-name' { |memb| ... }
    #
    # List public members
    #
    # Members of an organization can choose to have their
    # membership publicized or not.
    #
    # @example
    #  github = Github.new
    #  github.orgs.members.list 'org-name', public: true
    #  github.orgs.members.list 'org-name', public: true { |memb| ... }
    #
    # @api public
    def list(*args)
      params = arguments(args, required: [:org_name]).params
      org_name = arguments.org_name

      response = if params.delete('public')
        get_request("/orgs/#{org_name}/public_members", params)
      else
        get_request("/orgs/#{org_name}/members", params)
      end
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Check if user is, publicly or privately, a member of an organization
    #
    # @example
    #   github = Github.new
    #   github.orgs.members.member? 'org-name', 'member-name'
    #
    # Check if a user is a public member of an organization
    #
    # @example
    #   github = Github.new
    #   github.orgs.members.member? 'org-name', 'member-name', public: true
    #
    # @api public
    def member?(*args)
      params   = arguments(args, required: [:org_name, :user]).params
      org_name = arguments.org_name
      user     = arguments.user

      response = if params.delete('public')
        get_request("/orgs/#{org_name}/public_members/#{user}", params)
      else
        get_request("/orgs/#{org_name}/members/#{user}", params)
      end
      response.status == 204
    rescue Github::Error::NotFound
      false
    end

    # Remove a member
    #
    # Removing a user from this list will remove them from all teams and
    # they will no longer have any access to the organization’s repositories.
    #
    # @example
    #   github = Github.new
    #   github.orgs.members.remove 'org-name', 'member-name'
    #
    # @api public
    def delete(*args)
      arguments(args, required: [:org_name, :user])

      delete_request("/orgs/#{arguments.org_name}/members/#{arguments.user}", arguments.params)
    end
    alias :remove :delete

    # Publicize a user’s membership
    #
    # @example
    #   github = Github.new oauth_token: '...'
    #   github.orgs.members.publicize 'org-name', 'member-name'
    #
    # @api public
    def publicize(*args)
      arguments(args, required: [:org_name, :user])

      put_request("/orgs/#{arguments.org_name}/public_members/#{arguments.user}", arguments.params)
    end
    alias :make_public :publicize
    alias :publicize_membership :publicize

    # Conceal a user’s membership
    #
    # @example
    #  github = Github.new oauth_token: '...'
    #  github.orgs.members.conceal 'org-name', 'member-name'
    #
    # @api public
    def conceal(*args)
      arguments(args, required: [:org_name, :user])

      delete_request("/orgs/#{arguments.org_name}/public_members/#{arguments.user}", arguments.params)
    end
    alias :conceal_membership :conceal

    # Add or Update a user's membership for an organization. Supports roles of member or admin.
    #
    # @example
    #  github = Github.new oauth_token: '...'
    #  github.orgs.memberships.addupdateuser 'org-name', 'member-name', 'role'
    # @api public
    def addupdateuser(*args)
	arguments(args, required: [:org_name, :user, :role])
	
	put_request("/orgs/#{arguments.org_name}/memberships/#{arguments.user}", arguments.params)
    end
    alias :add_update_user :addupdateuser
  end # Client::Orgs::Members
end # Github
