# frozen_string_literal: true

require "date"
require "json"
require "sequel"

module Lauth
  class PatronImporter
    CAMPUSES = {
      "UMAA" => "University of Michigan%Ann Arbor",
      "UMDB" => "University of Michigan%Dearborn",
      "UMFL" => "University of Michigan%Flint",
      "UMLS" => "University of Michigan%Library Staff",
      "UMXX" => "University of Michigan%Pseudo%",
      "MIRL" => "Non-University of Michigan Mirlyn Users"
    }.freeze

    LIBRARY_UNITS = {
      "380015" => "UMBS Kresge Library",
      "412000" => "Law Library",
      "514200" => "Bentley Historical Library",
      "514400" => "Clements Library",
      "567001" => "UMTRI Library",
      "689250" => "Gerald R Ford Library",
      "923000" => "Dearborn Mardigian Library",
      "951200" => "Flint Library",
      "513100" => "Media Commons",
      "499989" => "UM Press: Investment",
      "499990" => "UM Press: General",
      "499991" => "UM Press: Acquisition",
      "499992" => "UM Press: Copy Editing",
      "499993" => "UM Press: Production",
      "499994" => "UM Press: Sales and Marketing",
      "499995" => "UM Press: Administration",
      "499996" => "UM Press: Business Office",
      "499997" => "UM Press: ESL",
      "499998" => "UM Press: Distributed Clients",
      "499999" => "UM Press: IT and Ebooks"
    }.freeze
    FIELD_NAMES = %i[
      userid surname given_name unit status campus key email address_1 address_2
      locality state postal_code telephone expiry
    ].freeze
    MAX_LENGTHS = {
      userid: 64,
      givenName: 32,
      surname: 32,
      rfc822Mailbox: 64,
      organizationalUnitName: 128,
      postalAddress: 128,
      localityName: 32,
      stateOrProvinceName: 32,
      postalCode: 9,
      telephoneNumber: 16,
      organizationalStatus: 8,
      dlpsKey: 16
    }.freeze
    BATCH_SIZE = 100
    IN_CLAUSE_SIZE = 500
    PURGE_AFTER_DAYS = 760

    def initialize(rom:, output: $stdout, errors: $stderr)
      @rom = rom
      @output = output
      @errors = errors
    end

    def run(export_path:, staff_map_path: nil)
      staff_ids = load_staff_ids(staff_map_path)
      campus_ids = resolve_campuses
      return false unless campus_ids

      import_export(export_path, campus_ids, staff_ids)
      expire_records
      true
    end

    private

    attr_reader :rom, :output, :errors

    def relation(name)
      rom.relations[name]
    end

    def database
      rom.gateways[:default].connection
    end

    def load_staff_ids(path)
      unless path
        errors.puts("Warning: staff map not provided; staff-feed matches will be skipped.")
        return {}
      end

      staff_tree = JSON.parse(File.read(path))
      uniqnames(staff_tree).compact.to_h { |uniqname| [uniqname, true] }
    end

    def uniqnames(person)
      raise ArgumentError, "staff map must contain a person object" unless person.is_a?(Hash)

      reports = person["DirectReports"] || []
      raise ArgumentError, "staff map DirectReports must be an array" unless reports.is_a?(Array)

      [person["Uniqname"], *reports.flat_map { |report| uniqnames(report) }]
    end

    def resolve_campuses
      ids = {}

      CAMPUSES.each do |campus, pattern|
        matches = relation(:institutions).dataset
          .where(Sequel.like(:organizationName, pattern))
          .select_map(:uniqueIdentifier)

        if matches.length != 1
          errors.puts("Expected one institution for #{campus}; found #{matches.length}. Aborting.")
          return nil
        end

        ids[campus] = matches.first
      end

      ids
    end

    def import_export(path, campus_ids, staff_ids)
      processed = 0
      skipped = 0
      batch = []

      File.foreach(path).with_index(1) do |line, line_number|
        row = normalize_row(line)
        unless row && campus_ids.key?(row[:campus])
          skipped += 1
          errors.puts("Skipping invalid patron record on line #{line_number}.")
          next
        end

        batch << row
        next unless batch.length == BATCH_SIZE

        import_batch(batch, campus_ids, staff_ids)
        processed += batch.length
        output.puts("#{processed} patron records processed") if (processed % 10_000).zero?
        batch.clear
      end

      unless batch.empty?
        import_batch(batch, campus_ids, staff_ids)
        processed += batch.length
      end

      noun = (processed == 1) ? "record" : "records"
      output.puts("Processed #{processed} patron #{noun}; skipped #{skipped}.")
    end

    def normalize_row(line)
      values = FIELD_NAMES.zip(line.chomp.split("\t", -1)).to_h

      userid = values[:userid].to_s.delete(" ")
      email = values[:email].to_s.delete(" ")
      key = values[:key].to_s.delete(" -")
      expiry = values[:expiry].to_s.delete(" ")

      return if userid.empty? || userid.match?(/@.*umich[.]edu\z/)
      return if values[:given_name].to_s.empty? || values[:surname].to_s.empty?
      return if email.empty? || key.empty?
      return unless expiry.match?(/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/)

      date = Date.strptime(expiry, "%Y-%m-%d")
      expiry_time = Time.local(date.year, date.month, date.day, 23, 59, 59)
      email += "@umich.edu" unless email.include?("@")
      key = "600847#{key}" if key.length == 8 && !key.start_with?("600847")

      address_1 = trim_end(values[:address_1])
      address_2 = trim_end(values[:address_2])
      postal_address = address_1
      postal_address += "\n#{address_2}" unless address_2.empty?

      telephone = values[:telephone].to_s.gsub(/[^().0-9tTdD-]/, "")
      telephone.sub!("()", "")
      telephone = "" if telephone == "-"

      {
        userid: truncate(userid, MAX_LENGTHS[:userid]),
        givenName: truncate(values[:given_name], MAX_LENGTHS[:givenName]),
        surname: truncate(values[:surname], MAX_LENGTHS[:surname]),
        rfc822Mailbox: truncate(email, MAX_LENGTHS[:rfc822Mailbox]),
        organizationalUnitName: optional_truncate(trim_end(values[:unit]), MAX_LENGTHS[:organizationalUnitName]),
        postalAddress: optional_truncate(postal_address, MAX_LENGTHS[:postalAddress]),
        localityName: optional_truncate(trim_end(values[:locality]), MAX_LENGTHS[:localityName]),
        stateOrProvinceName: optional_truncate(trim_end(values[:state]), MAX_LENGTHS[:stateOrProvinceName]),
        postalCode: optional_truncate(trim_end(values[:postal_code]), MAX_LENGTHS[:postalCode]),
        telephoneNumber: optional_truncate(telephone, MAX_LENGTHS[:telephoneNumber]),
        organizationalStatus: optional_truncate(trim_end(values[:status]), MAX_LENGTHS[:organizationalStatus]),
        dlpsKey: truncate(key, MAX_LENGTHS[:dlpsKey]),
        dlpsExpiryTime: expiry_time,
        campus: values[:campus]
      }
    rescue Date::Error
      nil
    end

    def trim_end(value)
      value.to_s.sub(/ +\z/, "")
    end

    def truncate(value, length)
      value.to_s.slice(0, length)
    end

    def optional_truncate(value, length)
      truncated = truncate(value, length)
      truncated.empty? ? nil : truncated
    end

    def import_batch(rows, campus_ids, staff_ids)
      database.transaction do
        rows.each do |row|
          upsert_user(row)
          ensure_membership(
            :institution_memberships,
            {userid: row[:userid], inst: campus_ids.fetch(row[:campus])}
          )

          if staff_ids.key?(row[:userid]) || library_staff?(row)
            ensure_membership(
              :institution_memberships,
              {userid: row[:userid], inst: campus_ids.fetch("UMLS")}
            )
          end
        end
      end
    end

    def upsert_user(row)
      user = row.except(:campus)
        .merge(personalTitle: nil, initials: nil, dlpsCourse: nil)
      users = relation(:users).dataset
      existing = users.where(userid: user[:userid]).first

      if existing
        changed = user.any? { |field, value| existing[field] != value }
        return unless changed || existing[:dlpsDeleted] != "f"

        users.where(userid: user[:userid]).update(
          user.merge(lastModifiedTime: Time.now, lastModifiedBy: "root", dlpsDeleted: "f")
        )
      else
        users.insert(
          user.merge(
            userPassword: "@umich.edu",
            manager: 0,
            lastModifiedTime: Time.now,
            lastModifiedBy: "root",
            dlpsDeleted: "f"
          )
        )
      end
    end

    def ensure_membership(name, keys)
      memberships = relation(name).dataset
      existing = memberships.where(keys).first
      now = Time.now

      if existing
        return if existing[:dlpsDeleted] == "f"

        memberships.where(keys).update(
          lastModifiedTime: now,
          lastModifiedBy: "root",
          dlpsDeleted: "f"
        )
      else
        memberships.insert(
          keys.merge(lastModifiedTime: now, lastModifiedBy: "root", dlpsDeleted: "f")
        )
      end
    end

    # The Library is 47XXXX; https://spg.umich.edu/org-charts/470000
    # Some other units are considered library staff; see hash above.
    def library_staff?(row)
      unit = row[:organizationalUnitName]
      in_library = unit&.start_with?("47") || LIBRARY_UNITS.key?(unit)
      eligible_status = %w[Faculty Staff].include?(row[:organizationalStatus])

      in_library && eligible_status
    end

    def expire_records
      now = Time.now
      expire_users(now)
      purge_old_records(now - (PURGE_AFTER_DAYS * 86_400))
    end

    def expire_users(now)
      users = relation(:users).dataset
      expired_userids = users
        .where(dlpsDeleted: "f")
        .exclude(userid: "root")
        .exclude(dlpsExpiryTime: nil)
        .where { dlpsExpiryTime < now }
        .select_map(:userid)

      database.transaction do
        expired_userids.each_slice(IN_CLAUSE_SIZE) do |userids|
          expired_values = {lastModifiedTime: now, lastModifiedBy: "root", dlpsDeleted: "t"}
          users.where(userid: userids).update(expired_values)
          relation(:group_memberships).dataset.where(userid: userids).update(expired_values)
          relation(:institution_memberships).dataset.where(userid: userids).update(expired_values)
        end

        relation(:grants).dataset
          .where(dlpsDeleted: "f")
          .exclude(dlpsExpiryTime: nil)
          .where { dlpsExpiryTime < now }
          .update(lastModifiedTime: now, lastModifiedBy: "root", dlpsDeleted: "t")
      end
    end

    def purge_old_records(cutoff)
      users = relation(:users).dataset
      old_userids = users
        .where(dlpsDeleted: "t")
        .where { lastModifiedTime < cutoff }
        .select_map(:userid)

      database.transaction do
        old_userids.each_slice(IN_CLAUSE_SIZE) do |userids|
          %i[collections locations institutions grants networks users groups].each do |name|
            relation(name).dataset.where(lastModifiedBy: userids).update(lastModifiedBy: "root")
          end

          users.where(userid: userids).delete
        end

        [relation(:group_memberships), relation(:institution_memberships), relation(:grants)].each do |record_relation|
          record_relation.dataset
            .where(dlpsDeleted: "t")
            .where { lastModifiedTime < cutoff }
            .delete
        end
      end
    end
  end
end
