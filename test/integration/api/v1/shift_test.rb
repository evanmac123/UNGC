require "test_helper"

class Api::V1::ShiftIntegrationTest < ActionDispatch::IntegrationTest

  should "do something useful with shift" do
    # Given that we have a resource

    link_url_base = '//google.com/1'
    resource = create(:resource)
    resource_link = create(:resource_link, resource: resource, url: "http:#{link_url_base}")

    # And MIT/Shift sends us (via the chrome extension) a resource to identify by its resource URL
    step1_request = { resource_url: library_resource_url(resource) }.to_json
    post_json "/api/v1/mit-shift/step1", step1_request, bearer: mit_shift_api_key

    # Then we reply with the resource's ID
    assert_equal "200", response.code, json_response
    assert_equal resource.id, json_response[:resource_id]

    # And MIT/Shift sends us (via the chrome extension) a resource to identify by its resource link URL
    step1_request = { resource_url: resource_link.url }.to_json
    post_json "/api/v1/mit-shift/step1", step1_request, bearer: mit_shift_api_key

    # And MIT/Shift sends us a secure protocol
    step1_request = { resource_url: "https:#{link_url_base}" }.to_json
    post_json "/api/v1/mit-shift/step1", step1_request, bearer: mit_shift_api_key

    # Then we reply with the resource's ID from the resource link
    assert_equal "200", response.code, json_response

    assert_equal resource.id, json_response[:resource_id]

    # When MIT/Shift sends us a weight response
    step3_request = weighted_payload(resource).to_json
    post_json "/api/v1/mit-shift/step3", step3_request, bearer: mit_shift_api_key

    # Then we reply with 200/OK
    assert_equal 200, response.status

    # And we have a new weight for the resource
    assert_not_nil resource.weight

    assert_equal 17, resource.weight.weights.dig("issue_categories", 0, "id")
  end

  private

  def mit_shift_api_key
    DEFAULTS[:mit_shift]["api_key"]
  end

  def weighted_payload(resource)
    @_weighted_payload ||= {
      "full_text_words": "Lorem ipsum dolor sit amet consectetur adipisicing elit Assumenda culpa delectus deleniti dignissimos distinctio dolorem eaque eos exercitationem fuga id inventore magnam modi neque omnis repudiandae tempora tempore vel voluptate",
      "full_text_all": "<!doctype html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0\"><meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\"><title>Document Title</title></head><body><div>Lorem ipsum dolor sit amet consectetur adipisicing elit Assumenda culpa delectus deleniti dignissimos distinctiodolorem eaque eos exercitationem fuga id inventore magnam modi neque omnis repudiandae tempora tempore vel voluptate</div></body></html>",
      "issue_categories": [
        {
          "id": 17,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 4,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "issues": [
        {
          "id": 17,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 4,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "resource_id": resource.id,
      "resource_title": "My Sustainability Page",
      "resource_type": "web",
      "resource_url": "https://example.com",
      "sdg": [
        {
          "id": 17,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 4,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "sdg_categories": [
        {
          "id": 17,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 4,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "sector_categories": [
        {
          "id": 1,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 3,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "sectors": [
        {
          "id": 1,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 3,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "topic_categories": [
        {
          "id": 1,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 3,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ],
      "topics": [
        {
          "id": 1,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 2,
          "custom_weight": 0.25,
          "suggested_weight": 0
        },
        {
          "id": 3,
          "custom_weight": 0.25,
          "suggested_weight": 0
        }
      ]
    }.freeze
  end

end
