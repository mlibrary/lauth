# frozen_string_literal: true

require "json"
require "stringio"
require "tmpdir"
require_relative "../../lib/lauth/patron_importer"

RSpec.describe Lauth::PatronImporter, type: :database do
  let(:output) { StringIO.new }
  let(:errors) { StringIO.new }
  let(:importer) { described_class.new(rom: rom, output: output, errors: errors) }
  let(:relations) { rom.relations }

  around do |example|
    Dir.mktmpdir("patron-importer") do |directory|
      @directory = directory
      example.run
    end
  end

  before do
    [
      [850_001, "University of Michigan Ann Arbor"],
      [850_002, "University of Michigan Dearborn"],
      [850_003, "University of Michigan Flint"],
      [850_004, "University of Michigan Library Staff"],
      [850_005, "University of Michigan Pseudo Users"],
      [850_006, "Non-University of Michigan Mirlyn Users"]
    ].each do |id, name|
      Factory[:institution, uniqueIdentifier: id, organizationName: name]
    end
  end

  it "imports a patron from paths, normalizes values, and adds staff membership from the map" do
    export_path = write_export(
      patron_row(
        userid: "test patron",
        surname: "Example",
        given_name: "Pat",
        unit: " 999999  ",
        status: "Staff  ",
        campus: "UMAA",
        key: "1234-5678",
        email: "test patron@example.test",
        address_1: " 1 Main St  ",
        address_2: " Room 2  ",
        phone: "+1 (555) 123-4567",
        expiry: "2099-01-02"
      )
    )
    staff_path = write_staff_map(
      "Uniqname" => "manager",
      "DirectReports" => [{"Uniqname" => "testpatron", "DirectReports" => []}]
    )

    importer.run(export_path: export_path, staff_map_path: staff_path)

    patron = relations[:users].dataset.where(userid: "testpatron").first
    expect(patron).to include(
      givenName: "Pat",
      surname: "Example",
      rfc822Mailbox: "testpatron@example.test",
      dlpsKey: "60084712345678",
      postalAddress: " 1 Main St\n Room 2",
      organizationalUnitName: " 999999",
      organizationalStatus: "Staff",
      dlpsDeleted: "f"
    )
    expect(patron[:telephoneNumber]).to eq("1(555)123-4567")

    memberships = relations[:institution_memberships].dataset
      .where(userid: "testpatron")
      .select_map(:inst)
    expect(memberships).to contain_exactly(850_001, 850_004)
    expect(output.string).to include("Processed 1 patron record;")
    expect(errors.string).to be_empty
  end

  it "adds staff membership from qualifying org units when the optional map is omitted" do
    export_path = write_export(
      patron_row(userid: "missing-email", email: "", expiry: "2099-01-02") +
        patron_row(userid: "invalid-date", expiry: "2099-02-30") +
        patron_row(userid: "faculty-patron", campus: "UMDB", status: "Faculty", unit: "470001") +
        patron_row(userid: "staff-patron", campus: "UMDB", status: "Staff", unit: "380015") +
        patron_row(userid: "other-unit-patron", campus: "UMDB", status: "Staff", unit: "999999") +
        patron_row(userid: "other-status-patron", campus: "UMDB", status: "Graduate", unit: "470001")
    )

    importer.run(export_path: export_path)

    expect(relations[:users].dataset.where(userid: "missing-email").count).to eq(0)
    expect(relations[:users].dataset.where(userid: "faculty-patron").get(:organizationalStatus)).to eq("Faculty")
    expect(relations[:users].dataset.where(userid: "staff-patron").get(:organizationalStatus)).to eq("Staff")
    expect(
      relations[:institution_memberships].dataset.where(userid: "faculty-patron").select_map(:inst)
    ).to contain_exactly(850_002, 850_004)
    expect(
      relations[:institution_memberships].dataset.where(userid: "staff-patron").select_map(:inst)
    ).to contain_exactly(850_002, 850_004)
    expect(
      relations[:institution_memberships].dataset.where(userid: "other-unit-patron").select_map(:inst)
    ).to contain_exactly(850_002)
    expect(
      relations[:institution_memberships].dataset.where(userid: "other-status-patron").select_map(:inst)
    ).to contain_exactly(850_002)
    expect(errors.string).to include("staff map not provided")
    expect(output.string).to include("Processed 4 patron records; skipped 2")
  end

  it "updates and reactivates an existing patron" do
    returning = Factory[
      :user,
      :soft_deleted,
      userid: "returning-patron",
      givenName: "Old",
      surname: "Name",
      dlpsKey: "old-key",
      rfc822Mailbox: "old@example.test",
      lastModifiedTime: Time.now - 100
    ]
    relations[:institution_memberships].dataset.insert(
      userid: returning.userid,
      inst: 850_003,
      lastModifiedTime: Time.now - 100,
      lastModifiedBy: "root",
      dlpsDeleted: "t"
    )
    export_path = write_export(
      patron_row(
        userid: "returning-patron",
        given_name: "New",
        surname: "Name",
        campus: "UMFL",
        key: "abcdefgh",
        email: "new@example.test",
        expiry: "2099-01-02"
      )
    )

    importer.run(export_path: export_path, staff_map_path: write_staff_map("Uniqname" => "someone", "DirectReports" => []))

    patron = relations[:users].dataset.where(userid: "returning-patron").first
    expect(patron).to include(
      givenName: "New",
      dlpsKey: "600847abcdefgh",
      rfc822Mailbox: "new@example.test",
      dlpsDeleted: "f",
      lastModifiedBy: "root"
    )
    expect(patron[:lastModifiedTime]).to be > Time.now - 30
    expect(
      relations[:institution_memberships].dataset
        .where(userid: "returning-patron", inst: 850_003)
        .get(:dlpsDeleted)
    ).to eq("f")
  end

  it "aborts before importing when a campus matches more than one institution" do
    Factory[:institution, uniqueIdentifier: 850_007, organizationName: "University of Michigan North Ann Arbor"]
    export_path = write_export(patron_row(userid: "not-imported"))

    result = importer.run(export_path: export_path, staff_map_path: write_staff_map("Uniqname" => "manager", "DirectReports" => []))

    expect(result).to be(false)
    expect(relations[:users].dataset.where(userid: "not-imported").count).to eq(0)
    expect(errors.string).to include("Expected one institution for UMAA")
  end

  it "expires users, memberships, and grants, then purges records older than 760 days" do
    expired = Factory[
      :user,
      userid: "expired-patron",
      dlpsExpiryTime: Time.now - 86_400,
      lastModifiedTime: Time.now - 100
    ]
    expired_institution = Factory[:institution]
    expired_group = Factory[:group]
    Factory[:institution_membership, user: expired, institution: expired_institution]
    Factory[:group_membership, user: expired, group: expired_group]
    collection = Factory[:collection]
    Factory[
      :grant,
      :for_user,
      user: expired,
      collection: collection,
      dlpsExpiryTime: Time.now - 3_600
    ]

    old = Factory[
      :user,
      :soft_deleted,
      userid: "purged-patron",
      lastModifiedTime: Time.now - (761 * 86_400)
    ]
    old_institution = Factory[:institution]
    Factory[
      :institution_membership,
      :soft_deleted,
      user: old,
      institution: old_institution,
      lastModifiedTime: Time.now - (761 * 86_400)
    ]
    old_collection = Factory[:collection, lastModifiedBy: "purged-patron"]

    importer.run(export_path: write_export(""), staff_map_path: write_staff_map("Uniqname" => "manager", "DirectReports" => []))

    expect(relations[:users].dataset.where(userid: "expired-patron").get(:dlpsDeleted)).to eq("t")
    expect(
      relations[:institution_memberships].dataset.where(userid: "expired-patron").get(:dlpsDeleted)
    ).to eq("t")
    expect(
      relations[:group_memberships].dataset.where(userid: "expired-patron").get(:dlpsDeleted)
    ).to eq("t")
    expect(
      relations[:grants].dataset.where(userid: "expired-patron").get(:dlpsDeleted)
    ).to eq("t")

    expect(relations[:users].dataset.where(userid: "purged-patron").count).to eq(0)
    expect(
      relations[:institution_memberships].dataset.where(userid: old.userid).count
    ).to eq(0)
    expect(relations[:collections].dataset.where(uniqueIdentifier: old_collection.uniqueIdentifier).get(:lastModifiedBy))
      .to eq("root")
  end

  def write_export(contents)
    path = File.join(@directory, "patrons.tsv")
    File.write(path, contents)
    path
  end

  def write_staff_map(data)
    path = File.join(@directory, "staff.json")
    File.write(path, JSON.generate(data))
    path
  end

  def patron_row(
    userid: "test-user",
    surname: "Example",
    given_name: "Patron",
    unit: "999999",
    status: "Undergraduate",
    campus: "UMAA",
    key: "12345678",
    email: "patron@example.test",
    address_1: "",
    address_2: "",
    locality: "",
    state: "",
    postal_code: "",
    phone: "",
    expiry: "2099-01-02"
  )
    [userid, surname, given_name, unit, status, campus, key, email, address_1, address_2, locality, state, postal_code, phone, expiry]
      .join("\t") + "\n"
  end
end
