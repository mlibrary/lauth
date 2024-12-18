-- target-cats is the collection that the user will request
-- the user is authorized for this collection
INSERT INTO aa_coll VALUES(
  'target-cats', -- uniqueIdentifier
  'target-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'any', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  'f', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- extra-cats is a private collection the user is authorized for
INSERT INTO aa_coll VALUES(
  'extra-cats', -- uniqueIdentifier
  'extra-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'any', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  'f', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- secret-cats is a private collection the user is not authorized for
INSERT INTO aa_coll VALUES(
  'secret-cats', -- uniqueIdentifier
  'secret-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'any', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  'f', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- public-cats is a public collection the user is not explicitly authorized for
INSERT INTO aa_coll VALUES(
  'public-cats', -- uniqueIdentifier
  'public-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'any', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  't', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- extra-public-cats is a public collection the user is explicitly authorized for
INSERT INTO aa_coll VALUES(
  'extra-public-cats', -- uniqueIdentifier
  'extra-public-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'any', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  't', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- location for non-proxy scenarios
INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/lauth/test-site/cgi/printenv', -- dlpsPath
  'target-cats', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- location for proxy scenarios, where we match by uri
INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/app/proxied', -- dlpsPath
  'target-cats', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  'lauth-allowed', -- userid
  NULL, -- user_grp
  NULL, -- inst
  'target-cats', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  'lauth-allowed', -- userid
  NULL, -- user_grp
  NULL, -- inst
  'extra-cats', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  'lauth-allowed', -- userid
  NULL, -- user_grp
  NULL, -- inst
  'extra-public-cats', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);
