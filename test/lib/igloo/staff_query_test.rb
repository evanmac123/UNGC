require "test_helper"

class Igloo::StaffQueryTest < ActiveSupport::TestCase

  test "includes staff" do
    staff = create(:staff_contact)
    contact = create(:contact)

    query = Igloo::StaffQuery.new
    assert query.include?(staff), "staff should be included"
    refute query.include?(contact), "only staff should be included"
  end

  test "recent staff" do
    older = create(:staff_contact,
      first_name: "Older",
      created_at: 1.year.ago,
      updated_at: 1.year.ago,
    )
    recent = create(:staff_contact,
      first_name: "Recent",
      created_at: 1.week.ago,
      updated_at: 1.week.ago,
    )

    query = Igloo::StaffQuery.new
    staff = query.recent(1.month.ago).map(&:name)
    assert_includes staff, recent.name
    assert_not_includes staff, older.name
  end

end
