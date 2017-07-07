require "test_helper"

module Igloo
  class StaffSyncTest < ActiveSupport::TestCase

    test "uploads recent staff to Igloo" do
      # Given two recently updated staff contacts
      jeff = build_stubbed(:staff_contact,
        id: 1002,
        first_name: "Jefferey",
        last_name: "Glover",
        email: "orie@roobmaggio.io",
        job_title: "Human Solutions Architect")

      nick = build_stubbed(:staff_contact,
        id: 1004,
        first_name: "Nicholaus",
        last_name: "Gusikowski",
        email: "patrick.hand@lesch.co",
        job_title: "Direct Identity Executive")

      last_sync = 1.week.ago
      query = mock("query")
      query.expects(:recent).
        with(last_sync).
        returns([jeff, nick])

      api = mock("api")
      sync = Igloo::StaffSync.new(api, query)

      # when we sync those contacts, the API should
      # be given properly formatted CSV for the 2 contacts
      api.expects(:bulk_upload).
        with(expected_csv)

      sync.upload_recent(last_sync)
    end

    test "returns the number of contacts synced" do
      2.times.map { create(:staff_contact) }

      sync = StaffSync.new(stub("api", :bulk_upload))

      count = sync.upload_recent(1.week.ago)
      assert_equal 2, count
    end

    private

    def expected_csv
      [
        "firstname,lastname,email,customIdentifier,bio,birthdate,gender,address,address2,city,state,zipcode,country,cellphone,fax,busphone,buswebsite,company,department,occupation,sector,im_skype,im_googletalk,im_msn,im_aol,s_facebook,s_linkedin,s_twitter,website,blog,associations,hobbies,interests,skills,isSAML,managedByLdap,s_google,status,extension,i_report_to,i_report_to_email,im_skypeforbusiness,groupsToAdd,groupsToRemove\n",
        "Jefferey,Glover,orie@roobmaggio.io,1002,,,,,,,,,USA,,,,,UNGC,,Human Solutions Architect,,,,,,,,,,,,,,,,,,,,,,,Administrators,\n",
        "Nicholaus,Gusikowski,patrick.hand@lesch.co,1004,,,,,,,,,USA,,,,,UNGC,,Direct Identity Executive,,,,,,,,,,,,,,,,,,,,,,,Administrators,\n",
      ].join
    end

  end
end
