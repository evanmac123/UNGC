require 'test_helper'


class DataVisualization::SdgsControllerTest < ActionController::TestCase
  context 'test order by' do
    should 'get countries' do
      country = create(:country)
      get :countries, id: country
      assert_response :success
      assert_template 'data_visualization/sdgs/countries'
    end
  end
end
