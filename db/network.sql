-- Create an institution within the larger institution
INSERT INTO aa_inst VALUES(
  NULL,
  'Lauth Law Enclave', NULL,
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);
SET @enclave_inst_id = LAST_INSERT_ID();

-- We use the existing inst as the larger university network.
SET @big_inst_id = (
  SELECT uniqueIdentifier
  FROM aa_inst
  WHERE organizationName = 'University of Lauth, Testing'
);

-- Collection for most network scenarios
INSERT INTO aa_coll VALUES(
  'lauth-by-client-ip', -- uniqueIdentifier
  'lauth-by-client-ip', -- commonName
  'auth system testing: network authentication',
  'lauth-test', -- dlpsClass
  'none', -- dlpsSource (unused)
  'ip', -- dlpsAuthenMethod
  'n', -- dlpsAuthzType
  'f', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/lauth/test-site/web/restricted-by-network%', -- dlpsPath
  'lauth-by-client-ip', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  NULL, -- userid
  NULL, -- user_grp
  @big_inst_id, -- inst
  'lauth-by-client-ip', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  NULL, -- userid
  NULL, -- user_grp
  @enclave_inst_id, -- inst
  'lauth-by-client-ip', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);

------A full /24 allowed campus network-------
-- allow campus 10.1.16.0/24 (255 - 0)
INSERT INTO aa_network --
VALUES (
  NULL, NULL,
  '10.1.16.0/24', 167841792, 167842047,
  'allow', NULL, @big_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);

-- keep this range free of rules!
-- null 10.1.8.0/24 (255)

----Campus net with a single blocked ip and an allowed enclave----
-- allow campus 10.1.6.0/24 (255)
-- deny one ip 10.1.6.2/32 (1)
-- allow enclave 10.1.6.8/29 (8)
INSERT INTO aa_network -- campus network
VALUES (
  NULL, NULL,
  '10.1.6.0/24', 167839232, 167839487,
  'allow', NULL, @big_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);
INSERT INTO aa_network -- blocked ip
VALUES (
  NULL, NULL,
  '10.1.6.2/32', 167839234, 167839234,
  'deny', NULL, @big_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);
INSERT INTO aa_network -- allowed enclave
VALUES (
  NULL, NULL,
  '10.1.6.8/29', 167839240, 167839247,
  'allow', NULL, @enclave_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);

----An allowed enclave within a denied campus-----
-- deny campus 10.1.7.0/24 (255 - 8)
-- allow enclave 10.1.7.8/29 (-8)
INSERT INTO aa_network -- campus network, denied
VALUES (
  NULL, NULL,
  '10.1.7.0/24', 167839488, 167839743,
  'deny', NULL, @big_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);
INSERT INTO aa_network -- allowed enclave
VALUES (
  NULL, NULL,
  '10.1.7.8/29', 167839496, 167839503,
  'allow', NULL, @enclave_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);



------A full /24 denied campus network-------
-- deny campus 10.1.17.0/24 (255 - 0)
INSERT INTO aa_network
VALUES (
  NULL, NULL,
  '10.1.17.0/24', 167842048, 167842303,
  'deny', NULL, @big_inst_id,
  CURRENT_TIMESTAMP, 'root', 'f'
);
