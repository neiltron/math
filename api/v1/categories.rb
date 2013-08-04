module Math
  class Categories < Grape::API
    format :json

    resource :categories do
      desc 'Get all categories belonging to a user'
      get do
        categories = @user.categories.map do |category|
            Boxer.ship(:category, category)
        end

        {
          categories: categories
        }
      end

      desc 'Create a new category'
      params do
        requires :name, type: String, desc: 'Category name'
        optional :item_ids, desc: 'An list of items to be included in this category'
      end
      post do
        category = Category.create!( :name => params[:name] )

        #check for item existence, add to category
        params[:item_ids].each do |item_id|
          item = Item.find(item_id)
          category.items.push item unless item.nil?
        end unless params[:item_ids].nil?

        @user.categories.push category
        @user.save

        Boxer.ship(:category, category)
      end

      params do
        requires :category_id, desc: 'Category ID'
      end
      resource ':category_id' do
        before { @category = Category.find(params[:category_id]) }

        desc 'Get category information'
        get do
          Boxer.ship(:category, @category)
        end

        desc 'Update a category'
        put do
          @category.update_attributes!(params) if @category.user == current_user
        end

        desc 'Add items to a category'
        post 'items' do
          params[:items].each do |item_id|
            item = Item.find(item_id)
            @category.items.push item unless item.nil?
          end

          @category.save
        end

        desc 'Get all related records for a category'
        get 'records' do
          per = (params[:per] || 7).to_i
          page = (params[:page] || 0).to_i
          category = Category.find(params[:category_id])

          { values: category.records.to_a }
        end
      end
    end
  end
end