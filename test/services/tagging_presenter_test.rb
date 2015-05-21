require 'test_helper'

class TaggingPresenterTest < ActiveSupport::TestCase
  context 'given a taggable object with taggings' do
    context 'that fails validation and does not save' do
      setup do
        create_topic
        create_issue
        create_sector

        @topic = create_topic
        @issue = create_issue
        @sector = create_sector
        @event = create_event

        @event.update_attributes({
          title: '',
          topic_ids: [@topic.id],
          issue_ids: [@issue.id],
          sector_ids: [@sector.id]
        })

        @presenter = TaggingPresenter.new(@event)
      end

      context 'given #topic_options' do
        should 'return the unsaved topic as selected' do
          unsaved_topic = @presenter.topic_options.find { |topic_option|
            topic_option[0].id == @topic.id
          }

          assert unsaved_topic[0].selected?, 'Unsaved topic was not selected.'
        end
      end

      context 'given #issue_options' do
        should 'return the unsaved issue as selected' do
          unsaved_issue = @presenter.issue_options.find { |issue_option|
            issue_option[0].id == @issue.id
          }

          assert unsaved_issue[0].selected?, 'Unsaved issue was not selected.'
        end
      end

      context 'given #sector_options' do
        should 'return the unsaved sector as selected' do
          unsaved_sector = @presenter.sector_options.find { |sector_option|
            sector_option[0].id == @sector.id
          }

          assert unsaved_sector[0].selected?, 'Unsaved sector was not selected.'
        end
      end
    end
  end
end
