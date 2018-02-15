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
    FactoryBot.create(:country, local_network: local_network)
  end

  def local_network
    FactoryBot.create(:local_network)
  end

  def sector
    FactoryBot.create_list(:sector, 2)
  end

end
