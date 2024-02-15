INSERT INTO aa_coll VALUES(
  'projection-public', -- uniqueIdentifier
  'projection-public', -- commonName
  'auth system testing: projection',
  'unused', -- dlpsClass
  'none', -- dlpsSource (unused)
  'pw', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  't', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/lauth/test-site/web/projection/public', -- dlpsPath
  'projection-public', -- coll.uniqueIdentifier
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
  'd', -- dlpsAuthzType
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
