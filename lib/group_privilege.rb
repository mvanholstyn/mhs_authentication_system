class GroupPrivilege < ActiveRecord::Base
  set_table_name "groups_privileges"
  belongs_to :group
  belongs_to :privilege
end
