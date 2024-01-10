-- private-cats is the collection that the user will request
-- the user is authorized for this collection
INSERT INTO aa_coll VALUES(
  'private-cats', -- uniqueIdentifier
  'private-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'pw', -- dlpsAuthenMethod
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
  'pw', -- dlpsAuthenMethod
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
  'pw', -- dlpsAuthenMethod
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
  'pw', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  't', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- foia-cats is a public collection the user is explicitly authorized for
INSERT INTO aa_coll VALUES(
  'foia-cats', -- uniqueIdentifier
  'foia-cats', -- commonName
  'auth system testing: delegation',
  'catpics', -- dlpsClass
  'none', -- dlpsSource (unused)
  'pw', -- dlpsAuthenMethod
  'd', -- dlpsAuthzType
  't', -- dlpsPartlyPublic
  0, -- manager
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

-- we only need one location for these tests
INSERT INTO aa_coll_obj VALUES(
  'www.lauth.local', -- server hostname, not vhost
  '/lauth/test-site/cgi/private-cats.pl', -- dlpsPath
  'private-cats', -- coll.uniqueIdentifier
  CURRENT_TIMESTAMP, 'root', -- modified info
  'f' -- deleted
);

INSERT INTO aa_may_access VALUES(
  NULL, -- uniqueIdentifier
  'lauth-allowed', -- userid
  NULL, -- user_grp
  NULL, -- inst
  'private-cats', -- coll
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
  'foia-cats', -- coll
  CURRENT_TIMESTAMP,
  'root',
  NULL,
  'f'
);
