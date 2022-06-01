-- Drop all foreign keys; for truncate and data load

ALTER TABLE aa_user DROP FOREIGN KEY user_manager
ALTER TABLE aa_user DROP FOREIGN KEY user_lastModifiedBy;
ALTER TABLE aa_user_grp DROP FOREIGN KEY user_grp_manager;
ALTER TABLE aa_user_grp DROP FOREIGN KEY user_grp_lastModifiedBy;
ALTER TABLE aa_inst DROP FOREIGN KEY inst_manager;
ALTER TABLE aa_inst DROP FOREIGN KEY inst_lastModifiedBy;
ALTER TABLE aa_is_member_of_inst DROP FOREIGN KEY is_member_of_inst_user;
ALTER TABLE aa_is_member_of_inst DROP FOREIGN KEY is_member_of_inst_inst;
ALTER TABLE aa_is_member_of_inst DROP FOREIGN KEY is_mem_inst_lastModifiedBy;
ALTER TABLE aa_is_member_of_grp DROP FOREIGN KEY is_member_of_grp_user;
ALTER TABLE aa_is_member_of_grp DROP FOREIGN KEY is_member_of_grp_user_grp;
ALTER TABLE aa_is_member_of_grp DROP FOREIGN KEY is_mem_grp_lastModifiedBy;
ALTER TABLE aa_coll DROP FOREIGN KEY coll_manager;
ALTER TABLE aa_coll DROP FOREIGN KEY coll_lastModifiedBy;
ALTER TABLE aa_coll_obj DROP FOREIGN KEY coll_obj_coll;
ALTER TABLE aa_coll_obj DROP FOREIGN KEY coll_obj_lastModifiedBy;
ALTER TABLE aa_network DROP FOREIGN KEY network_coll;
ALTER TABLE aa_network DROP FOREIGN KEY network_inst;
ALTER TABLE aa_network DROP FOREIGN KEY network_lastModifiedBy;
ALTER TABLE aa_may_access DROP FOREIGN KEY may_access_user;
ALTER TABLE aa_may_access DROP FOREIGN KEY may_access_user_grp;
ALTER TABLE aa_may_access DROP FOREIGN KEY may_access_inst;
ALTER TABLE aa_may_access DROP FOREIGN KEY may_access_coll;
ALTER TABLE aa_may_access DROP FOREIGN KEY may_access_lastModifiedBy;
