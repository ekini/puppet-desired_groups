Puppet::Type.type(:desired_groups).provide(:usermod) do

    desc "Manage user's groups via usermod"

    confine :kernel => [ :Linux, :SunOS ]
    defaultfor :kernel => [ :Linux, :SunOS ]

    commands :usermod => "/usr/sbin/usermod"

    # helper method
    def get_user_groups(user)
        user_groups = []
        Etc.setgrent
        Etc.group {|g|
            if g.mem.include? user
                user_groups << g.name
            end
        }
        Etc.endgrent
        user_groups
    end

    # getter
    def groups
        user = @resource[:name]
        desired_groups = @resource[:groups]
        current_groups = get_user_groups(user)
        groups = []

        # adding nil items to comply with user data
        desired_groups.each {|dg|
            if current_groups.include? dg
                groups << dg
            else
                groups << nil
            end
        }

        groups
    end

    # setter
    def groups=(values)
        user = @resource[:name]

        # need compact to remove nil items
        groups = values.compact
        params = [ '-G',groups.join(','),user ]

        if Facter.value(:kernel) == 'Linux'
            params.unshift('-a')
        end

        usermod(params)
    end

end
