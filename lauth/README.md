# Lauth

## Import patron records

Run the patron importer from this application directory:

```sh
hanami run script/update_patron_users.rb /path/to/patron-export.tsv [/path/to/staff-map.json]
```

The patron export path is required. The optional staff map is read from disk and
must use the `Uniqname` and `DirectReports` JSON structure. Library staff
memberships are added for patrons found in this map or whose org unit matches and
status is `Faculty` or `Staff`. If the map is omitted, the importer warns and
uses only the org-unit rules.
