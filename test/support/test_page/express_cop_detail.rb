module TestPage
  class ExpressCopDetail  < CopDetail

    def path
      admin_express_cop_path(@cop)
    end

  end
end
