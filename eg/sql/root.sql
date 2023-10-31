-- For a new database, root user/group is needed; for migrated, skip.
INSERT INTO aa_user
  (userid, givenName, surname, rfc822Mailbox, dlpsKey, userPassword, manager,
    lastModifiedTime, lastModifiedBy, dlpsDeleted)
  VALUES('root', 'Super', 'User', 'lit-cs-sysadmin@umich.edu',
    '!none', '!none', 0, CURRENT_TIMESTAMP(), 'root', 'f');

INSERT INTO aa_user_grp VALUES(0, 'root', 0, CURRENT_TIMESTAMP(), 'root', 'f');

INSERT INTO aa_is_member_of_grp VALUES('root', 0, CURRENT_TIMESTAMP(), 'root', 'f');


