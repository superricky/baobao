#encoding: utf-8
class Backend::BaseBranchesController < BackendApplicationController
  before_action :set_base_branch, only: :exchange_position
  def index
    @base_branches = @current_shop.base_branches.root_base_branches.paginate(:page => params[:page], :per_page => 25)
  end

  def change_position
    @branches = @current_shop.base_branches
    if params[:base_branch_ids].size != 2
      logger.error "The branch going to exchange are: #{params[:base_branch_ids]}"
      @errors = "需要提供进行排序的商户"
    else
      updated_branches =  @branches.find(params[:base_branch_ids])
      @first_base_branch = updated_branches[0]
      @second_base_branch = updated_branches[1]
      position = @second_base_branch.position
      @second_base_branch.position = @first_base_branch.position
      @first_base_branch.position = position
      Branch.transaction do
        if not @first_base_branch.save
          @errors = @first_base_branch.errors.full_messages
          raise ActiveRecord::Rollback
        end
        if not @second_base_branch.save
          @errors = @second_base_branch.errors.full_messages
          raise ActiveRecord::Rollback
        end
      end
    end
    redirect_to backend_shop_base_branches_path(@current_shop.slug)
  end


  private
  def set_base_branch
    @base_branch = @current_shop.base_branches.find(:id)
  end
end
