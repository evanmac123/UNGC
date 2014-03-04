require 'test_helper'

class CopFormTest < ActiveSupport::TestCase

  def valid_cop_attrs(organization, params={})
    cop_attrs = valid_communication_on_progress_attributes(organization_id: organization.id)
    link_params = {
      "cop_links_attributes" => {
        "new_cop" => {
          "attachment_type" => "cop",
          "language_id" => @french.id,
          "url" => "http://example.com"
        }
      }
    }
    file_params = {cop_files_attributes: {"0" => cop_file_attributes}}
    HashWithIndifferentAccess.new cop_attrs.merge(params).merge(link_params).merge(file_params)
  end

  setup do
    create_principle_area
    create_organization_and_user
    @english = create_language(name:'English')
    @french = create_language(name:'French')
  end

  %w(basic intermediate advanced non_business).each do |type|
    context "When a new #{type} form is created" do

      setup do
        @form = CopForm.new_form(@organization, type, @organization_user.contact_info)
      end

      should "have a new cop" do
        assert @form.cop.new_record?
      end

      should "not be persisted" do
        refute @form.persisted?
      end

      should "set the title from the organization" do
        assert_equal @organization.cop_name, @form.title
      end

      should "set the cop type" do
        assert_equal type, @form.cop_type
      end

      should "have a contact name" do
        assert_equal @organization_user.contact_info, @form.contact_name
      end

      should "not be submitted" do
        refute @form.submitted?, "form should not yet be submitted"
      end

      should "have formats" do
        assert_not_nil @form.formats
      end

      should "have methods" do
        assert_not_nil @form.methods
      end

      should "have a form partial" do
        assert_equal "#{type}_form", @form.partial
      end

      context "creating cop links" do
        setup do
          @link = @form.new_link
        end

        should "have a cop attachment type" do
          assert_equal "cop", @link.attachment_type
        end

        should "have the default language" do
          assert_equal @english.id, @link.language_id
        end

        should "have an empty url" do
          assert_equal '', @link.url
        end
      end

      context "when build_cop_answers is called" do
        setup do
          2.times do
            question = @form.cop_questions.create(valid_cop_question_attributes)
            2.times do
              question.cop_attributes.create(valid_cop_attribute_attributes)
            end
          end
          @form.build_cop_answers
          @answers = @form.cop_answers
        end

        should "have 4 answers" do
          assert_equal 4, @answers.length
        end

        should "have no text" do
          assert @answers.map(&:text).none?
        end

        should "default to false" do
          assert @answers.map(&:value).none?
        end

        should "have cop_attribute ids" do
          ids = @form.cop_questions.map(&:cop_attributes).flatten.map(&:id)
          assert_equal ids, @answers.map(&:cop_attribute_id)
        end
      end

      context "With valid attributes" do
        setup do
          @result = @form.submit valid_cop_attrs(@organization)
        end

        should "be valid" do
          assert @result, Array(@form.errors.messages).join("\n")
        end

        should "remember link language" do
          assert_equal @french.id, @form.link_language
        end

        should "remember link url" do
          assert_equal 'http://example.com', @form.link_url
        end

        should "save the communication on progress" do
          assert @form.cop.persisted?
        end

        should "be submitted" do
          assert @form.submitted?
        end

      end

      context "With invalid attributes" do

        setup do
          @invalid_attrs = valid_cop_attrs(@organization)
          @invalid_attrs.delete(:cop_files_attributes)
          @invalid_form = CopForm.new_form(@organization, type, @organization_user.contact_info)
          @result = @invalid_form.submit @invalid_attrs
        end

        should "not be valid" do
          # basic forms are valid without a cop file.
          refute @result unless type == 'basic'
        end

        should "remember link language" do
          assert_equal @french.id, @invalid_form.link_language
        end

        should "remember link url" do
          assert_equal 'http://example.com', @invalid_form.link_url
        end

        should "not save the communication on progress" do
          refute @invalid_form.cop.persisted? unless type == 'basic'
        end

        should "be submitted" do
          assert @invalid_form.submitted?
        end

      end

    end

  end

  context "basic forms" do

    setup do
      @form = CopForm.new_form(@organization, 'basic', @organization_user.contact_info)
    end

    should "have filters" do
      refute @form.filters.empty?
    end

    should "not have a cop file" do
      assert_nil @form.cop_file
    end

    should "be valid" do
      assert @form.valid?
    end

  end

  context "When editing a form" do

    setup do
      # given an existing cop
      @old_cop = create_communication_on_progress
      assert_equal :learner, @old_cop.differentiation_level
      assert_not_nil @old_cop.created_at

      # and we submit some new changes
      @attrs = valid_cop_attrs(@organization, {
        include_actions: true,
        use_indicators: true,
        has_certification: true,
        include_continued_support_statement: true,
        references_labour: true,
        references_anti_corruption: true,
        additional_questions: true,
        references_water_mandate: true,
        include_measurement: true,
        use_gri: true,
        notable_program: true,
        references_human_rights: true,
        references_environment: true,
        meets_advanced_criteria: true,
        references_business_peace: true,
        starts_on: Date.today - 1.year + 1.day,
        ends_on: Date.today + 1.day,
      })
      @attrs.delete(:created_at)
      @attrs.delete(:updated_at)

      @form = CopForm.edit_form(@old_cop, @organization_user.contact_info)
    end

    context "basic fields" do

      setup do
        assert @form.submit @attrs
        # load the edit cop up.
        @cop = CommunicationOnProgress.find(@form.id)
        assert_not_nil @cop.created_at
      end

      %w(
        organization_id
        title
        email
        job_title
        contact_name
        include_actions
        include_measurement
        use_indicators
        cop_score_id
        use_gri
        has_certification
        notable_program
        description
        state
        include_continued_support_statement
        format
        references_human_rights
        references_labour
        references_environment
        references_anti_corruption
        meets_advanced_criteria
        starts_on
        ends_on
        method_shared
        differentiation
        references_business_peace
        references_water_mandate
      ).each do |f|
        field = f.to_sym
        should "have the new #{field}" do
          assert_equal @attrs[field], @cop.public_send(field)
        end
      end

      should "be upgraded to active differentiation" do
        assert_equal :active, @cop.differentiation_level
      end
    end

    context "adding a link" do

      setup do
        @attrs[:cop_links_attributes] = [valid_cop_link_attributes, valid_cop_link_attributes]
        assert @form.update(@attrs), @form.errors.full_messages.to_sentence
        @cop = CommunicationOnProgress.find(@form.id)
      end

      should "add a link" do
        assert_equal 2, @cop.cop_links.count
      end

    end

    context "deleting a link" do
      setup do
        @link1_attrs = valid_cop_link_attributes
        @link2_attrs = valid_cop_link_attributes
        @old_cop.cop_links.create! @link1_attrs
        @old_cop.cop_links.create! @link2_attrs

        assert_equal 2, @old_cop.cop_links.count
        @attrs = valid_cop_attrs(@organization)
        @attrs.delete(:created_at)
        @attrs.delete(:updated_at)
        @attrs[:cop_links_attributes] = [@old_cop.cop_links.first.attributes]

        assert @form.update(@attrs), @form.errors.full_messages.to_sentence
        @cop = CommunicationOnProgress.find(@form.id)
      end

      should "delete a link" do
        assert_equal @link1_attrs['url'], @cop.cop_links.first.url
        assert_equal 1, @cop.cop_links.count
      end

    end

  end

end
