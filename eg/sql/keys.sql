-- Create all foreign keys; will cause problems if in place before bootstrap or data load

ALTER TABLE aa_user
    ADD CONSTRAINT user_manager
        FOREIGN KEY (manager)
            REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_user
    ADD CONSTRAINT user_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_user_grp
    ADD CONSTRAINT user_grp_manager
        FOREIGN KEY (manager)
            REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_user_grp
    ADD CONSTRAINT user_grp_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_inst
    ADD CONSTRAINT inst_manager
        FOREIGN KEY (manager)
            REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_inst
    ADD CONSTRAINT inst_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_is_member_of_inst
    ADD CONSTRAINT is_member_of_inst_user
        FOREIGN KEY (userid)
            REFERENCES aa_user (userid)
            ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_inst
    ADD CONSTRAINT is_member_of_inst_inst
        FOREIGN KEY (inst)
            REFERENCES aa_inst (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_inst
    ADD CONSTRAINT is_mem_inst_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_is_member_of_grp
    ADD CONSTRAINT is_member_of_grp_user
        FOREIGN KEY (userid)
            REFERENCES aa_user (userid)
            ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_grp
    ADD CONSTRAINT is_member_of_grp_user_grp
        FOREIGN KEY (user_grp)
            REFERENCES aa_user_grp (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_is_member_of_grp
    ADD CONSTRAINT is_mem_grp_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_coll
    ADD CONSTRAINT coll_manager
        FOREIGN KEY (manager)
            REFERENCES aa_user_grp (uniqueIdentifier);

ALTER TABLE aa_coll
    ADD CONSTRAINT coll_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_coll_obj
    ADD CONSTRAINT  coll_obj_coll
        FOREIGN KEY (coll)
            REFERENCES aa_coll (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_coll_obj
    ADD CONSTRAINT coll_obj_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_network
    ADD CONSTRAINT network_coll
        FOREIGN KEY (coll)
            REFERENCES aa_coll (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_network
    ADD CONSTRAINT network_inst
        FOREIGN KEY (inst)
            REFERENCES aa_inst (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_network
    ADD CONSTRAINT network_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid);

ALTER TABLE aa_may_access
    ADD CONSTRAINT may_access_user
        FOREIGN KEY (userid)
            REFERENCES aa_user (userid)
            ON DELETE CASCADE;

ALTER TABLE aa_may_access
    ADD CONSTRAINT may_access_user_grp
        FOREIGN KEY (user_grp)
            REFERENCES aa_user_grp (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_may_access
    ADD CONSTRAINT may_access_inst
        FOREIGN KEY (inst)
            REFERENCES aa_inst (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_may_access
    ADD CONSTRAINT may_access_coll
        FOREIGN KEY (coll)
            REFERENCES aa_coll (uniqueIdentifier)
            ON DELETE CASCADE;

ALTER TABLE aa_may_access
    ADD CONSTRAINT may_access_lastModifiedBy
        FOREIGN KEY (lastModifiedBy)
            REFERENCES aa_user (userid)
            ON DELETE CASCADE;
