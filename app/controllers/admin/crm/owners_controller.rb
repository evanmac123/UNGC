class Admin::Crm::OwnersController < AdminController

  def index
    @owners = Crm::Owner.all
  end

  def new
    @owner = Crm::Owner.new
    @participant_managers = participant_managers
  end

  def edit
    @owner = Crm::Owner.find(params.fetch(:id))
    @participant_managers = participant_managers
  end

  def create
    @owner = Crm::Owner.new(owner_params)
    if @owner.save
      redirect_to action: :index, notice: "Created"
    else
      @participant_managers = participant_managers
      render :new
    end
  end

  def update
    @owner = Crm::Owner.find(params.fetch(:id))
    if @owner.update(owner_params)
      redirect_to action: :index, notice: "Saved"
    else
      @participant_managers = participant_managers
      render :edit
    end
  end

  def destroy
    @owner = Crm::Owner.find(params.fetch(:id))
    @owner.destroy!
    redirect_to action: :index, notice: "Deleted"
  end

  private

  def owner_params
    params.require(:crm_owner).slice(:contact_id, :crm_id).permit(:contact_id, :crm_id)
  end

  def participant_managers
    Contact.ungc_staff.
      select(:first_name, :last_name, :id).
      map { |c| [c.name, c.id] }
  end
end
