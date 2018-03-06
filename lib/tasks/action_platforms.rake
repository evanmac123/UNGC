# -*- coding: utf-8 -*-
namespace :action_platforms do

  desc "Create the initial Action Platforms"
  task create: :environment do
    platforms = [
      {
        name: "The Blueprint for SDG Leadership",
        slug: "blueprint-for-leadership",
        description: "Participants in the Blueprint for SDG Leadership platform will develop a new framework that aligns stakeholder expectations and defines corporate leadership to support all 17 SDGs. Companies will join an expert group comprised of UN Partners, civil society organizations and Local Networks to lead a global consultation process that will consolidate existing standards and leadership principles to advance the SDGs. When launched at the UN Global Compact Leaders Summit in September 2017, the Blueprint will serve as a foundational document for Global Compact participants to use to align their strategies, goals and targets to support the achievement of the SDGs.",
      },
      {
        name: "Reporting on the SDGs",
        slug: "reporting-on-sdgs",
        description: "Reporting on the SDGs, in partnership with GRI, will enable business to incorporate SDG reporting into their existing processes, empowering them to act and make achieving the SDGs a reality. Platform participants will receive expert guidance and identify solutions and innovative ways to report on their SDG progress. Through self-assessment exercises, participants will determine the SDGs that are most material to their business and improve how they communicate on their contributions in those areas. Participants will also collaborate on the development of a validated list of business disclosures across the SDGs and contribute to a publication on leadership and best practices for business on SDG reporting.",
      },
      {
        name: "Breakthrough Innovation",
        slug: "breakthrough-innovation",
        description: "In partnership with Volans, PA Consulting, The DO School and Singularity University, Breakthrough Innovation for the SDGs aims to connect companies with some of the world’s leading exponential thinkers and innovators to explore the potential of disruptive technologies (e.g. Artificial Intelligence, Big Data, the Internet of Things), and create the sustainable business models of the future. Through facilitated workshops, webinars and online briefs, participants will gain insights on the industrial applications of disruptive technology, identify business models and technologies most relevant to their companies, and receive support for integrating solutions powered by disruptive technologies into their sustainability initiatives.",
      },
      {
        name: "Financial Innovation for the SDGs",
        slug: "financial-innovation",
        description: "In collaboration with the United Nations Environment Programme Finance Initiative (UNEP FI) and Principles for Responsible Investment (PRI), Financial Innovation for the SDGs will identify innovative financial instruments that have the potential to direct private finance towards critical sustainability solutions. The platform will develop guidance on impact investment strategies that support sustainable development, map current and emerging financial instruments, and provide a laboratory for the development of new innovative instruments.",
      },
      {
        name: "Pathways to Low-Carbon & Resilient Development",
        slug: "pathways-to-low-carbon",
        description: "In collaboration with the United Nations Environment Programme Finance Initiative (UNEP FI) and Principles for Responsible Investment (PRI), Financial Innovation for the SDGs will identify innovative financial instruments that have the potential to direct private finance towards critical sustainability solutions. The platform will develop guidance on impact investment strategies that support sustainable development, map current and emerging financial instruments, and provide a laboratory for the development of new innovative instruments."
      },
      {
        name: "Health is Everyone's Business",
        slug: "health",
        description: "The platform Health is Everybody’s Business will enable business to minimize negative impacts and accelerate positive action to support sustainable living, health and well-being in the workforce, community and marketplace. The platform will demonstrate why health and well-being are imperative for sustainable business, develop the business case for action and showcase opportunities across supply and value chains. Participants will explore opportunities for collective impact through cross-sector partnerships and local implementation and collaborate on the development of a scorecard that business in any sector can use to drive performance and report on progress.",
      },
      {
        name: "Business for Inclusion",
        slug: "business-for-inclusion",
        description: "Business for Inclusion will consider the spectrum of ways that business can help end discrimination, promote equal opportunity, tackle harmful stereotypes and build cultures of respect and understanding. Platform participants will fine-tune their inclusion strategies to maximize impact and connect to corporate sustainability objectives. They will explore launching new business practices or expanding existing initiatives to create opportunities for economically and socially excluded people, and have the opportunity to engage in multi-stakeholder partnerships and business-led advocacy to promote the social and economic benefits of inclusion. The platform will amplify the stories of companies and business leaders that are committed to making the world more inclusive and sustainable."
      },
      {
        name: "Business Action for Humanitarian Needs",
        slug: "business-action-for-humanitarian",
        description: "Business Action for Humanitarian Needs will provide an entry point for business to support the implementation of the New York Declaration for Refugees and Migrants. By developing guidance, supporting global advocacy efforts, mapping opportunities for business engagement and designing new innovative solutions, the platform aims to increase and deepen private sector action in support of vulnerable migrants, refugees and internally displaced persons (IDPs)."
      },
      {
        name: "Decent Work in Global Supply Chains",
        slug: "decent-work",
        description: "Business Action for Humanitarian Needs will provide an entry point for business to support the implementation of the New York Declaration for Refugees and Migrants. By developing guidance, supporting global advocacy efforts, mapping opportunities for business engagement and designing new innovative solutions, the platform aims to increase and deepen private sector action in support of vulnerable migrants, refugees and internally displaced persons (IDPs)."
      }
    ]

    platforms.each do |attrs|
      ActionPlatform::Platform.where(slug: attrs.fetch(:slug))
        .first_or_create(attrs.slice(:name, :slug, :description))
    end
  end

  desc "move sitemap pages to action platform specific locations"
  task move_pages: :environment do
    map = {
      "breakthrough-innovation" => "breakthrough-innovation",
      "sdg-reporting" => "sdg-reporting",
      "low-carbon-development" => "low-carbon-development",
      "financial-innovation" => "financial-innovation",
      "health" => "health",
      "decent-work-supply-chains" => "decent-work-supply-chains",
      "humanitarian" => "huamnitarian",
      "ocean" => "ocean",
      "water" => "water-stewardess-for-sdgs",
      "justice" => "justice-and-strong-institutions",
    }

    moved = map.keys.select do |slug|
      old_path = "/take-action/action/#{slug}"
      new_path = "/take-action/action-platforms/#{slug}"
      Container.find_by(path: old_path)&.update!(path: new_path)
    end

    ap "Updated #{moved.count} container paths"

    tagged = map.select do |path, platform_slug|
      container = Container.find_by(path: "/take-action/action-platforms/#{path}")
      platform = ActionPlatform::Platform.find_by(slug: platform_slug)

      unless container.taggings.where(action_platform: platform).exists?
        container.taggings.create!(action_platform: platform)
        ap "Tagged #{path} with #{platform.name}"
      end
    end

  end
end
