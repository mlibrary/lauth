-- Create all foreign keys; will cause problems if in place before bootstrap or data load

ALTER TABLE aa_user ADD FOREIGN KEY
  user_manager (manager)
  REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_user ADD FOREIGN KEY
  user_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_user_grp ADD FOREIGN KEY
  user_grp_manager (manager)
  REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_user_grp ADD FOREIGN KEY
  user_grp_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_inst ADD FOREIGN KEY
  inst_manager (manager)
  REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_inst ADD FOREIGN KEY
  inst_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_is_member_of_inst ADD FOREIGN KEY
  is_member_of_inst_user (userid)
  REFERENCES aa_user (userid)
  ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_inst ADD FOREIGN KEY
  is_member_of_inst_inst (inst)
  REFERENCES aa_inst (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_inst ADD FOREIGN KEY
  is_mem_inst_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_is_member_of_grp ADD FOREIGN KEY
  is_member_of_grp_user (userid)
  REFERENCES aa_user (userid)
  ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_grp ADD FOREIGN KEY
  is_member_of_grp_user_grp (user_grp)
  REFERENCES aa_user_grp (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_grp ADD FOREIGN KEY
  is_mem_grp_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_coll ADD FOREIGN KEY
  coll_manager (manager)
  REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_coll ADD FOREIGN KEY
  coll_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_coll_obj ADD FOREIGN KEY
  coll_obj_coll (coll)
  REFERENCES aa_coll (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_coll_obj ADD FOREIGN KEY
  coll_obj_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_network ADD FOREIGN KEY
  network_coll (coll)
  REFERENCES aa_coll (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_network ADD FOREIGN KEY
  network_inst (inst)
  REFERENCES aa_inst (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_network ADD FOREIGN KEY
  network_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid);

ALTER TABLE aa_may_access ADD FOREIGN KEY
  may_access_user (userid)
  REFERENCES aa_user (userid)
  ON DELETE CASCADE;

ALTER TABLE aa_may_access ADD FOREIGN KEY
  may_access_user_grp (user_grp)
  REFERENCES aa_user_grp (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_may_access ADD FOREIGN KEY
  may_access_inst (inst)
  REFERENCES aa_inst (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_may_access ADD FOREIGN KEY
  may_access_coll (coll)
  REFERENCES aa_coll (uniqueIdentifier)
  ON DELETE CASCADE;

ALTER TABLE aa_may_access ADD FOREIGN KEY
  may_access_lastModifiedBy (lastModifiedBy)
  REFERENCES aa_user (userid)
  ON DELETE CASCADE;

