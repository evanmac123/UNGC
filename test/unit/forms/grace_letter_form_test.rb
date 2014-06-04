require 'test_helper'

class GraceLetterFormTest < ActiveSupport::TestCase

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
      @english = create_language(name: "English")
    end

    context "when the form is created" do

      setup do
        @form = GraceLetterForm.new(@organization)
      end

      should "have a default language" do
        assert_equal @english.id, @form.cop_file.language_id
        assert_equal @english.id, @form.language_id
      end

      should "have a new cop file by default" do
        assert_instance_of CopFile, @form.cop_file
        assert @form.cop_file.new_record?, "cop_file should not be saved."
      end

    end

    context "when a grace letter is submitted" do
      setup do
        @form = GraceLetterForm.new(@organization)
        @params = cop_file_attributes
      end

      should "save" do
        assert @form.submit(@params), Array(@form.errors).join("  ")
      end

      should "create a grace letter" do
        assert_difference('CommunicationOnProgress.count', 1) do
          @form.submit(@params)
        end
      end

      should "create a cop file" do
        assert_difference('CopFile.count', 1) do
          @form.submit(@params)
        end
      end

      should "extend organization due date" do
        date = @organization.cop_due_on
        @form.submit(@params)
        assert_equal date + 90.days, @organization.cop_due_on.to_date
      end

      should "set grace letter start_on" do
        date = @organization.cop_due_on
        @form.submit(@params)
        assert_equal date, @form.grace_letter.starts_on.to_date
      end

      should "set grace letter ends_on" do
        date = @organization.cop_due_on
        @form.submit(@params)
        assert_equal date + 90.days, @form.grace_letter.ends_on.to_date
      end

    end

    context "when a grace letter is updated" do
      setup do
        @form = GraceLetterForm.new(@organization)
        @form.submit(cop_file_attributes)
      end


      should "set a new language" do
        l = create_language
        @form.update({language_id: l.id})
        assert_equal l, @form.cop_file.language
      end

      should "set a new attachment" do
        attr = {attachment: fixture_file_upload('files/untitled.jpg')}
        @form.update(attr)
        assert_equal attr[:attachment].original_filename, @form.cop_file.attachment_file_name
      end

      should "remove the old attachment" do
        attr = {attachment: fixture_file_upload('files/untitled.jpg')}
        @form.update(attr)
        assert_equal 1, @form.grace_letter.cop_files.count
      end

      should "not change the organization.cop_due_date" do
        due_date = @form.organization.cop_due_on
        attr = {attachment: fixture_file_upload('files/untitled.jpg')}
        @form.update(attr)
        assert_equal due_date, @form.organization.cop_due_on
      end

    end

  end
end
