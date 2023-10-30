INSERT INTO aa_inst VALUES(
  NULL,
  'University of Lauth, Testing', NULL,
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- Capture the institution ID for associated inserts
SET @test_inst_id = LAST_INSERT_ID();

INSERT INTO aa_coll VALUES(
  'lauth-user', -- uniqueIdentifier
  'lauth-user', -- commonName
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
  '/lauth/test-site/web/user%', -- dlpsPath (on disk, not URL)
  'lauth-user', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_may_access VALUES(
  NULL,
  -- uniqueIdentifier; normally auto-inc, but keys are disabled
  -- so we can set the inst id explicitly
  NULL, NULL, @test_inst_id, 'lauth-user', CURRENT_TIMESTAMP, 'root', NULL, 'f'
);

------ TODO: Discuss network ranges
-- INSERT INTO aa_network VALUES(
--   NULL, NULL, '10.1.1.1/24', 167837953, 167838207, 'allow', NULL, @test_inst_id, CURRENT_TIMESTAMP, 'root', 'f'
-- );

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

INSERT INTO aa_is_member_of_inst VALUES(
  'lauth-allowed', @test_inst_id, CURRENT_TIMESTAMP, 'root', 'f'
);
