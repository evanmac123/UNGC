module TestPage
  module Signup
    class Step1 < TestPage::Base

      def path
        "/participation/join/application/step1/business"
      end

      def submit(params = {})
        defaults = FactoryGirl.attributes_for(:organization).merge(
          organization_name: Faker::Company.name,
          website: Faker::Internet.url,
          employees: 23,
          sector: "Beverages",
          revenue: "12345678",
          country: "USA",
          subsidiary?: false,
          tobacco?: false,
          landmines?: false,
        )
        args = params.reverse_merge(defaults)
        fill_in "Organization Name", with: args.fetch(:organization_name)
        fill_in "Website", with: args.fetch(:website)
        fill_in "Employees", with: args.fetch(:employees)
        select args.fetch(:ownership), from: "Ownership"

        if args.key?(:exchange)
          select args.fetch(:exchange), from: "Exchange", visible: false
        end

        if args.key?(:stock_symbol)
          fill_in "Stock symbol", with: args.fetch(:stock_symbol), visible: false
        end

        select args.fetch(:sector), from: "Sector", visible: false
        fill_in I18n.t("level_of_participation.confirm_annual_revenue"), with: args.fetch(:revenue)
        select args.fetch(:country), from: "Country"

        within("label[for='organization_is_subsidiary']") {
          args.fetch(:subsidiary?) ? choose("Yes") : choose("No")
        }

        if args.key?(:parent_company_name) && args.key?(:parent_company_id)
          fill_in "organization_parent_company_name", with: args.fetch(:parent_company_name)
          simulate_parent_company_selection(args.fetch(:parent_company_id))
        end

        within("label[for='organization_is_tobacco']") {
          args.fetch(:tobacco?) ? choose("Yes") : choose("No")
        }
        within("label[for='organization_is_landmine']") {
          args.fetch(:landmines?) ? choose("Yes") : choose("No")
        }

        click_on "Next"

        Step2.new
      end

      private

      def simulate_parent_company_selection(parent_company_id)
        find(:xpath, "//input[@id='organization_parent_company_id']", visible: :all).set(parent_company_id)
      end

    end
  end
end
