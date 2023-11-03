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
