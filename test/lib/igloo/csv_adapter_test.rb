require "test_helper"

module Igloo
  class CsvAdapterTest < ActiveSupport::TestCase

    test "it wraps single records" do
      adapter = CsvAdapter.new
      csv = parse(adapter.to_csv("firstname" => "Alice"))
      assert_equal 1, csv.length
    end

    test "it drops unknown values" do
      adapter = CsvAdapter.new
      csv = parse(adapter.to_csv("invalid" => true))
      assert_equal 1, csv.length
      assert_nil csv[0]["invalid"]
    end

    test "defaults missing values to nil" do
      adapter = CsvAdapter.new
      csv = parse adapter.to_csv({})
      assert_nil csv[0]["firstname"]
    end

    test "uses supplied values" do
      adapter = CsvAdapter.new
      csv = parse adapter.to_csv("firstname" => "Alice")
      assert_equal "Alice", csv[0]["firstname"]
    end

    test "it adds headers" do
      adapter = CsvAdapter.new

      csv = parse adapter.to_csv("firstname" => "Alice")
      headers = csv.headers

      assert_includes headers, "email"
      assert_equal "firstname", headers[0]
      assert_equal "lastname", headers[1]
    end

    test "handles more than 1 row" do
      adapter = CsvAdapter.new

      records = [
        { "firstname" => "Alice", "lastname" => "Walker" },
        { "firstname" => "Bob", "lastname" => "Ross" }
      ]

      csv = parse adapter.to_csv(records)

      row1 = csv[0]
      assert_equal "Alice", row1["firstname"]
      assert_equal "Walker", row1["lastname"]

      row2 = csv[1]
      assert_equal "Bob", row2["firstname"]
      assert_equal "Ross", row2["lastname"]
    end

    private

    def parse(csv)
      CSV.parse(csv, headers: true)
    end

  end
end
