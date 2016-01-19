require 'test_helper'

class CopFormTest < ActiveSupport::TestCase

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
        assert_equal @organization_user.contact_info, @form.contact_info
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

    should "set basic fields" do
      assert @form.submit @attrs
      # load the edit cop up.
      @cop = CommunicationOnProgress.find(@form.id)
      assert_not_nil @cop.created_at

      assert_equal @attrs[:organization_id], @cop.organization_id
      assert_equal @attrs[:title], @cop.title
      assert_equal @attrs[:contact_info], @cop.contact_info
      assert_equal @attrs[:include_actions], @cop.include_actions
      assert_equal @attrs[:include_measurement], @cop.include_measurement
      assert_equal @attrs[:use_indicators], @cop.use_indicators
      assert_equal @attrs[:use_gri], @cop.use_gri
      assert_equal @attrs[:has_certification], @cop.has_certification
      assert_equal @attrs[:notable_program], @cop.notable_program
      assert_equal @attrs[:description], @cop.description
      assert_equal @attrs[:state], @cop.state
      assert_equal @attrs[:include_continued_support_statement], @cop.include_continued_support_statement
      assert_equal @attrs[:format], @cop.format
      assert_equal @attrs[:references_human_rights], @cop.references_human_rights
      assert_equal @attrs[:references_labour], @cop.references_labour
      assert_equal @attrs[:references_environment], @cop.references_environment
      assert_equal @attrs[:references_anti_corruption], @cop.references_anti_corruption
      assert_equal false, @cop.meets_advanced_criteria
      assert_equal @attrs[:starts_on], @cop.starts_on
      assert_equal @attrs[:ends_on], @cop.ends_on
      assert_equal @attrs[:method_shared], @cop.method_shared
      assert_equal 'active', @cop.differentiation
      assert_equal @attrs[:references_business_peace], @cop.references_business_peace
      assert_equal @attrs[:references_water_mandate], @cop.references_water_mandate
      assert_equal :active, @cop.differentiation_level
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

    context "deleting all the links" do
      setup do
        @old_cop.cop_links.create! valid_cop_link_attributes
        @old_cop.cop_links.create! valid_cop_link_attributes

        assert_equal 2, @old_cop.cop_links.count
        @attrs = valid_cop_attrs(@organization)
        @attrs.delete(:created_at)
        @attrs.delete(:updated_at)
        @attrs[:cop_links_attributes] = []

        assert @form.update(@attrs), @form.errors.full_messages.to_sentence
        @cop = CommunicationOnProgress.find(@form.id)
      end

      should "delete all the links" do
        assert_equal 0, @cop.cop_links.count
      end

    end

    should "delete all the links when no links are supplied" do
      @old_cop.cop_links.create! valid_cop_link_attributes

      attrs = valid_cop_attrs(@organization)
      attrs.delete(:created_at)
      attrs.delete(:updated_at)
      attrs.delete(:cop_links_attributes)

      assert @form.update(attrs), @form.errors.full_messages.to_sentence
      cop = CommunicationOnProgress.find(@form.id)

      assert_equal 0, cop.cop_links.count
    end

  end

  should "adjust an organization's cop_state when publishing a draft" do
    # When an org creates a draft COP and the publishes it, the cop_due_on
    # date should be adjusted

    # Given an non-communicating organization
    original_due_date = Date.today - 1.month
    non_communicating = Organization::COP_STATE_NONCOMMUNICATING
    @organization.update(
      cop_due_on: original_due_date,
      cop_state: non_communicating)

    # When a draft is save
    form = CopForm.new_form(@organization, :intermediate,
                            @organization_user.contact_info)
    form.save_draft(valid_cop_attrs(@organization))
    @organization.reload

    # Then the organization should still be non-communicating, and it's
    # cop due date unchanged.
    assert_equal original_due_date, @organization.cop_due_on
    assert_equal non_communicating, @organization.cop_state

    # When the COP is submitted
    form.submit({})
    @organization.reload

    # Then the organization should be active with the adjusted cop_due_on
    assert_equal 'active', @organization.cop_state
    assert @organization.cop_due_on > Date.today, 'cop_due_on was not adjusted'
  end

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
    attrs = cop_attrs.merge(params)
      .merge(link_params)
      .merge(file_params)
      .with_indifferent_access
    attrs.delete(:id)
    attrs.delete(:submission_status)
    attrs
  end

  should "not create duplicates cop_answers when saving a draft" do
    # Given a new COP
    form = CopForm.new_form(@organization, :advanced,
                            @organization_user.contact_info)

    # With 1 question and 1 attribute
    question = form.cop_questions.create(valid_cop_question_attributes)
    attribute = question.cop_attributes.create(valid_cop_attribute_attributes)

    # And we save a draft
    params = {
      "cop_answers_attributes" => {
        "0" => {
          "cop_attribute_id" => attribute.id,
          "value" => "0"
        }
      }
    }.with_indifferent_access

    assert_difference -> {CopAnswer.count}, 1 do
      form.save_draft(params)
    end

    # When we edit the COP, and save a new draft, we won't create any more
    # answers
    edit_form = CopForm.edit_form(form.cop, @organization_user.contact_info)
    assert_difference -> {CopAnswer.count}, 0 do
      edit_form.save_draft(params)
    end
  end

  should  "not duplicate cop_answers when saving a draft" do
  form = CopForm.new_form(@organization, :basic,
                          @organization_user.contact_info)

  # With 1 question and 1 attribute
  question = form.cop_questions.create(valid_cop_question_attributes)
  attribute = question.cop_attributes.create(valid_cop_attribute_attributes)

  # And we save a draft
  params = {
            "cop_answers_attributes" => [{
                "cop_attribute_id" => attribute.id,
                "value" => "0"
            }]
          }.with_indifferent_access

          assert_difference -> {CopAnswer.count}, 1 do
            form.save_draft(params)
          end

          # When we edit the COP, and save a new draft, we won't create any more
          # answers
          edit_form = CopForm.edit_form(form.cop, @organization_user.contact_info)
          assert_difference -> {CopAnswer.count}, 0 do
            edit_form.save_draft(params)
          end
        end

end
