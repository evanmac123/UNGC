require 'test_helper'

class EventPresenterTest < ActiveSupport::TestCase
  context 'given an event with taggings' do
    context 'that fails validation and does not save' do
      setup do
        create_sponsor
        create_topic
        create_issue
        create_sector

        @sponsor = create_sponsor
        @topic = create_topic
        @parent_issue = create_issue
        @child_issue = create_issue(parent: @parent_issue)
        @parent_sector = create_sector
        @child_sector = create_sector(parent: @parent_sector)
        @sdg = create_sustainable_development_goal
        @event = create_event

        @event.update_attributes({
          title: '',
          sponsor_ids: [@sponsor.id],
          topic_ids: [@topic.id],
          issue_ids: [@parent_issue.id],
          sector_ids: [@parent_sector.id],
          sustainable_development_goal_ids: [@sdg.id]
        })

        @presenter = EventPresenter.new(@event)
      end

      context 'given #sponsor_options' do
        should 'return the unsaved sponsor as selected' do
          unsaved_sponsor = @presenter.sponsor_options.find { |sponsor_option|
            sponsor_option.id == @sponsor.id
          }

          assert unsaved_sponsor.selected?, 'Unsaved sponsor was not selected.'
        end
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
            issue_option[0].id == @parent_issue.id
          }

          assert unsaved_issue[0].selected?, 'Unsaved issue was not selected.'
        end
      end

      context 'given #sector_options' do
        should 'return the unsaved sector as selected' do
          unsaved_sector = @presenter.sector_options.find { |sector_option|
            sector_option[0].id == @parent_sector.id
          }

          assert unsaved_sector[0].selected?, 'Unsaved sector was not selected.'
        end
      end

      context 'given #sustainable_development_goal_options' do
        should 'return the unsaved sustainable development goal as selected' do
          unsaved_sustainable_development_goal = @presenter.sustainable_development_goal_options.find { |sustainable_development_goal_option|
            sustainable_development_goal_option.id == @sdg.id
          }

          assert unsaved_sustainable_development_goal.selected?, 'Unsaved sustainable development goal was not selected.'
        end
      end
    end
  end
end
