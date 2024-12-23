INSERT INTO aa_inst VALUES(
  NULL,
  'University of Lauth, Testing', NULL,
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- Capture the institution ID for associated inserts
SET @test_inst_id = LAST_INSERT_ID();

INSERT INTO aa_coll VALUES(
  'lauth-by-username', -- uniqueIdentifier
  'lauth-by-username', -- commonName
  'auth system testing: user authentication',
  'lauth-test', -- dlpsClass
  'none', -- dlpsSource (unused)
  'pw', -- dlpsAuthenMethod
  'n', -- dlpsAuthzType
  'f', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/lauth/test-site/web/restricted-by-username%', -- dlpsPath (path on disk, for Apache <Directory>)
  'lauth-by-username', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- Our "proxied" tests will covered URI-based locations
------------- !!!! -----------------
-- INSERT INTO aa_coll_obj VALUES(
--   'www.lauth.local', -- server hostname, not vhost
--   '/restricted-by-username%', -- dlpsPath (URL as Apache sees it for <Location>)
--   'lauth-by-username', -- coll.uniqueIdentifier
--   CURRENT_TIMESTAMP, 'root', -- modified info
--   'f' -- deleted
-- );

INSERT INTO aa_may_access VALUES(
  NULL,
  -- uniqueIdentifier; normally auto-inc, but keys are disabled
  -- so we can set the inst id explicitly
  NULL, NULL, @test_inst_id, 'lauth-by-username', CURRENT_TIMESTAMP, 'root', NULL, 'f'
);


INSERT INTO aa_user VALUES(
  'lauth-allowed',NULL,'Lauth',NULL,'Tester-Allowed','lauth-allowed@umich.edu',
  NULL, -- org unit
  'Library auth system test user - this user is granted access',
  'Ann Arbor','MI','48109-119',NULL,NULL,'Staff',NULL,
  '!none', -- umich id, !none
  '@umich.edu', -- password, @umich.edu MAY signify SSO
  0,NULL,
  CURRENT_TIMESTAMP,'root', -- modified
  NULL, -- expiry
  'f'
);

INSERT INTO aa_user VALUES(
  'lauth-denied',NULL,'Lauth',NULL,'Tester-Denied','lauth-denied@umich.edu',
  NULL, -- org unit
  'Library auth system test user - this user has NO memberships or grants',
  'Ann Arbor','MI','48109-119',NULL,NULL,'Staff',NULL,
  '!none', -- umich id, !none
  '@umich.edu', -- password, @umich.edu MAY signify SSO
  0,NULL,
  CURRENT_TIMESTAMP,'root', -- modified
  NULL, -- expiry
  'f'
);

---------- setup for user allowed via institution membership ----------
INSERT INTO aa_user VALUES(
  'lauth-inst-member',NULL,'Lauth',NULL,'Test-inst-mem','lauth-inst-member',
  NULL, -- org unit
  'Library auth system test user - this user is an institution member',
  'Ann Arbor','MI','48109-119',NULL,NULL,'Staff',NULL,
  '!none', -- umich id, !none
  '@umich.edu', -- password, @umich.edu MAY signify SSO
  0,NULL,
  CURRENT_TIMESTAMP,'root', -- modified
  NULL, -- expiry
  'f'
);

INSERT INTO aa_is_member_of_inst VALUES(
  'lauth-inst-member', @test_inst_id, CURRENT_TIMESTAMP, 'root', 'f'
);

INSERT INTO aa_may_access VALUES(
  NULL,
  NULL, NULL, @test_inst_id, 'lauth-by-username', CURRENT_TIMESTAMP, 'root', NULL, 'f'
);

---------- setup for user allowed via group membership ----------
INSERT INTO aa_user VALUES(
  'lauth-group-member',NULL,'Lauth',NULL,'Test-group-mem','lauth-group-member',
  NULL, -- org unit
  'Library auth system test user - this user is a group member',
  'Ann Arbor','MI','48109-119',NULL,NULL,'Staff',NULL,
  '!none', -- umich id, !none
  '@umich.edu', -- password, @umich.edu MAY signify SSO
  0,NULL,
  CURRENT_TIMESTAMP,'root', -- modified
  NULL, -- expiry
  'f'
);

INSERT INTO aa_user_grp VALUES(
	9999, -- uniqueIdentifier
	'Library auth system test group', -- commonName
	0, -- manager
	CURRENT_TIMESTAMP, 'root', -- modified
  'f' -- deleted
);

INSERT INTO aa_is_member_of_grp VALUES(
  'lauth-group-member', 9999, CURRENT_TIMESTAMP, 'root', 'f'
);

INSERT INTO aa_may_access VALUES(
  NULL,
  NULL, 9999, NULL, 'lauth-by-username', CURRENT_TIMESTAMP, 'root', NULL, 'f'
);

-----------------------------------------------------------------------------

-- Individual grant to the by-username collection
INSERT INTO aa_may_access VALUES(
  NULL,
  'lauth-allowed', NULL, NULL, 'lauth-by-username', CURRENT_TIMESTAMP, 'root', NULL, 'f'
);
