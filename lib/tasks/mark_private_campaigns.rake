desc "One-shot script to mark private campaigns"
task mark_private_campaigns: :environment do

  campaign_ids = [
    '701A0000000WqNPIA0',
    '701A0000000VZjVIAW',
    '701A0000000VPxiIAG',
    '701A0000000WmeTIAS',
    '701A0000000kqHGIAY',
    '701A0000000mdZvIAI',
    '701A0000000mW1PIAU',
    '701A0000000mTPcIAM',
    '701A0000000nAzKIAU',
    '701A0000000nAzFIAU',
    '70112000000jw0YAAQ',
    '70112000000kR2oAAE',
    '701A0000000W4XJIA0',
    '701A0000000mteAIAQ',
    '701A0000000Wq3DIAS',
    '701A0000000WqN5IAK',
    '701A0000000VZl2IAG',
    '701A0000000VOFNIA4',
    '701A0000000WmeOIAS',
    '701A0000000krjYIAQ',
    '701A0000000mKRdIAM',
    '701A0000000mnsrIAA',
    '701A0000000kix0IAA',
  ]

  Campaign.where(campaign_id: campaign_ids)
          .update_all(is_private: true)
end
