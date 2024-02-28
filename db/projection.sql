INSERT INTO aa_coll VALUES(
  'projection-public', -- uniqueIdentifier
  'projection-public', -- commonName
  'auth system testing: projection',
  'unused', -- dlpsClass
  'none', -- dlpsSource (unused)
  'pw', -- dlpsAuthenMethod
  'n', -- dlpsAuthzType
  't', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/lauth/test-site/web/projection/public%', -- dlpsPath
  'projection-public', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_coll VALUES(
  'projection-private', -- uniqueIdentifier
  'projection-private', -- commonName
  'auth system testing: projection',
  'unused', -- dlpsClass
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
  '/lauth/test-site/web/projection/private%', -- dlpsPath
  'projection-private', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  'lauth-allowed', -- userid
  NULL, -- user_grp
  NULL, -- inst
  'projection-private', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);

INSERT INTO aa_coll VALUES(
  'projection-private-also', -- uniqueIdentifier
  'projection-private-also', -- commonName
  'auth system testing: projection',
  'unused', -- dlpsClass
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
  '/lauth/test-site/web/projection/private-also%', -- dlpsPath
  'projection-private-also', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_user VALUES(
  'lauth-allowed-also',NULL,'Lauth',NULL,'Tester-Allowed','lauth-allowed-also@umich.edu',
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

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  'lauth-allowed-also', -- userid
  NULL, -- user_grp
  NULL, -- inst
  'projection-private-also', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
)
