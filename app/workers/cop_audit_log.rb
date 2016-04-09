class CopAuditLog
  include Sidekiq::Worker

  def self.log(event:, type:, status:, errors:,
               contact:, organization:, params:)
    perform_async(
      event,
      type,
      status,
      errors.to_sentence,
      contact.id,
      organization.id,
      params
    )
  end

  def perform(event, type, status, error_message, contact_id,
              organization_id, params)
    CopLogEntry.create!(
      event: event,
      cop_type: type,
      status: status,
      error_message: error_message,
      contact_id: contact_id,
      organization_id: organization_id,
      params: params
    )
  end

end

