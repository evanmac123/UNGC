class CaseExampleMailerPreview < ActionMailer::Preview

  def case_example_received
    CaseExampleMailer.case_example_received(params)
  end

  private

  def params
    @params = { company: "Shake Shack",
                country: country,
                sectors:  sector,
                is_participant: true,
                link: "/files/case-example.txt"
                }
  end

  def country
    FactoryGirl.create(:country, local_network: local_network)
  end

  def local_network
    FactoryGirl.create(:local_network)
  end

  def sector
    FactoryGirl.create_list(:sector, 2)
  end

end
